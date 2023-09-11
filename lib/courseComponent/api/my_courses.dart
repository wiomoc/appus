import '../../base/helpers/api_operation.dart';
import '../../base/networking/apis/campUSApi/campus_api.dart';
import '../../providers_get_it.dart';
import '../model/course_summary.dart';

class MyCoursesApiOperation extends ApiOperation<List<CourseSummary>> {

  @override
  String get cacheKey => "myCourses";

  @override
  List<CourseSummary> fromCached(Map<String, dynamic> map) =>
      (map["courses"] as List<dynamic>).map((courseJson) => CourseSummary.fromJson(courseJson)).toList();

  @override
  Map<String, dynamic> toCached(List<CourseSummary> object) =>
      {"courses": object.map((course) => course.toJson()).toList()};

  @override
  Future<List<CourseSummary>> fetchOnline() async {
    final campusApi = getIt.get<CampusApi>();
    final List<dynamic> courseResources = await campusApi.callRestApi("slc.tm.cp/student/myCourses",
        params: {"\$orderBy": "title=ascnf", "\$skip": 0, "\$top": 20});

    return courseResources.map((courseResource) {
      final courseRegistration = courseResource["content"]["cpCourseGroupRegistrationDto"];
      final semesterHoursString = (courseRegistration["courseNormConfigs"] as List<dynamic>)
          .where((element) => element["key"] == "SST")
          .firstOrNull?["value"];

      return CourseSummary(
          id: courseRegistration["course"]["id"],
          localizedTitle: CampusApi.getLocalized(courseRegistration["course"]["courseTitle"])!,
          localizedType: CampusApi.getLocalized(courseRegistration["course"]["courseTypeDto"]["courseTypeName"])!,
          groupId: courseRegistration["courseGroupId"],
          localizedStudyProgramme: CampusApi.getLocalized(courseRegistration["studyProgramme"]["studyName"])!,
          semesterHours: (semesterHoursString != null) ? int.parse(semesterHoursString) : null);
    }).toList(growable: false);
  }
}

