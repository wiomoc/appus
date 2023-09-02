import 'dart:math';

import 'package:campus_flutter/base/helpers/retryable.dart';
import 'package:campus_flutter/base/helpers/url_launcher.dart';
import 'package:campus_flutter/base/networking/apis/campUSApi/campus_api.dart';
import 'package:campus_flutter/mapComponent/map_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../base/helpers/card_with_padding.dart';
import '../base/helpers/delayed_loading_indicator.dart';
import '../base/helpers/horizontal_slider.dart';
import '../base/helpers/icon_text.dart';
import '../base/views/error_handling_view.dart';
import '../providers_get_it.dart';
import 'basic_course_info_view.dart';
import 'detailed_course_info_view.dart';

class CourseAppointmentsView extends StatefulWidget {
  final List<Appointment> appointments;
  final DateTime? selectedDate;

  const CourseAppointmentsView(this.appointments, {this.selectedDate, super.key});

  @override
  CourseAppointsmentsState createState() {
    return CourseAppointsmentsState();
  }
}

class CourseAppointsmentsState extends State<CourseAppointmentsView> {
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
                      Text("CANCELED", style: Theme.of(context).textTheme.bodyMedium),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat("E. d").format(appointment.startDate),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(DateFormat.yMMM().format(appointment.startDate),
                            style: Theme.of(context).textTheme.bodyLarge),
                        Text(
                            "${DateFormat.Hm().format(appointment.startDate)} - ${DateFormat.Hm().format(appointment.endDate)}",
                            style: Theme.of(context).textTheme.bodyLarge),
                        if (appointment.roomId != null && appointment.status != CalendarEventStatus.canceled) ...[
                          const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => MapPageView(roomId: appointment.roomId!),
                              ));
                            },
                            child: Text(
                              appointment.cleanRoomName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.dotted),
                            ),
                          )
                        ]
                      ],
                    ),
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

class CourseView extends StatefulWidget {
  final int courseId;
  final DateTime? selectedDate;

  const CourseView({required this.courseId, this.selectedDate, super.key});

  @override
  CourseState createState() {
    return CourseState();
  }
}

class CourseState extends State<CourseView> {
  late Retryable<(CourseDetail, CourseGroupDetail)> _courseRetryable;

  @override
  void initState() {
    super.initState();

    _courseRetryable = Retryable(() async {
      final api = getIt<CampusApi>();

      return (await api.course(widget.courseId), await api.courseGroup(widget.courseId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return StreamBuilder(
      stream: _courseRetryable.stream,
      builder: (context, snapshot) {
        Widget body;

        if (snapshot.hasData) {
          final courseDetails = snapshot.data!.$1;
          final courseGroupDetails = snapshot.data!.$2;
          body = ListView(children: [
            _infoCard(Icons.info_outline_rounded, "Basic Lecture Information",
                BasicCourseInfoView(courseDetails: courseDetails, lecturerNames: courseGroupDetails.lecturerNames)),
            if (courseGroupDetails.appointments.isNotEmpty)
              CourseAppointmentsView(courseGroupDetails.appointments, selectedDate: widget.selectedDate),
            if (courseDetails.localizedCourseContent != null || courseDetails.localizedCourseObjective != null)
              _infoCard(
                  Icons.folder, "Detailed Lecture Information", DetailedCourseInfoView(courseDetails: courseDetails)),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text("Ilias"),
              trailing: const Icon(Icons.arrow_forward_outlined),
              onTap: () {
                UrlLauncher.urlString("https://ilias3.uni-stuttgart.de/ecsredi.php?cmsid=${courseDetails.id}");
              },
            )
          ]);
        } else if (snapshot.hasError) {
          body = ErrorHandlingView(
            error: snapshot.error!,
            errorHandlingViewType: ErrorHandlingViewType.fullScreen,
            retry: (force) {
              _courseRetryable.retry();
            },
          );
        } else {
          body = const DelayedLoadingIndicator(name: "Course");
        }

        return Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: Text(snapshot.hasData ? snapshot.data!.$1.localizedTitle : "Course"),
          ),
          body: body,
        );
      },
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
}
