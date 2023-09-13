import 'package:json_annotation/json_annotation.dart';

part 'calendar_event.g.dart';

enum CalendarEventStatus { fixed, planned, canceled, rejected, deleted, rescheduled, unknown }

enum CalendarEventType {
  vacation,
  lecture,
  examination,
  personal,
  nonAcademicEvent,
  internalTraining,
  administrative,
  resourceBooking,
  blocker,
  unknown
}

@JsonSerializable()
class CalendarEvent {
  final String id;
  final CalendarEventStatus status;
  final CalendarEventType type;
  final DateTime startDate;
  final DateTime endDate;
  final String summary;
  final String? location;
  final int? courseId;

  CalendarEvent(
      {required this.id,
        required this.status,
        required this.type,
        required this.startDate,
        required this.endDate,
        required this.summary,
        required this.location,
        this.courseId});

  factory CalendarEvent.fromJson(Map<String, dynamic> json) => _$CalendarEventFromJson(json);

  Map<String, dynamic> toJson() => _$CalendarEventToJson(this);

  @override
  String toString() {
    return 'CalendarEvent{id: $id, status: $status, type: $type, startDate: $startDate, endDate: $endDate, summary: $summary, location: $location, courseId: $courseId}';
  }
}