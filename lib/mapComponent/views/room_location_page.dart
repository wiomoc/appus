import 'package:campus_flutter/mapComponent/views/map_view.dart';
import 'package:flutter/material.dart';
import 'package:campus_flutter/base/l10n/generated/app_localizations.dart';

import '../../base/helpers/api_backed_state.dart';
import '../../base/views/child_sized_draggable_scrollable_sheet.dart';
import '../api/room_location_api.dart';
import '../model/room_location.dart';
import 'floor_plan_view.dart';
import 'room_information_view.dart';

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
              ? ChildSizedDraggableScrollableSheet(
                  hiddenHeight: 20,
                  builder: (context) =>
                      RoomInformationView(data!))
              : null,
        ));
  }

  @override
  Widget buildAppBarTitle(RoomLocation data) {
    return Text(data.room.number);
  }

  @override
  Widget buildBody(RoomLocation data) {
    return showFloorPlan && data.floor.planImageUrl != null
        ? FloorPlanView(data.floor, focusedRoom: data.room.id)
        : MapView(data.building);
  }

  @override
  String get resourceName => AppLocalizations.of(context)!.mapRoom;
}
