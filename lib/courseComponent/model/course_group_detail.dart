import 'package:json_annotation/json_annotation.dart';

import '../../calendarComponent/model/calendar_event.dart';

part 'course_group_detail.g.dart';

@JsonSerializable()
class Appointment {
  final int id;
  final CalendarEventType type;
  final CalendarEventStatus status;
  final int courseId;
  final DateTime startDate;
  final DateTime endDate;
  final String? roomName;
  final int? roomId;

  Appointment(
      {required this.id,
      required this.type,
      required this.status,
      required this.courseId,
      required this.startDate,
      required this.endDate,
      required this.roomName,
      required this.roomId});

  String? get cleanRoomName => roomName?.split(" (")[0];

  factory Appointment.fromJson(Map<String, dynamic> json) => _$AppointmentFromJson(json);

  Map<String, dynamic> toJson() => _$AppointmentToJson(this);
}

@JsonSerializable()
class CourseGroupDetail {
  final int courseId;
  final int groupId;
  final List<String> lecturerNames;
  final List<Appointment> appointments;

  CourseGroupDetail(
      {required this.courseId, required this.groupId, required this.lecturerNames, required this.appointments});

  factory CourseGroupDetail.fromJson(Map<String, dynamic> json) => _$CourseGroupDetailFromJson(json);

  Map<String, dynamic> toJson() => _$CourseGroupDetailToJson(this);

  @override
  String toString() {
    return 'CourseGroupDetail{id: $courseId, groupId: $groupId, lecturerNames: $lecturerNames, appointments: $appointments}';
  }
}
