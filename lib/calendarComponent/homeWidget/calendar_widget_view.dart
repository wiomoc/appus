import 'package:campus_flutter/base/extensions/date_day.dart';
import 'package:campus_flutter/base/helpers/api_backed_state.dart';
import 'package:campus_flutter/base/helpers/card_with_padding.dart';
import 'package:campus_flutter/calendarComponent/api/my_events.dart';
import 'package:campus_flutter/calendarComponent/model/calendar_event.dart';
import 'package:campus_flutter/homeComponent/widgetComponent/views/widget_frame_view.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'calendar_widget_event_view.dart';

class CalendarHomeWidgetView extends StatefulWidget {
  const CalendarHomeWidgetView({super.key});

  @override
  State<CalendarHomeWidgetView> createState() => _CalendarHomeWidgetView();
}

class _CalendarHomeWidgetView extends ApiBackedState<List<CalendarEvent>, CalendarHomeWidgetView> {
  @override
  void initState() {
    final today = DateTime.now().dateDay;
    load(MyEventsApiOperation(today, today.add(const Duration(days: 2))), Duration(minutes: 15));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetFrameView(
        title: "Calendar",
        child: SizedBox(height: MediaQuery.sizeOf(context).height * 0.25, child: CardWithPadding(child: body())));
  }

  @override
  Widget? buildBody(List<CalendarEvent> data) {
    final events = getWidgetEvents(data);
    final today = DateTime.now();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(DateFormat.EEEE().format(today), style: TextStyle(color: Theme.of(context).primaryColor)),
              Text(
                DateFormat(DateFormat.DAY).format(today),
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const Spacer()
            ],
          )),
          Expanded(
              child: (events.$1 != null)
                  ? CalendarHomeWidgetEventView(calendarEvent: events.$1!)
                  : const Center(child: Text("No Events Today")))
        ])),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 5.0)),
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (events.$2.isNotEmpty) Expanded(child: CalendarHomeWidgetEventView(calendarEvent: events.$2.first)),
          if (events.$2.length > 1) Expanded(child: CalendarHomeWidgetEventView(calendarEvent: events.$2[1]))
        ]))
      ],
    );
  }

  @override
  String get resourceName => "Events";

  static (CalendarEvent?, List<CalendarEvent>) getWidgetEvents(List<CalendarEvent> events) {
    CalendarEvent? leftColumn;
    List<CalendarEvent> rightColumn = [];

    final filteredEvents = events
        .where((element) => !element.startDate.isBefore(DateTime.now()))
        .sorted((a, b) => a.startDate.compareTo(b.startDate));

    final currentDay = DateTime.now().dateDay;

    for (CalendarEvent event in filteredEvents) {
      final dateToCheck = event.startDate.dateDay;
      if (dateToCheck == currentDay && leftColumn == null) {
        leftColumn = event;
      } else if (rightColumn.length <= 2 &&
          (rightColumn.firstOrNull == null || rightColumn.first.startDate.isBefore(event.startDate))) {
        rightColumn.add(event);
      } else {
        continue;
      }
    }

    return (leftColumn, rightColumn);
  }
}
