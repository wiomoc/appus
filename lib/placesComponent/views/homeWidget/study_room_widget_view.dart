import 'package:campus_flutter/base/helpers/card_with_padding.dart';
import 'package:campus_flutter/base/helpers/delayed_loading_indicator.dart';
import 'package:campus_flutter/base/views/error_handling_view.dart';
import 'package:campus_flutter/homeComponent/widgetComponent/views/widget_frame_view.dart';
import 'package:campus_flutter/providers_get_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/*
class StudyRoomWidgetView extends ConsumerStatefulWidget {
  factory StudyRoomWidgetView(StudyRoomGroup? studyRoomGroup) {
    if (studyRoomGroup == null) {
      return const StudyRoomWidgetView.closest();
    } else {
      return StudyRoomWidgetView.group(
        studyRoomGroup: studyRoomGroup,
      );
    }
  }

  const StudyRoomWidgetView.closest(
      {super.key, this.studyRoomGroup, this.closestStudyRoom = true});

  const StudyRoomWidgetView.group(
      {super.key, required this.studyRoomGroup, this.closestStudyRoom = false});

  final StudyRoomGroup? studyRoomGroup;
  final bool closestStudyRoom;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StudyRoomWidgetViewState();
}

class _StudyRoomWidgetViewState extends ConsumerState<StudyRoomWidgetView> {
  @override
  void initState() {
    if (widget.closestStudyRoom) {
      ref.read(studyRoomsViewModel).fetchClosestStudyRoom(false);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.closestStudyRoom) {
      return WidgetFrameView(
        title: "Closest Study Rooms",
        child: _streamBuilder(context),
      );
    } else {
      return _streamBuilder(context);
    }
  }

  Widget _streamBuilder(BuildContext context) {
    return StreamBuilder(
        stream: widget.closestStudyRoom
            ? ref.watch(studyRoomsViewModel).closestStudyRoom
            : ref.watch(studyRoomsViewModel).studyRooms,
        builder: (context, snapshot) {
          return GestureDetector(
              onTap: () {
                if (snapshot.hasData && snapshot.data != null) {
                  _onPressed(
                      widget.closestStudyRoom
                          ? snapshot.data! as StudyRoomGroup
                          : widget.studyRoomGroup!,
                      context);
                }
              },
              child: CardWithPadding(
                  height: MediaQuery.sizeOf(context).height * 0.075,
                  child: _widgetLabel(snapshot, context)));
        });
  }

  Widget _widgetLabel(AsyncSnapshot snapshot, BuildContext context) {
    if (snapshot.hasData) {
      if (snapshot.data != null) {
        return _buttonLabel(
            widget.closestStudyRoom
                ? snapshot.data! as StudyRoomGroup
                : ref
                    .read(studyRoomsViewModel)
                    .studyRoomData!
                    .groups!
                    .firstWhere(
                        (element) => element.id == widget.studyRoomGroup!.id),
            context);
      } else {
        return const Center(child: Text("no study rooms near you found"));
      }
    } else if (snapshot.hasError) {
      return ErrorHandlingView(
          error: snapshot.error!,
          errorHandlingViewType: ErrorHandlingViewType.descriptionOnly);
    } else {
      return const DelayedLoadingIndicator(name: "Closest Study Room");
    }
  }

  _onPressed(StudyRoomGroup studyRoomGroup, BuildContext context) async {
    if (MediaQuery.orientationOf(context) == Orientation.portrait) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => StudyRoomGroupScaffold(studyRoomGroup)));
    } else {
      ref
          .read(homeSplitViewModel)
          .selectedWidget
          .add(StudyRoomGroupView(studyRoomGroup));
    }
  }

  Widget _buttonLabel(StudyRoomGroup studyRoomGroup, BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(studyRoomGroup.name ?? "Unknown")),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 5.0)),
        _freeRooms(studyRoomGroup),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 5.0)),
        const Icon(Icons.arrow_forward_ios, size: 15)
      ],
    );
  }

  Widget _freeRooms(StudyRoomGroup studyRoomGroup) {
    final freeRooms = ref.read(studyRoomsViewModel).freeRooms(studyRoomGroup);
    return Text("$freeRooms room${freeRooms > 1 ? "s" : ""} free",
        style: TextStyle(color: freeRooms > 0 ? Colors.green : Colors.red));
  }
}
*/