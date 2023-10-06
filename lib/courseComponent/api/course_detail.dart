import 'package:campus_flutter/courseComponent/model/course_group_detail.dart';

import '../../base/extensions/cast.dart';
import '../../base/helpers/api_operation.dart';
import '../../base/networking/apis/campUSApi/campus_api.dart';
import '../../calendarComponent/model/calendar_event.dart';
import '../../providers_get_it.dart';
import '../model/course_detail.dart';

class CourseDetailApiOperation extends ApiOperation<(CourseDetail, CourseGroupDetail)> {
  final int id;

  CourseDetailApiOperation(this.id);

  @override
  String get cacheKey => "course$id";

  @override
  (CourseDetail, CourseGroupDetail) fromCached(Map<String, dynamic> map) =>
      (CourseDetail.fromJson(map["detail"]), CourseGroupDetail.fromJson(map["group"]));

  @override
  Map<String, dynamic> toCached((CourseDetail, CourseGroupDetail) object) => {
        "detail": object.$1.toJson(),
        "group": object.$2.toJson(),
      };

  Future<CourseGroupDetail> _fetchGroups(CampusApi campusApi) async {
    final resource = await campusApi.callRestApi("slc.tm.cp/student/courseGroups/firstGroups/$id");
    final Map<String, dynamic> courseGroup = resource[0]["content"]["cpCourseGroupDto"];

    CalendarEventStatus decodeAppointmentStatus(String str) {
      switch (str) {
        case "CANCELLED":
          return CalendarEventStatus.canceled;
        case "CONFIRMED":
          return CalendarEventStatus.fixed;
        default:
          return CalendarEventStatus.unknown;
      }
    }

    int? getRoomId(String? resourcePath) {
      if (resourcePath == null) return null;
      final resourcePathParts = resourcePath.split("?");
      if (resourcePathParts.length != 2) return null;
      final raumKey = Uri.splitQueryString(resourcePathParts[1])["raumKey"];
      if (raumKey == null) return null;
      return int.tryParse(raumKey);
    }

    return CourseGroupDetail(
        courseId: courseGroup["courseId"],
        groupId: courseGroup["id"],
        lecturerNames: (courseGroup["lectureshipDtos"] as List<dynamic>)
            .where((lectureship) => lectureship["teachingFunction"]["key"] == "V")
            .map((lectureship) =>
                "${lectureship["identityLibDto"]["firstName"]} ${lectureship["identityLibDto"]["lastName"]}")
            .toList(),
        appointments: (courseGroup["appointmentDtos"] as List<dynamic>)
            .map((appointment) => Appointment(
                id: appointment["id"],
                type: CalendarEventType.lecture,
                status: decodeAppointmentStatus(appointment["appointmentStatusType"]),
                courseId: courseGroup["courseId"],
                startDate: DateTime.parse(appointment["timestampFrom"]["value"]),
                endDate: DateTime.parse(appointment["timestampTo"]["value"]),
                roomName: appointment["resourceName"],
                roomId: getRoomId(appointment["resourceUrl"])))
            .toList());
  }

  Future<CourseDetail> _fetchCourse(CampusApi campusApi) async {
    final resource = await campusApi.callRestApi("slc.tm.cp/student/courses/$id");
    final Map<String, dynamic> courseDetail = resource[0]["content"]["cpCourseDetailDto"];
    final semesterHoursString = cast<List<dynamic>?>(courseDetail["cpCourseDto"]?["courseNormConfigs"])
        ?.where((element) => element["key"] == "SST")
        .firstOrNull?["value"];

    return CourseDetail(
        id: courseDetail["cpCourseDto"]["id"],
        courseNumber: courseDetail["cpCourseDto"]["courseNumber"]["courseNumber"],
        localizedTitle: CampusApi.getLocalized(courseDetail["cpCourseDto"]["courseTitle"])!,
        semesterHours: (semesterHoursString != null) ? int.tryParse(semesterHoursString) : null,
        localizedType: CampusApi.getLocalized(courseDetail["cpCourseDto"]["courseTypeDto"]["courseTypeName"])!,
        localizedSemester: CampusApi.getLocalized(courseDetail["cpCourseDto"]["semesterDto"]["semesterDesignation"])!,
        localizedOrganisation:
        CampusApi.getLocalized(courseDetail["cpCourseDto"]?["organisationResponsibleDto"]?["name"]),
        localizedLanguage: (courseDetail["cpCourseDto"]["courseLanguageDtos"] as List<dynamic>)
            .map((language) => CampusApi.getLocalized(language["languageDto"]["name"])!)
            .join(", "),
        localizedCourseContent: CampusApi.getLocalized(courseDetail["cpCourseDescriptionDto"]?["courseContent"]),
        localizedCourseObjective: CampusApi.getLocalized(courseDetail["cpCourseDescriptionDto"]?["courseObjective"]));
  }

  @override
  Future<(CourseDetail, CourseGroupDetail)> fetchOnline() async {
    final campusApi = getIt.get<CampusApi>();
    final [course, groups] = await Future.wait([_fetchCourse(campusApi), _fetchGroups(campusApi)]);
    return (course as CourseDetail, groups as CourseGroupDetail);
  }
}

