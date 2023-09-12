import '../../base/helpers/api_operation.dart';
import '../../base/networking/apis/campUSApi/campus_api.dart';
import '../../providers_get_it.dart';
import '../model/course_summary.dart';

class CoursesSearchApiOperation extends ApiOperation<List<CourseSummary>> {

  final String searchText;

  CoursesSearchApiOperation(this.searchText);

  @override
  String get cacheKey => "coursesSearch$searchText";

  @override
  List<CourseSummary> fromCached(Map<String, dynamic> map) =>
      (map["courses"] as List<dynamic>).map((courseJson) => CourseSummary.fromJson(courseJson)).toList();

  @override
  Map<String, dynamic> toCached(List<CourseSummary> object) =>
      {"courses": object.map((course) => course.toJson()).toList()};

  @override
  Future<List<CourseSummary>> fetchOnline() async {
    final campusApi = getIt.get<CampusApi>();
    final List<dynamic> courseResources = await campusApi.callRestApi("slc.tm.cp/student/courses",
        params: {
          "\$orderBy": "title=ascnf",
          "\$skip": 0,
          "\$top": 5,
          "\$filter": "courseNormKey-eq=LVEAB;filterTerm-like=$searchText;orgId-eq=3"
        });

    return courseResources.map((courseResource) {
      final course = courseResource["content"]["cpCourseDto"];
      final semesterHoursString = (course["courseNormConfigs"] as List<dynamic>)
          .where((element) => element["key"] == "SST")
          .firstOrNull?["value"];

      return CourseSummary(
          id: course["id"],
          courseNumber: course["courseNumber"]["courseNumber"],
          localizedTitle: CampusApi.getLocalized(course["courseTitle"])!,
          localizedType: CampusApi.getLocalized(course["courseTypeDto"]["courseTypeName"])!,
          groupId: 0,
          semesterHours: (semesterHoursString != null) ? int.tryParse(semesterHoursString) : null);
    }).toList(growable: false);
  }
}

