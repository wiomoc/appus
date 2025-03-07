import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../base/views/child_sized_draggable_scrollable_sheet.dart';
import '../../mapComponent/views/room_location_page.dart';
import '../api/stuvus_learning_spaces.dart';
import '../model/learning_spaces.dart';

class RoomBottomSheet extends StatelessWidget {
  final Room room;
  final List<String> tags;

  const RoomBottomSheet({super.key, required this.room, required this.tags});

  @override
  Widget build(BuildContext context) {
    final imageUrl = room.images?.firstOrNull;
    final roomId = room.raumKey;
    return ChildSizedDraggableScrollableSheet(builder: (context) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        if (imageUrl != null)
          SizedBox(
              height: 350,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: CachedNetworkImage(
                    imageUrl: expandImageUrl(imageUrl),
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (context, url, loadingProgress) {
                      return const Center(
                          child: Padding(padding: EdgeInsets.all(25), child: CircularProgressIndicator()));
                    },
                  )))
        else
          const Padding(padding: EdgeInsets.all(4)),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        child: Text(room.name, style: Theme.of(context).textTheme.titleMedium)),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), child: Text(room.address)),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        child: Text(room.open.map((times) => "${times.days}: ${times.hours}").join("\n"))),
                  ]),
                  if (roomId != null)
                    Transform.translate(
                        offset: const Offset(0, -20),
                        child: FloatingActionButton.small(
                            onPressed: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) => RoomLocationPage(roomId: roomId)));
                            },
                            child: const Icon(Icons.map_outlined)))
                ])),
        SizedBox(
            height: 60,
            child: ListView(
                scrollDirection: Axis.horizontal,
                children: tags
                    .map((tag) =>
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Chip(label: Text(tag))))
                    .toList())),
      ]);
    });
  }
}
