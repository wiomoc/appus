import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../api/stuvus_learning_spaces.dart';
import '../model/learning_spaces.dart';

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
          borderRadius: BorderRadius.circular(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: CachedNetworkImage(
                      imageUrl: "$learningSpacesBaseUrl/${room.thumbnail!}",
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
