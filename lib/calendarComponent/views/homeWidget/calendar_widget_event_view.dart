import 'package:campus_flutter/base/extensions/date_day.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:campus_flutter/base/l10n/generated/app_localizations.dart';

import '../../../courseComponent/views/course_view.dart';
import '../../model/calendar_event.dart';

class CalendarHomeWidgetEventView extends StatelessWidget {
  const CalendarHomeWidgetEventView({super.key, required this.calendarEvent});

  final CalendarEvent calendarEvent;

  @override
  Widget build(BuildContext context) {
    final String startTime = DateFormat(DateFormat.HOUR24_MINUTE).format(calendarEvent.startDate);
    final String endTime = DateFormat(DateFormat.HOUR24_MINUTE).format(calendarEvent.endDate);
    final DateTime today = DateTime.now().dateDay;
    final DateTime tomorrowDate = today.add(const Duration(days: 1));
    final DateTime startDate = DateTime(
        calendarEvent.startDate.year, calendarEvent.startDate.month, calendarEvent.startDate.day);

    return GestureDetector(
        onTap: () {
          if (calendarEvent.courseId != null) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => CoursePage(courseId: calendarEvent.courseId!, selectedDate: calendarEvent.startDate),
            ));
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Text(
                startDate.isAtSameMomentAs(today)
                    ? AppLocalizations.of(context)!.calendarToday
                    : startDate.isAtSameMomentAs(tomorrowDate)
                        ? AppLocalizations.of(context)!.calendarTomorrow
                        : DateFormat("EEEE, d. MMM").format(calendarEvent.startDate),
                style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
            const Spacer(),
            Container(
                decoration: BoxDecoration(
                    border: Border(
                        left: BorderSide(color: Theme.of(context).primaryColor, width: 2.0))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(calendarEvent.summary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium),
                      Text("$startTime - $endTime",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall),
                      if(calendarEvent.location != null)
                      Text(calendarEvent.location!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall)
                    ],
                  ),
                )),
            const Spacer()
          ],
        ));
  }
}
