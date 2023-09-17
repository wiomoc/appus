import 'package:flutter/material.dart';

import '../model/learning_spaces.dart';
import 'room_card.dart';

class LearningSpacesView extends StatefulWidget {
  final LearningSpaces learningSpaces;
  final Map<String, double>? occupations;

  const LearningSpacesView({super.key, required this.learningSpaces, this.occupations});

  @override
  LearningSpacesViewState createState() {
    return LearningSpacesViewState();
  }
}

class LearningSpacesViewState extends State<LearningSpacesView> {
  late Set<String> _selectedCampuses;
  late Set<String> _selectedTypes;
  late Set<String> _selectedAccessGroups;

  @override
  void initState() {
    super.initState();

    _selectedCampuses = widget.learningSpaces.locations.map((campus) => campus.id).toSet();
    _selectedTypes = widget.learningSpaces.types.map((type) => type.id).toSet();
    _selectedAccessGroups = {"all"};
  }

  @override
  Widget build(BuildContext context) {
    final learningSpaces = widget.learningSpaces;
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
                    occupationPercentage: room.tikName != null ? (widget.occupations?[room.tikName!]) : null,
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
