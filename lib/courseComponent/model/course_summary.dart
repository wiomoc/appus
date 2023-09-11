import 'package:json_annotation/json_annotation.dart';

part 'course_summary.g.dart';

@JsonSerializable()
class CourseSummary {
  final int id;
  final String localizedTitle;
  final String localizedType;
  final int groupId;
  final String localizedStudyProgramme;
  final int? semesterHours;

  String get iliasUrl => "https://ilias3.uni-stuttgart.de/ecsredi.php?cmsid=$id";

  CourseSummary(
      {required this.id,
      required this.localizedTitle,
      required this.localizedType,
      required this.groupId,
      required this.localizedStudyProgramme,
      this.semesterHours});

  @override
  String toString() {
    return 'CourseSummary{id: $id, localizedTitle: $localizedTitle, localizedType: $localizedType, groupId: $groupId, localizedStudyProgramme: $localizedStudyProgramme, semesterHours: $semesterHours}';
  }

  factory CourseSummary.fromJson(Map<String, dynamic> json) => _$CourseSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$CourseSummaryToJson(this);
}
