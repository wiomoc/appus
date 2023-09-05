import 'dart:async';
import 'dart:math';

import 'package:campus_flutter/mapComponent/map_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:zoom_widget/zoom_widget.dart';

import '../base/helpers/delayed_loading_indicator.dart';
import '../base/helpers/retryable.dart';
import '../base/views/error_handling_view.dart';
import '../courseComponent/basic_course_info_row_view.dart';
import 'models.dart';

class FloorPlanView extends StatefulWidget {
  final Floor floor;
  final int? focusedRoom;

  const FloorPlanView(this.floor, {this.focusedRoom, super.key});

  @override
  LayerPlanState createState() {
    return LayerPlanState();
  }
}

class LayerPlanState extends State<FloorPlanView> {
  double _markerScale = 1;
  late ImageStream _imageStream;
  late ImageStreamListener _imageListener;
  ImageInfo? _imageInfo;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    if (widget.floor.planImageUrl == null) {
      return const Center(child: Text("Kein Plan vorhanden"));
    }
    return Container(
        child: Image.network(
      widget.floor.planImageUrl!,
      fit: BoxFit.fitWidth,
      excludeFromSemantics: true,
      loadingBuilder: (context, child, loadingProgress) =>
          loadingProgress != null ? const DelayedLoadingIndicator(name: "Flurplan") : child,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        final markers = widget.floor.rooms
            .map((room) => Positioned(
                left: room.position[0].toDouble() - (12.5 * _markerScale),
                top: room.position[1].toDouble() - (12.5 * _markerScale),
                child: CircleAvatar(
                    backgroundColor: ((widget.focusedRoom != null && room.id == widget.focusedRoom)
                            ? Colors.redAccent
                            : Colors.lightBlue)
                        .withOpacity(0.8),
                    radius: 25 * _markerScale,
                    child: Text(
                      room.number,
                      style: TextStyle(color: Colors.white, fontSize: 12 * _markerScale),
                    ))))
            .toList();

        return Zoom(
            initTotalZoomOut: true,
            centerOnScale: true,
            onScaleUpdate: (scale, zoom) {
              setState(() {
                _markerScale = max(2 - zoom, 0.8);
              });
            },
            child: Stack(
              children: [child, ...markers],
            ));
      },
    ));
  }

  @override
  void dispose() {
    super.dispose();
    _imageStream.removeListener(_imageListener);
    _imageInfo?.dispose();
    _imageInfo = null;
  }
}

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

class MapWidget extends StatefulWidget {
  final Building building;

  const MapWidget(this.building, {super.key});

  @override
  State<StatefulWidget> createState() {
    return MapState();
  }
}

GeoPoint coord3857To4326(List<double> coords) {
  const X = 20037508.34;

  final lat3857 = coords[1];
  final long3857 = coords[0];

  //converting the longitute from epsg 3857 to 4326
  final long4326 = (long3857 * 180) / X;

  //converting the latitude from epsg 3857 to 4326 split in multiple lines for readability
  var lat4326 = lat3857 / (X / 180);
  final exponent = (pi / 180) * lat4326;

  lat4326 = atan(exp(exponent));
  lat4326 = lat4326 / (pi / 360); // Here is the fixed line
  lat4326 = lat4326 - 90;

  return GeoPoint(latitude: lat4326, longitude: long4326);
}

class MapState extends State<MapWidget> {
  late MapController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MapController.customLayer(
        initPosition: coord3857To4326(widget.building.coordinates!),
        customTile: CustomTile(
            sourceName: "lageplan",
            urlsServers: [TileURLs(url: "https://lageplan.uni-stuttgart.de/osm_tiles/")],
            maxZoomLevel: 19,
            minZoomLevel: 12,
            tileExtension: ".png"));
  }

  @override
  Widget build(BuildContext context) {
    return OSMFlutter(
      controller: _controller,
      osmOption:
          OSMOption(zoomOption: const ZoomOption(initZoom: 16, maxZoomLevel: 19, minZoomLevel: 12), staticPoints: [
        StaticPositionGeoPoint(
            "1",
            MarkerIcon(
              icon: Icon(Icons.my_location, color: Colors.redAccent.withOpacity(0.9), size: 56),
            ),
            [coord3857To4326(widget.building.coordinates!)])
      ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

class MapPageView extends StatefulWidget {
  final int roomId;

  const MapPageView({super.key, this.roomId = 7054});

  @override
  MapPageState createState() {
    return MapPageState();
  }
}

class MapPageState extends State<MapPageView> with TickerProviderStateMixin {
  late Retryable<RoomLocation> _roomLocationRetryable;
  bool showFloorPlan = true;

  @override
  void initState() {
    _roomLocationRetryable = Retryable(() => MapService().fetchRoomLocation(widget.roomId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return DefaultTabController(
        initialIndex: 0,
        length: 3,
        child: StreamBuilder(
          stream: _roomLocationRetryable.stream,
          builder: (context, snapshot) {
            Widget body;
            Widget? bottomSheet;
            Widget? floatingActionButton;
            if (snapshot.hasData) {
              final roomLocation = snapshot.data!;
              if (roomLocation.floor.planImageUrl == null) {
                showFloorPlan = false;
              } else {
                floatingActionButton = FloatingActionButton.small(
                  onPressed: () {
                    setState(() {
                      showFloorPlan = !showFloorPlan;
                    });
                  },
                  child: Icon(showFloorPlan ? Icons.map_outlined : Icons.layers_outlined),
                );
              }

              body = showFloorPlan
                  ? FloorPlanView(roomLocation.floor, focusedRoom: roomLocation.room.id)
                  : MapWidget(roomLocation.building);

              bottomSheet = DraggableScrollableSheet(
                  minChildSize: 50 / screenHeight,
                  maxChildSize: 200 / screenHeight,
                  initialChildSize: 120 / screenHeight,
                  expand: false,
                  builder: (context, scrollController) => SingleChildScrollView(
                      controller: scrollController,
                      physics: ClampingScrollPhysics(),
                      child: RoomInformationView(roomLocation)));
            } else if (snapshot.hasError) {
              body = ErrorHandlingView(
                error: snapshot.error!,
                errorHandlingViewType: ErrorHandlingViewType.fullScreen,
                retry: (force) {
                  _roomLocationRetryable.retry();
                },
              );
            } else {
              body = const DelayedLoadingIndicator(name: "Room");
            }

            return Scaffold(
              appBar: AppBar(
                leading: const BackButton(),
                title: Text(snapshot.hasData ? snapshot.data!.room.number : "Map"),
              ),
              body: body,
              floatingActionButton: floatingActionButton,
              floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
              bottomSheet: bottomSheet,
            );
          },
        ));
  }
}
