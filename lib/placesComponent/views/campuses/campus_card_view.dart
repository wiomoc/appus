import 'package:campus_flutter/base/enums/campus.dart';
import 'package:campus_flutter/mapComponent/views/room_location_page.dart';
import 'package:flutter/material.dart';

class CampusCardView extends StatelessWidget {
  const CampusCardView({super.key, required this.campus});

  final Campus campus;

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: AspectRatio(
            aspectRatio: 1.75,
            child: Card(
                child: Column(
              children: [
                Expanded(
                    flex: 2,
                    child: SizedBox.expand(
                        child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                            child: Stack(children: [
                              Positioned.fill(
                                  child: Image.asset(
                                campus.image ?? "",
                                fit: BoxFit.cover,
                              )),
                              Positioned(
                                  bottom: 10,
                                  left: 10,
                                  child: Text(
                                    campus.name,
                                    style:
                                        Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, shadows: [
                                      const Shadow(color: Colors.black, blurRadius: 10.0, offset: Offset(0, 5)),
                                      const Shadow(color: Colors.black, blurRadius: 10.0),
                                      const Shadow(color: Colors.black, blurRadius: 10.0, offset: Offset(0, -5))
                                    ]),
                                  ))
                            ])))),
                for (var popularRoom in campus.popularRooms)
                  ListTile(
                    title: Text(
                      popularRoom.$1,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    leading: const Icon(
                      Icons.school,
                      size: 16,
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoomLocationPage(roomId: popularRoom.$2))),
                  )
              ],
            ))));
  }
}
