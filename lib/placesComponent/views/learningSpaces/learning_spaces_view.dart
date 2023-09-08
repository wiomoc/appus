import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:campus_flutter/base/helpers/delayed_loading_indicator.dart';
import 'package:campus_flutter/placesComponent/views/learningSpaces/learning_spaces_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../base/helpers/retryable.dart';
import '../../../base/views/error_handling_view.dart';
import '../../../base/views/generic_stream_builder.dart';
import 'learning_spaces_model.dart';

class LearningSpacesView extends StatefulWidget {
  const LearningSpacesView({super.key});

  @override
  LearningSpacesViewState createState() {
    return LearningSpacesViewState();
  }
}

class LearningSpacesViewState extends State<LearningSpacesView> {
  late Retryable<LearningSpaces> _learningSpacesRetryable;
  late Set<String> _selectedCampuses;
  late Set<String> _selectedTypes;
  late Set<String> _selectedAccessGroups;
  LearningSpaces? _allLearningSpaces;
  Map<String, double> _occupations = {};
  Error? _error;

  @override
  void initState() {
    super.initState();

    _learningSpacesRetryable = Retryable(() => LearningSpacesService().fetchLearningSpaces());
    _learningSpacesRetryable.stream.listen((learningSpaces) {
      setState(() {
        _allLearningSpaces = learningSpaces;
        _selectedCampuses = learningSpaces.locations.map((campus) => campus.id).toSet();
        _selectedTypes = learningSpaces.types.map((type) => type.id).toSet();
        _selectedAccessGroups = {"all"};
      });
    }, onError: (error) {
      setState(() {
        _error = error;
      });
    });

    LearningSpacesService().fetchOccupation().then((occupations) => setState(
          () {
            _occupations = occupations;
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(leading: const BackButton(), title: Text("Learning Spaces")), body: _body());
  }

  Widget _body() {
    final learningSpaces = _allLearningSpaces;
    if (learningSpaces != null) {
      final screenWidth = MediaQuery.of(context).size.width;
      final crossAxisCount = screenWidth ~/ 200;
      final widthOverflow = screenWidth % 200;

      final filteredRooms = learningSpaces.rooms
          .where((room) =>
              _selectedCampuses.contains(room.location) &&
              _selectedAccessGroups.contains(room.accessGroups) &&
              _selectedTypes.contains(room.type))
          .toList();
      return CustomScrollView(slivers: [
        SliverList.list(children: [
          _choices(learningSpaces.locations, _selectedCampuses),
          _choices(learningSpaces.accessGroups, _selectedAccessGroups),
          _choices(learningSpaces.types, _selectedTypes),
        ]),
        if (filteredRooms.isNotEmpty)
          SliverGrid.builder(
              itemCount: filteredRooms.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisExtent: 255 + widthOverflow / (crossAxisCount * 2),
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 0),
              itemBuilder: (context, index) {
                final room = filteredRooms[index];
                return Padding(
                    padding: const EdgeInsets.all(5),
                    child: RoomCard(
                      room: room,
                      occupationPercentage: room.tikName != null ? _occupations[room.tikName!] : null,
                    ));
              })
        else
          SliverList.list(children: [
            SizedBox(
                height: MediaQuery.of(context).size.height / 1.3,
                child: const Center(
                  child: Text("No learning spaces match the selected criterias"),
                ))
          ])
      ]);
    } else if (_error != null) {
      return ErrorHandlingView(
        error: _error!,
        errorHandlingViewType: ErrorHandlingViewType.fullScreen,
        retry: (force) {
          _learningSpacesRetryable.retry();
        },
      );
    } else {
      return const DelayedLoadingIndicator(name: "Learning Spaces");
    }
  }

  Widget _choices(List<dynamic> items, Set<String> selectedItems) {
    return SizedBox(
        height: 40,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                  child: FilterChip(
                    label: Text(
                      item.toString(),
                    ),
                    selected: selectedItems.contains(item.id),
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          selectedItems.add(item.id);
                        } else {
                          selectedItems.remove(item.id);
                        }
                      });
                    },
                    checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                  ));
            }));
  }
}

class RoomCard extends StatelessWidget {
  final Room room;
  final double? occupationPercentage;

  const RoomCard({required this.room, this.occupationPercentage, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      child: InkWell(
          onTap: () {
            _showDetailsBottomSheet(context);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: CachedNetworkImage(
                      imageUrl: "https://lernraeume.stuvus.uni-stuttgart.de/${room.thumbnail!}",
                      fit: BoxFit.cover,
                      height: 140,
                      width: double.infinity,
                      progressIndicatorBuilder: (context, url, loadingProgress) {
                        return const Center(
                            child: Padding(padding: EdgeInsets.all(25), child: CircularProgressIndicator()));
                      })),
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            room.name,
                            style: Theme.of(context).textTheme.titleLarge,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 1)),
                          Expanded(
                              child: Text(
                            room.address,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          )),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${room.seats} Seats", maxLines: 1, style: Theme.of(context).textTheme.bodyLarge),
                                if (occupationPercentage != null)
                                  Text("~${occupationPercentage!.toStringAsFixed(0)}%",
                                      maxLines: 1, style: Theme.of(context).textTheme.bodyLarge),
                              ])
                        ])),
              )
            ],
          )),
    );
  }

  void _showDetailsBottomSheet(BuildContext context) {
    /*showModalBottomSheet(
        isScrollControlled: true,
        useSafeArea: true,
        isDismissible: true,
        context: context,
        builder: (context) => MealBottomSheet(meal: meal, stars: stars, date: date, onStarsUpdate: onStarsUpdate));
        */
  }
}
