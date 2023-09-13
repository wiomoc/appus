import 'package:campus_flutter/calendarComponent/api/my_events.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../base/extensions/cast.dart';
import 'model/calendar_event.dart';

class CampusCalendarDatasource extends CalendarDataSource {
  final BuildContext context;
  final Set<DateTime> loadedWeeks = {};

  CampusCalendarDatasource(this.context) {
    appointments = [];
  }

  @override
  DateTime getStartTime(int index) {
    return cast<CalendarEvent>(appointments![index])!.startDate;
  }

  @override
  DateTime getEndTime(int index) {
    return cast<CalendarEvent>(appointments![index])!.endDate;
  }

  @override
  String getSubject(int index) {
    return cast<CalendarEvent>(appointments![index])!.summary;
  }

  @override
  Object getId(int index) {
    return cast<CalendarEvent>(appointments![index])!.id;
  }

  @override
  Color getColor(int index) {
    return Theme.of(context).primaryColor;
  }

  @override
  Future<void> handleLoadMore(DateTime startDate, DateTime endDate) async {
    final startWeek = _startOfWeek(startDate);
    print("Loading more events for week $startWeek");
    bool notified = false;
    for (DateTime week = startWeek; week.isBefore(endDate); week = week.add(const Duration(days: 7))) {
      if (loadedWeeks.add(week)) {
        final events = await MyEventsApiOperation(week, week.add(const Duration(days: 7))).fetchOnline();
        appointments!.addAll(events);
        notifyListeners(CalendarDataSourceAction.add, events);
        notified = true;
      }
    }
    if (!notified) {
      notifyListeners(CalendarDataSourceAction.add, []);
    }
  }
}

DateTime _startOfWeek(DateTime date) {
  return date
      .subtract(Duration(days: date.weekday - 1))
      .copyWith(hour: 0, minute: 0, second: 0, microsecond: 0, millisecond: 0);
}
