import 'package:campus_flutter/calendarComponent/model/calendar_event.dart';
import 'package:dio/dio.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:intl/intl.dart';

import '../../base/helpers/api_operation.dart';
import '../../base/networking/apis/campUSApi/campus_api.dart';
import '../../providers_get_it.dart';

class MyEventsApiOperation extends ApiOperation<List<CalendarEvent>> {
  final DateTime startDate;
  final DateTime endDate;

  MyEventsApiOperation(this.startDate, this.endDate);

  @override
  String get cacheKey => "events$startDate$endDate";

  @override
  List<CalendarEvent> fromCached(Map<String, dynamic> map) =>
      (map["events"] as List<dynamic>).map((courseJson) => CalendarEvent.fromJson(courseJson)).toList();

  @override
  Map<String, dynamic> toCached(List<CalendarEvent> object) =>
      {"events": object.map((event) => event.toJson()).toList()};

  @override
  Future<List<CalendarEvent>> fetchOnline() async {
    final campusApi = getIt.get<CampusApi>();
    final paramDateformat = DateFormat("dd.MM.yyyy");

    final response = await campusApi.call(
        "wbKalender.wbExport",
        {
          "pMode": "I",
          "pInclPruef": "J",
          "pInclPruefGepl": "J",
          "pExportBetreff": "J",
          "pExportAnsprechpartner": "J",
          "pExportOrt": "J",
          "pExportTerminTyp": "J",
          "pExportPublikumIntern": "J",
          "pDateFrom": paramDateformat.format(startDate),
          "pDateTo": paramDateformat.format(endDate),
          "pOutputFormat": "99",
          "pCharset": "UTF8",
          "pVortragende": "J",
          "pMaskAction": "DOWNLOAD"
        },
        responseType: ResponseType.plain);

    final ical = ICalendar.fromString(response.data.toString());

    //final icalDateformat = DateFormat("yyyyMMdd'T'hhmmss'Z'");

    return ical.data.map((event) {
      String? courseId;
      if (event["url"] != null) {
        final url = Uri.parse(event["url"]);
        courseId = url.queryParameters["pStpSpNr"];
      }

      CalendarEventStatus status = CalendarEventStatus.unknown;
      CalendarEventType type = CalendarEventType.unknown;
      final String? description = event["description"];
      if (description != null && description.isNotEmpty) {
        final descriptionParts = description.split("\\; ");
        if (descriptionParts.length > 0) {
          switch (descriptionParts[0]) {
            case "fix":
              status = CalendarEventStatus.fixed;
              break;
          }
        }
        if (descriptionParts.length > 1) {
          switch (descriptionParts[1]) {
            case "Prüfungstermin":
              type = CalendarEventType.examination;
              break;
            case "Abhaltung":
              type = CalendarEventType.lecture;
              break;
          }
        }
      }

      return CalendarEvent(
          id: event["uid"],
          status: status,
          type: type,
          startDate: event["dtstart"].toDateTime()!,
          endDate: event["dtend"].toDateTime()!,
          summary: event["summary"],
          location: event["location"],
          courseId: courseId != null ? int.parse(courseId) : null);
    }).toList(growable: false);
  }
}
