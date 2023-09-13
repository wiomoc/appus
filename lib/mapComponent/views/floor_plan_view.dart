import 'dart:math';

import 'package:flutter/material.dart';
import 'package:zoom_widget/zoom_widget.dart';

import '../../base/helpers/delayed_loading_indicator.dart';
import '../model/room_location.dart';

class FloorPlanView extends StatefulWidget {
  final Floor floor;
  final int? focusedRoom;

  const FloorPlanView(this.floor, {this.focusedRoom, super.key});

  @override
  State<FloorPlanView> createState() {
    return _FloorPlanViewState();
  }
}

class _FloorPlanViewState extends State<FloorPlanView> {
  double _markerScale = 1;

  @override
  Widget build(BuildContext context) {
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
}