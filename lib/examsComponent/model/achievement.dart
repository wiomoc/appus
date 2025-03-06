import 'package:json_annotation/json_annotation.dart';

part 'achievement.g.dart';

enum AchievementType {
  exam,
  thesis
}

@JsonSerializable()
class Achievement {
  final int id;
  final AchievementType type;
  final String localizedCourseName;
  final String localizedStudyName;
  final String localizedDegreeName;
  final int? courseId;
  final String? grade;
  final bool valid;
  final bool? passed;
  final String localizedSemester;
  final DateTime? dateTime;

  Achievement(
      {required this.id,
        required this.type,
        required this.localizedCourseName,
        required this.localizedStudyName,
        required this.localizedDegreeName,
        required this.courseId,
        this.grade,
        required this.valid,
        this.passed,
        required this.localizedSemester,
        this.dateTime});

  factory Achievement.fromJson(Map<String, dynamic> json) => _$AchievementFromJson(json);

  Map<String, dynamic> toJson() => _$AchievementToJson(this);


  @override
  String toString() {
    return 'Achievement{id: $id, localizedCourseName: $localizedCourseName, courseId: $courseId, grade: $grade, semester: $localizedSemester, dateTime: $dateTime}';
  }
}