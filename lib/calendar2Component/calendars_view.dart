import 'package:campus_flutter/base/helpers/delayed_loading_indicator.dart';
import 'package:campus_flutter/base/views/error_handling_view.dart';
import 'package:campus_flutter/calendar2Component/calendar_datasource.dart';
import 'package:campus_flutter/courseComponent/course_view.dart';
import 'package:campus_flutter/lectureComponent/views/lecture_details_view.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../base/networking/apis/campUSApi/campus_api.dart';
import '../calendarComponent/model/calendar_data_source.dart';
import '../providers_get_it.dart';

class CalendarsView extends StatefulWidget {
  const CalendarsView({super.key});

  @override
  State<CalendarsView> createState() => _CalendarsViewState();
}

enum CalendarType { day, week, month }

class _CalendarsViewState extends State<CalendarsView> {
  CalendarType _selectedCalendarTab = CalendarType.day;

  final CalendarController _calendarController = CalendarController();
  late final CampusCalendarDatasource _calendarDatasource;

  @override
  void initState() {
    super.initState();
    final api = getIt<CampusApi>();
    _calendarDatasource = CampusCalendarDatasource(api, context);
  }

  @override
  Widget build(BuildContext context) {
    Widget calendar;

    Widget loadMoreWidgetBuilder(BuildContext context, LoadMoreCallback loadMoreAppointments) {
      return FutureBuilder<void>(
        future: loadMoreAppointments(),
        builder: (context, snapShot) {
          return Container(
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.center,
              child: const CircularProgressIndicator());
        },
      );
    }

    void onEventTap(CalendarTapDetails details) {
      if (details.targetElement == CalendarElement.appointment && details.appointments!.isNotEmpty) {
        final calendarEvent = details.appointments!.first as CalendarEvent;
        if (calendarEvent.courseId != null) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CourseView(courseId: calendarEvent.courseId!, selectedDate: calendarEvent.startDate),
          ));
        } else {
          showModalBottomSheet(
              isScrollControlled: true,
              useSafeArea: true,
              showDragHandle: true,
              isDismissible: true,
              context: context,
              builder: (context) {
                return DraggableScrollableSheet(
                    initialChildSize: 0.5,
                    minChildSize: 0.5,
                    builder: (context, scrollController) {
                      return Column(children: [
                        Text(calendarEvent.summary),
                        Text(calendarEvent.startDate.toString())
                      ]);
                    });
              });
        }
      }
    }

    switch (_selectedCalendarTab) {
      case CalendarType.day:
        calendar = SfCalendar(
          key: const ValueKey("day"),
          controller: _calendarController,
          showDatePickerButton: true,
          view: CalendarView.day,
          dataSource: _calendarDatasource,
          onTap: onEventTap,
          headerDateFormat: "EEEE, dd.MM.yyyy",
          showNavigationArrow: true,
          timeSlotViewSettings: const TimeSlotViewSettings(startHour: 7, endHour: 22, timeFormat: "Hm"),
          loadMoreWidgetBuilder: loadMoreWidgetBuilder,
        );
        break;
      case CalendarType.week:
        calendar = SfCalendar(
          key: const ValueKey("week"),
          //controller: _calendarController,
          view: CalendarView.week,
          dataSource: _calendarDatasource,
          onTap: onEventTap,
          firstDayOfWeek: 1,
          showDatePickerButton: true,
          headerDateFormat: "",
          showWeekNumber: true,
          showNavigationArrow: true,
          loadMoreWidgetBuilder: loadMoreWidgetBuilder,
        );
        break;
      case CalendarType.month:
        calendar = SfCalendar(
          key: const ValueKey("month"),
          //controller: _calendarController,
          view: CalendarView.month,
          monthViewSettings:
          const MonthViewSettings(showAgenda: true, navigationDirection: MonthNavigationDirection.vertical),
          dataSource: _calendarDatasource,
          firstDayOfWeek: 1,
          showDatePickerButton: true,
          showNavigationArrow: true,
          onTap: onEventTap,
          loadMoreWidgetBuilder: loadMoreWidgetBuilder,
        );
        break;
    }

    return Column(children: [
      Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCalendarTab = CalendarType.day;
                      _calendarController.displayDate = DateTime.now();
                    });
                  },
                  child: Text("Today", style: Theme
                      .of(context)
                      .textTheme
                      .titleMedium)),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0)),
              Expanded(
                  child: SegmentedButton<CalendarType>(
                    segments: const <ButtonSegment<CalendarType>>[
                      ButtonSegment<CalendarType>(
                          value: CalendarType.day, label: Text('Day'), icon: Icon(Icons.calendar_view_day)),
                      ButtonSegment<CalendarType>(
                          value: CalendarType.week, label: Text('Week'), icon: Icon(Icons.calendar_view_week)),
                      ButtonSegment<CalendarType>(
                          value: CalendarType.month, label: Text('Month'), icon: Icon(Icons.calendar_view_month)),
                    ],
                    selected: <CalendarType>{_selectedCalendarTab},
                    onSelectionChanged: (Set<CalendarType> newSelection) {
                      setState(() {
                        _selectedCalendarTab = newSelection.first;
                      });
                    },
                  ))
            ],
          )),
      Expanded(child: calendar)
    ]);
  }
}