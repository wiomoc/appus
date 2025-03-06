import 'dart:math';

import 'package:flutter/material.dart';
import 'package:campus_flutter/base/l10n/generated/app_localizations.dart';

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
  late final TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _transformationController.addListener(() {
      setState(() {
        _markerScale = max(_transformationController.value.getMaxScaleOnAxis() / 2, 0.8);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.floor.planImageUrl == null) {
      return Center(child: Text(AppLocalizations.of(context)!.mapFloorPlanUnavailable));
    }
    Size size = MediaQuery.of(context).size;
    size = Size(size.width, size.height - 140);
    return Image.network(
      widget.floor.planImageUrl!,
      fit: BoxFit.contain,
      width: size.width,
      height: size.height,
      excludeFromSemantics: true,
      loadingBuilder: (context, child, loadingProgress) =>
          loadingProgress != null ? DelayedLoadingIndicator(name: AppLocalizations.of(context)!.mapFloorPlan) : child,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        final image = (child as RawImage).image;
        final imageWidth = image?.width ?? size.width;
        final imageHeight = image?.height ?? size.height;
        double widthOffset = (size.width - imageWidth) / 2;
        double heightOffset = (size.height - imageHeight) / 2;
        double scale = 1;
        if (widthOffset < 0 || heightOffset < 0) {
          scale = min(size.width / imageWidth, size.height / imageHeight);
          if (widthOffset < 0) {
            widthOffset = 0;
            heightOffset = (size.height - size.width * (imageHeight / imageWidth)) / 2;
          }
          if (heightOffset < 0) {
            heightOffset = 0;
            widthOffset = (size.width - size.height * (imageWidth / imageHeight)) / 2;
          }
        }

        final markers = widget.floor.rooms
            .map((room) => Positioned(
                left: (room.position[0].toDouble() - (12.5 * _markerScale)) * scale + widthOffset,
                top: (room.position[1].toDouble() - (12.5 * _markerScale)) * scale + heightOffset,
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

        return InteractiveViewer(
            transformationController: _transformationController,
            child: Stack(
              children: [child, ...markers],
            ));
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _transformationController.dispose();
  }
}
