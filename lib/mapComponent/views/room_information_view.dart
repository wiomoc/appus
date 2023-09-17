import 'package:flutter/material.dart';

import '../../courseComponent/views/basic_course_info_row_view.dart';
import '../model/room_location.dart';

class RoomInformationView extends StatelessWidget {
  final RoomLocation roomLocation;

  const RoomInformationView(this.roomLocation, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          BasicCourseInfoRowView(
            iconData: Icons.numbers_outlined,
            information: roomLocation.room.number,
          ),
          BasicCourseInfoRowView(
            iconData: Icons.layers_outlined,
            information: roomLocation.floor.name,
          ),
          BasicCourseInfoRowView(
            iconData: Icons.location_city_outlined,
            information: "${roomLocation.building.street}\n${roomLocation.building.city}",
          ),
          const Divider(),
          if (roomLocation.room.seats != null) ...[
            BasicCourseInfoRowView(
              iconData: Icons.event_seat_outlined,
              information: roomLocation.room.seats!.toString(),
            ),
          ],
          if (roomLocation.room.usage != null) ...[
            BasicCourseInfoRowView(
              iconData: Icons.room_preferences_outlined,
              information: roomLocation.room.usage!,
            )
          ]
        ]));
  }
}