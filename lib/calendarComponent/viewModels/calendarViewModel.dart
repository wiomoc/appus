
import 'package:campus_flutter/calendarComponent/model/calendarEvent.dart';
import 'package:campus_flutter/calendarComponent/services/calendarService.dart';
import 'package:rxdart/rxdart.dart';

class CalendarViewModel {
  BehaviorSubject<List<CalendarEvent>?> events = BehaviorSubject.seeded(null);
  BehaviorSubject<(List<CalendarEvent>, List<CalendarEvent>)?> widgetEvents = BehaviorSubject.seeded(null);

  fetchEvents() async {
    final events = await CalendarService.fetchCalendar();
    this.events.add(events);
  }

  (CalendarEvent?, List<CalendarEvent>) getWidgetEvents() {
      CalendarEvent? leftColumn;
      List<CalendarEvent> rightColumn = [];

      final filteredEvents = events.value ?? [];
      filteredEvents.removeWhere((element) => element.startDate.isBefore(DateTime.now()));
      filteredEvents.sort((a, b) => a.startDate.compareTo(b.startDate));

      final currentDate = DateTime.now();
      final currentDay = DateTime(currentDate.year, currentDate.month, currentDate.day);

      for (CalendarEvent event in events.value ?? []) {
        final dateToCheck =  DateTime(event.startDate.year, event.startDate.month, event.startDate.day);
        if (dateToCheck == currentDay && leftColumn == null) {
          leftColumn = event;
        } else if (rightColumn.length <= 2 && (rightColumn.firstOrNull == null || rightColumn.first.startDate.isBefore(event.startDate))) {
          rightColumn.add(event);
        } else {
          continue;
        }
      }

      return (leftColumn, rightColumn);
  }
}