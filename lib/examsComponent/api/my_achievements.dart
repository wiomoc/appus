import '../../base/helpers/api_operation.dart';
import '../../base/networking/apis/campUSApi/campus_api.dart';
import '../../providers_get_it.dart';
import '../model/achievement.dart';

class MyAchievementsApiOperation extends ApiOperation<List<Achievement>> {
  @override
  String get cacheKey => "myAchievements";

  @override
  List<Achievement> fromCached(Map<String, dynamic> map) =>
      (map["achievements"] as List<dynamic>).map((courseJson) => Achievement.fromJson(courseJson)).toList();

  @override
  Map<String, dynamic> toCached(List<Achievement> object) =>
      {"achievements": object.map((course) => course.toJson()).toList()};

  @override
  Future<List<Achievement>> fetchOnline() async {
    final campusApi = getIt.get<CampusApi>();

    final List<dynamic> achievementResources =
        await campusApi.callRestApi("slc.xm.ac/achievements", params: {"\$orderBy": "acDate=descnf"});

    return achievementResources.map((achievementResource) {
      final achievement = achievementResource["content"]["achievementDto"];
      return Achievement(
          id: achievement["id"],
          localizedCourseName: CampusApi.getLocalized(achievement["cpCourseLibDto"]["courseTitle"])!,
          localizedStudyName: CampusApi.getLocalized(achievement["studyBasicInfoLibDto"]["studyName"])!,
          localizedDegreeName: CampusApi.getLocalized(
              achievement["studyBasicInfoLibDto"]["basicStudyProgrammeLibDto"]["degreeType"]["name"])!,
          courseId: achievement["cpCourseLibDto"]["id"],
          grade: achievement["gradeDto"]["value"],
          valid: achievement["achievementStatusType"] == "FINAL",
          passed: achievement["gradeDto"]["isPositive"],
          localizedSemester: CampusApi.getLocalized(achievement["semesterLibDto"]["semesterDesignation"])!,
          dateTime: DateTime.parse(achievement["achievementDate"]["value"]));
    }).toList(growable: false);
  }
}
