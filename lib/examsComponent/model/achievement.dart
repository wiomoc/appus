import 'package:json_annotation/json_annotation.dart';

part 'achievement.g.dart';

@JsonSerializable()
class Achievement {
  final int id;
  final String localizedCourseName;
  final String localizedStudyName;
  final String localizedDegreeName;
  final int courseId;
  final String grade;
  final bool valid;
  final bool passed;
  final String localizedSemester;
  final DateTime dateTime;

  Achievement(
      {required this.id,
        required this.localizedCourseName,
        required this.localizedStudyName,
        required this.localizedDegreeName,
        required this.courseId,
        required this.grade,
        required this.valid,
        required this.passed,
        required this.localizedSemester,
        required this.dateTime});

  factory Achievement.fromJson(Map<String, dynamic> json) => _$AchievementFromJson(json);

  Map<String, dynamic> toJson() => _$AchievementToJson(this);


  @override
  String toString() {
    return 'Achievement{id: $id, localizedCourseName: $localizedCourseName, courseId: $courseId, grade: $grade, semester: $localizedSemester, dateTime: $dateTime}';
  }
}