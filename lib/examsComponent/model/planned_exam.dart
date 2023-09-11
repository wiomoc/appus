import 'package:json_annotation/json_annotation.dart';

part 'planned_exam.g.dart';

@JsonSerializable()
class PlannedExam {
  final int id;
  final int courseId;
  final String courseName;
  final DateTime? date;
  final List<String> examers;
  final String? roomName;
  final int? roomId;
  final DateTime? deregistrationEnd;

  PlannedExam(
      {required this.id,
        required this.courseId,
        required this.courseName,
        required this.date,
        required this.examers,
        required this.roomName,
        required this.roomId,
        required this.deregistrationEnd});

  factory PlannedExam.fromJson(Map<String, dynamic> json) => _$PlannedExamFromJson(json);

  Map<String, dynamic> toJson() => _$PlannedExamToJson(this);

  @override
  String toString() {
    return 'PlannedExam{id: $id, courseId: $courseId, courseName: $courseName, date: $date, examer: $examers, roomName: $roomName, roomId: $roomId, registrationEnd: $deregistrationEnd}';
  }
}