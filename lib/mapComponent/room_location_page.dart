import 'dart:math';

import 'package:campus_flutter/mapComponent/views/map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:zoom_widget/zoom_widget.dart';

import '../base/helpers/api_backed_state.dart';
import '../base/helpers/delayed_loading_indicator.dart';
import '../courseComponent/basic_course_info_row_view.dart';
import 'api/room_location_api.dart';
import 'model/room_location.dart';
import 'views/floor_plan_view.dart';
import 'views/room_information_view.dart';


class RoomLocationPage extends StatefulWidget {
  final int roomId;

  const RoomLocationPage({super.key, required this.roomId});

  @override
  RoomLocationPageState createState() {
    return RoomLocationPageState();
  }
}

class RoomLocationPageState extends ApiBackedState<RoomLocation, RoomLocationPage>
    with TickerProviderStateMixin, ApiBackedPageState<RoomLocation, RoomLocationPage> {
  bool showFloorPlan = true;

  @override
  void initState() {
    load(RoomLocationApiOperation(widget.roomId), const Duration(hours: 6));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
          appBar: appBar(),
          body: body(),
          floatingActionButton: data != null && data!.floor.planImageUrl != null
              ? FloatingActionButton.small(
                  onPressed: () {
                    setState(() {
                      showFloorPlan = !showFloorPlan;
                    });
                  },
                  child: Icon(showFloorPlan ? Icons.map_outlined : Icons.layers_outlined),
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          bottomSheet: data != null
              ? DraggableScrollableSheet(
                  minChildSize: 50 / screenHeight,
                  maxChildSize: 200 / screenHeight,
                  initialChildSize: 120 / screenHeight,
                  expand: false,
                  builder: (context, scrollController) =>
                      SingleChildScrollView(controller: scrollController, child: RoomInformationView(data!)))
              : null,
        ));
  }

  @override
  Widget buildAppBarTitle(RoomLocation data) {
    return Text(data.room.number);
  }

  @override
  Widget buildBody(RoomLocation roomLocation) {
    return showFloorPlan && roomLocation.floor.planImageUrl != null
        ? FloorPlanView(roomLocation.floor, focusedRoom: roomLocation.room.id)
        : MapView(roomLocation.building);
  }

  @override
  String get resourceName => "Room";
}