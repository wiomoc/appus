import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

import '../model/room_location.dart';

class MapView extends StatefulWidget {
  final Building building;

  const MapView(this.building, {super.key});

  @override
  State<StatefulWidget> createState() {
    return MapState();
  }
}

class MapState extends State<MapView> {
  late MapController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MapController.customLayer(
        initPosition: _coord3857To4326(widget.building.coordinates!),
        customTile: CustomTile(
            sourceName: "osm",
            urlsServers: [TileURLs(url: "https://tile.openstreetmap.org/")],
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
            [_coord3857To4326(widget.building.coordinates!)])
      ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

GeoPoint _coord3857To4326(List<double> coords) {
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