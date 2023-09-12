import 'package:json_annotation/json_annotation.dart';

import '../../searchComponent/model/comparison_token.dart';
import '../../searchComponent/protocols/searchable.dart';

part 'course_summary.g.dart';

@JsonSerializable()
class CourseSummary extends Searchable {
  final int id;
  final String courseNumber;
  final String localizedTitle;
  final String localizedType;
  final int groupId;
  final String? localizedStudyProgramme;
  final int? semesterHours;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get iliasUrl => "https://ilias3.uni-stuttgart.de/ecsredi.php?cmsid=$id";

  CourseSummary(
      {required this.id,
      required this.courseNumber,
      required this.localizedTitle,
      required this.localizedType,
      required this.groupId,
      this.localizedStudyProgramme,
      this.semesterHours});

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<ComparisonToken> get comparisonTokens => [ComparisonToken(value: localizedTitle), ComparisonToken(value: courseNumber)];

  @override
  String toString() {
    return 'CourseSummary{id: $id, localizedTitle: $localizedTitle, localizedType: $localizedType, groupId: $groupId, localizedStudyProgramme: $localizedStudyProgramme, semesterHours: $semesterHours}';
  }

  factory CourseSummary.fromJson(Map<String, dynamic> json) => _$CourseSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$CourseSummaryToJson(this);
}
