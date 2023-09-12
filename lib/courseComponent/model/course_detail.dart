import 'package:json_annotation/json_annotation.dart';

part 'course_detail.g.dart';

@JsonSerializable()
class CourseDetail {
  final int id;
  final String courseNumber;
  final String localizedTitle;
  final int? semesterHours;
  final String localizedType;
  final String localizedSemester;
  final String? localizedOrganisation;
  final String localizedLanguage;
  final String? localizedCourseContent;
  final String? localizedCourseObjective;

  CourseDetail({required this.id,
    required this.courseNumber,
    required this.localizedTitle,
    required this.semesterHours,
    required this.localizedType,
    required this.localizedSemester,
    this.localizedOrganisation,
    required this.localizedLanguage,
    this.localizedCourseContent,
    this.localizedCourseObjective});

  factory CourseDetail.fromJson(Map<String, dynamic> json) => _$CourseDetailFromJson(json);

  Map<String, dynamic> toJson() => _$CourseDetailToJson(this);

  @override
  String toString() {
    return 'CourseDetail{courseNumber: $courseNumber, localizedTitle: $localizedTitle}';
  }
}