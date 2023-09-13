import 'dart:math';

import 'package:campus_flutter/mapComponent/views/map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:zoom_widget/zoom_widget.dart';

import '../base/helpers/api_backed_state.dart';
import '../base/helpers/delayed_loading_indicator.dart';
import '../courseComponent/basic_course_info_row_view.dart';
import 'api/building_location_api.dart';
import 'api/room_location_api.dart';
import 'model/room_location.dart';
import 'views/floor_plan_view.dart';
import 'views/room_information_view.dart';

class BuildingLocationPage extends StatefulWidget {
  final int aref;

  const BuildingLocationPage({super.key, required this.aref});

  @override
  RoomLocationPageState createState() {
    return RoomLocationPageState();
  }
}

class RoomLocationPageState extends ApiBackedState<Building, BuildingLocationPage>
    with TickerProviderStateMixin, ApiBackedPageState<Building, BuildingLocationPage> {
  bool showFloorPlan = true;

  @override
  void initState() {
    load(BuildingLocationApiOperation(widget.aref), const Duration(hours: 6));
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
          bottomSheet: data != null
              ? DraggableScrollableSheet(
                  minChildSize: 50 / screenHeight,
                  maxChildSize: 100 / screenHeight,
                  initialChildSize: 80 / screenHeight,
                  expand: false,
                  builder: (context, scrollController) => SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: BasicCourseInfoRowView(
                            iconData: Icons.location_city_outlined,
                            information: "${data!.street}\n${data!.city}",
                          ))))
              : null,
        ));
  }

  @override
  Widget buildAppBarTitle(Building data) {
    return Text(data.street);
  }

  @override
  Widget buildBody(Building data) => MapView(data);

  @override
  String get resourceName => "Building";
}
