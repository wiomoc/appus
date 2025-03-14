import 'dart:math';

import 'package:campus_flutter/base/helpers/api_backed_state.dart';
import 'package:campus_flutter/base/helpers/url_launcher.dart';
import 'package:campus_flutter/courseComponent/api/course_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:campus_flutter/base/l10n/generated/app_localizations.dart';

import '../../base/helpers/card_with_padding.dart';
import '../../base/helpers/horizontal_slider.dart';
import '../../base/helpers/icon_text.dart';
import '../../calendarComponent/model/calendar_event.dart';
import '../../mapComponent/views/room_location_page.dart';
import 'basic_course_info_view.dart';
import 'detailed_course_info_view.dart';
import '../model/course_detail.dart';
import '../model/course_group_detail.dart';

class CourseAppointmentsView extends StatefulWidget {
  final List<Appointment> appointments;
  final DateTime? selectedDate;

  const CourseAppointmentsView(this.appointments, {this.selectedDate, super.key});

  @override
  State<CourseAppointmentsView> createState() {
    return _CourseAppointmentsViewState();
  }
}

class _CourseAppointmentsViewState extends State<CourseAppointmentsView> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final selectedDate = widget.selectedDate ?? DateTime.now();
    var upcomingIndex = widget.appointments.indexWhere((appointment) => appointment.endDate.isAfter(selectedDate));
    if (upcomingIndex == -1) upcomingIndex = widget.appointments.length - 1;

    _scrollController = ScrollController(initialScrollOffset: max(upcomingIndex * 206.0 - 10, 0));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return HorizontalSlider(
      data: widget.appointments,
      scrollController: _scrollController,
      height: 155,
      child: (appointment) {
        final color = Theme.of(context).colorScheme.primaryContainer;
        return SizedBox(
            width: 200,
            child: CardWithPadding(
                color: (appointment.endDate.isBefore(now) || appointment.status == CalendarEventStatus.canceled)
                    ? color.withOpacity(0.5)
                    : color,
                margin: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (appointment.status == CalendarEventStatus.canceled)
                      Text("CANCELED",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat("E d").format(appointment.startDate),
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
                        ),
                        Text(DateFormat.yMMM().format(appointment.startDate),
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                        Text(
                            "${DateFormat.Hm().format(appointment.startDate)} - ${DateFormat.Hm().format(appointment.endDate)}",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                        if (appointment.roomId != null && appointment.status != CalendarEventStatus.canceled) ...[
                          const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => RoomLocationPage(roomId: appointment.roomId!),
                              ));
                            },
                            child: Text(
                              appointment.cleanRoomName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  decoration: TextDecoration.underline,
                                  decorationStyle: TextDecorationStyle.dotted),
                            ),
                          )
                        ]
                      ],
                    )),
                  ],
                )));
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }
}

class CoursePage extends StatefulWidget {
  final int courseId;
  final DateTime? selectedDate;

  const CoursePage({required this.courseId, this.selectedDate, super.key});

  @override
  CoursePageState createState() {
    return CoursePageState();
  }
}

class CoursePageState extends ApiBackedState<(CourseDetail, CourseGroupDetail), CoursePage>
    with ApiBackedPageState<(CourseDetail, CourseGroupDetail), CoursePage> {
  @override
  void initState() {
    super.initState();
    load(CourseDetailApiOperation(widget.courseId), const Duration(hours: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: body(),
    );
  }

  Widget _infoCard(IconData icon, String title, Widget child) {
    return CardWithPadding(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IconText(iconData: icon, label: title, style: Theme.of(context).textTheme.titleMedium),
        const Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
        child
      ],
    ));
  }

  @override
  Widget buildAppBarTitle((CourseDetail, CourseGroupDetail) data) {
    return Text(data.$1.localizedTitle);
  }

  @override
  Widget buildBody((CourseDetail, CourseGroupDetail) data) {
    final courseDetails = data.$1;
    final courseGroupDetails = data.$2;
    return ListView(children: [
      _infoCard(Icons.info_outline_rounded, AppLocalizations.of(context)!.courseBasicInformation,
          BasicCourseInfoView(courseDetails: courseDetails, lecturerNames: courseGroupDetails.lecturerNames)),
      if (courseGroupDetails.appointments.isNotEmpty)
        CourseAppointmentsView(courseGroupDetails.appointments, selectedDate: widget.selectedDate),
      if (courseDetails.localizedCourseContent != null || courseDetails.localizedCourseObjective != null)
        _infoCard(Icons.folder, AppLocalizations.of(context)!.courseDetailedInformation,
            DetailedCourseInfoView(courseDetails: courseDetails)),
      ListTile(
        leading: const Icon(Icons.link),
        title: const Text("Ilias"),
        trailing: const Icon(Icons.arrow_forward_outlined),
        onTap: () {
          UrlLauncher.urlString("https://ilias3.uni-stuttgart.de/ecsredi.php?cmsid=${courseDetails.id}");
        },
      )
    ]);
  }

  @override
  String get resourceName => AppLocalizations.of(context)!.coursesCourse;
}
