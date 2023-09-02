import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'campus_api_exception.dart';

class AuthTokens {
  final String profile;
  final String psessionid;
  final String accessToken;

  AuthTokens({required this.profile, required this.psessionid, required this.accessToken});

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      AuthTokens(profile: json["profile"]!, psessionid: json["psessionid"]!, accessToken: json["accessToken"]!);

  Map<String, String> toJson() => {"profile": profile, "psessionid": psessionid, "accessToken": accessToken};

  @override
  String toString() {
    return 'AuthState{profile: $profile, psessionid: $psessionid, accessToken: $accessToken}';
  }
}

const campusBaseUrl = "https://campus.uni-stuttgart.de/cusonline/";
const userAgent = "burn-uninow";

enum CalendarEventStatus { fixed, planned, canceled, rejected, deleted, rescheduled, unknown }

enum CalendarEventType {
  vacation,
  lecture,
  examination,
  personal,
  nonAcademicEvent,
  internalTraining,
  administrative,
  resourceBooking,
  blocker,
  unknown
}

class CalendarEvent {
  final String id;
  final CalendarEventStatus status;
  final CalendarEventType type;
  final DateTime startDate;
  final DateTime endDate;
  final String summary;
  final String? location;
  final int? courseId;

  CalendarEvent(
      {required this.id,
      required this.status,
      required this.type,
      required this.startDate,
      required this.endDate,
      required this.summary,
      required this.location,
      this.courseId});

  @override
  String toString() {
    return 'CalendarEvent{id: $id, status: $status, type: $type, startDate: $startDate, endDate: $endDate, summary: $summary, location: $location, courseId: $courseId}';
  }
}

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
}

class Appointment {
  final int id;
  final CalendarEventType type;
  final CalendarEventStatus status;
  final int courseId;
  final DateTime startDate;
  final DateTime endDate;
  final String? roomName;
  final int? roomId;

  Appointment(
      {required this.id,
      required this.type,
      required this.status,
      required this.courseId,
      required this.startDate,
      required this.endDate,
      required this.roomName,
      required this.roomId});

  String? get cleanRoomName => roomName?.split(" (")[0];
}

class CourseDetail {
  final int id;
  final String courseNumber;
  final String localizedTitle;
  final int? semesterHours;
  final String localizedType;
  final String localizedSemester;
  final String localizedOrganisation;
  final String localizedLanguage;
  final String? localizedCourseContent;
  final String? localizedCourseObjective;

  CourseDetail(
      {required this.id,
      required this.courseNumber,
      required this.localizedTitle,
      required this.semesterHours,
      required this.localizedType,
      required this.localizedSemester,
      required this.localizedOrganisation,
      required this.localizedLanguage,
      this.localizedCourseContent,
      this.localizedCourseObjective});
}

class CourseGroupDetail {
  final int courseId;
  final int groupId;
  final List<String> lecturerNames;
  final List<Appointment> appointments;

  CourseGroupDetail(
      {required this.courseId, required this.groupId, required this.lecturerNames, required this.appointments});

  @override
  String toString() {
    return 'CourseGroupDetail{id: $courseId, groupId: $groupId, lecturerNames: $lecturerNames, appointments: $appointments}';
  }
}

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

  @override
  String toString() {
    return 'PlannedExam{id: $id, courseId: $courseId, courseName: $courseName, date: $date, examer: $examers, roomName: $roomName, roomId: $roomId, registrationEnd: $deregistrationEnd}';
  }
}

class Study {
  final int id;
  final String germanName;
  final String localizedName;
  final String localizedDegree;

  Study({required this.id, required this.germanName, required this.localizedName, required this.localizedDegree});

  @override
  String toString() {
    return 'Study{id: $id, germanName: $germanName, localizedName: $localizedName, localizedDegree: $localizedDegree}';
  }
}

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

  @override
  String toString() {
    return 'Achievement{id: $id, localizedCourseName: $localizedCourseName, courseId: $courseId, grade: $grade, semester: $localizedSemester, dateTime: $dateTime}';
  }
}

class CampusApi {
  static const String authTokenPrefKey = "campus_auth_token";

  late final Future<void> isInitialized;
  final BehaviorSubject<bool> isAuthenticated = BehaviorSubject();

  AuthTokens? currentAuthTokens;
  Dio dioClient;

  CampusApi(this.dioClient) {
    isInitialized = _initialize().catchError((error) {});
  }

  Future<void> _initialize() async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final data = sharedPreferences.get(authTokenPrefKey) as String?;
    if (data != null) {
      try {
        currentAuthTokens = AuthTokens.fromJson(jsonDecode(data));
        isAuthenticated.value = true;
      } catch (error) {
        print(error);
        isAuthenticated.value = false;
      }
    } else {
      isAuthenticated.value = false;
    }
  }

  Future<void> _storeAuthTokens() async {
    final currentAuthTokens = this.currentAuthTokens;
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (currentAuthTokens != null) {
      sharedPreferences.setString(authTokenPrefKey, jsonEncode(currentAuthTokens.toJson()));
    } else {
      sharedPreferences.remove(authTokenPrefKey);
    }
  }

  String _generateRandomString(int len) {
    var r = Random();
    String randomString = String.fromCharCodes(List.generate(len, (index) => r.nextInt(33) + 89));
    return randomString;
  }

  Future<void> login(String username, String password) async {
    final state = base64UrlEncode(const Utf8Encoder().convert(Uri(queryParameters: {
      "client_id": "co_ee_ui_client_id",
      "response_type": "code",
      "scope": "ANY@co.standard+ANY@co.public+POST@co.plsql+GET@co.plsql",
      "redirect_uri": "https://campus.uni-stuttgart.de/cusonline/ee/login/oauth2code",
      "state": _generateRandomString(20),
      "id_provider": "username"
    }).query));

    final queryParameters = {
      "pUsername": username,
      "pPassword": password,
      "pConfirm": "X",
      "pStateWrapper": state,
      "pSkipOauth2": "F"
    };

    final headers = {"Accept": "application/json", "User-Agent": userAgent};

    print(Uri.parse("${campusBaseUrl}wbOAuth2.approve").replace(queryParameters: queryParameters).toString());

    final response = await dioClient.get("${campusBaseUrl}wbOAuth2.approve",
        queryParameters: queryParameters,
        options: Options(followRedirects: false, validateStatus: (status) => true, headers: headers));
    var responseObject = response.data;
    final Map<String, Cookie> cookies = Map.fromIterable(
        response.headers[HttpHeaders.setCookieHeader]?.map(Cookie.fromSetCookieValue) ?? [],
        key: (cookie) => cookie.name);

    if (response.statusCode == 302) {
      final location = path.url.join(campusBaseUrl, response.headers["location"]!.first);
      final secondResponse = await dioClient.get(location,
          options: Options(followRedirects: false, validateStatus: (status) => true, headers: headers));
      responseObject = secondResponse.data;
    }

    final String? error = responseObject["error"];
    if (error != null) {
      final String errorDescription = responseObject["error_description"];
      if (error == "invalid_un_pswd") {
        throw InvalidCampusCredentialsException(error);
      } else {
        throw CampusApiException(errorDescription);
      }
    }

    final String accessToken = responseObject["access_token"];

    isAuthenticated.value = true;
    currentAuthTokens = AuthTokens(
        profile: cookies["CO_PROFILE"]!.value, psessionid: cookies["PSESSIONID"]!.value, accessToken: accessToken);
    _storeAuthTokens();
  }

  Future<List<dynamic>> _callRestApi(String path,
      {Map<String, dynamic>? params, bool requireAuth = true, String resourcesKey = "resource"}) async {
    final response = await _call("ee/rest/$path", params, requireAuth: requireAuth, appendAccessToken: requireAuth);
    final Map<String, dynamic> responseData = response.data;
    final resource = responseData[resourcesKey];
    if (resource == null) {
      throw CampusApiException("${responseData["status"]} - ${responseData["title"]}");
    }
    return resource;
  }

  Future<void> _refreshToken() async {
    final response = await _call("ee/rest/auth/token/refresh", null, method: "post", suppressTokenRefresh: true);
    final Map<String, dynamic> responseData = response.data;
    final newAccessToken = responseData["accessToken"];
    if (newAccessToken == null) {
      throw CampusApiException("Could not refresh access token");
    }

    currentAuthTokens = AuthTokens(
        profile: currentAuthTokens!.profile, psessionid: currentAuthTokens!.psessionid, accessToken: newAccessToken);
    _storeAuthTokens();
  }

  Future<Response<dynamic>> _call(String path, Map<String, dynamic>? params,
      {String method = "get",
      bool requireAuth = true,
      ResponseType responseType = ResponseType.json,
      bool appendAccessToken = false,
      bool suppressTokenRefresh = false}) async {
    if (requireAuth) {
      await isInitialized;
    }

    final Map<String, dynamic> headers = {"User-Agent": userAgent};
    if (responseType == ResponseType.json) {
      headers["Accept"] = "application/json";
    }
    if (requireAuth) {
      final authState = currentAuthTokens;
      if (authState == null) {
        throw StateError("Auth required");
      }
      headers[HttpHeaders.cookieHeader] = [
        Cookie("CO_PROFILE", authState.profile)..httpOnly = false,
        Cookie("PSESSIONID", authState.psessionid)..httpOnly = false
      ].join("; ");
      if (appendAccessToken) {
        headers[HttpHeaders.authorizationHeader] = "Bearer ${authState.accessToken}";
      }
    }

    final response = await dioClient.request("$campusBaseUrl$path",
        queryParameters: params,
        options: Options(
          method: method,
          headers: headers,
          responseType: responseType,
          validateStatus: (status) => true,
        ));
    print(response.headers);
    if (response.statusCode == 401 && appendAccessToken) {
      if (suppressTokenRefresh) {
        throw CampusApiException("Could not refresh access token");
      }
      await _refreshToken();
      return _call(path, params,
          requireAuth: requireAuth, responseType: responseType, appendAccessToken: true, suppressTokenRefresh: true);
    }
    return response;
  }

  Future<List<CalendarEvent>> calendar(DateTime startDate, DateTime endDate) async {
    final paramDateformat = DateFormat("dd.MM.yyyy");

    final response = await _call(
        "wbKalender.wbExport",
        {
          "pMode": "I",
          "pInclPruef": "J",
          "pInclPruefGepl": "J",
          "pExportBetreff": "J",
          "pExportAnsprechpartner": "J",
          "pExportOrt": "J",
          "pExportTerminTyp": "J",
          "pExportPublikumIntern": "J",
          "pDateFrom": paramDateformat.format(startDate),
          "pDateTo": paramDateformat.format(endDate),
          "pOutputFormat": "99",
          "pCharset": "UTF8",
          "pVortragende": "J",
          "pMaskAction": "DOWNLOAD"
        },
        responseType: ResponseType.plain);

    final ical = ICalendar.fromString(response.data.toString());

    //final icalDateformat = DateFormat("yyyyMMdd'T'hhmmss'Z'");

    return ical.data.map((event) {
      String? courseId;
      if (event["url"] != null) {
        final url = Uri.parse(event["url"]);
        courseId = url.queryParameters["pStpSpNr"];
      }

      CalendarEventStatus status = CalendarEventStatus.unknown;
      CalendarEventType type = CalendarEventType.unknown;
      final String? description = event["description"];
      if (description != null && description.isNotEmpty) {
        final descriptionParts = description.split("\\; ");
        if (descriptionParts.length > 0) {
          switch (descriptionParts[0]) {
            case "fix":
              status = CalendarEventStatus.fixed;
              break;
          }
        }
        if (descriptionParts.length > 1) {
          switch (descriptionParts[1]) {
            case "Prüfungstermin":
              type = CalendarEventType.examination;
              break;
            case "Abhaltung":
              type = CalendarEventType.lecture;
              break;
          }
        }
      }

      return CalendarEvent(
          id: event["uid"],
          status: status,
          type: type,
          startDate: event["dtstart"].toDateTime()!,
          endDate: event["dtend"].toDateTime()!,
          summary: event["summary"],
          location: event["location"],
          courseId: courseId != null ? int.parse(courseId) : null);
    }).toList(growable: false);
  }

  String? _getLocalized(Map<String, dynamic> translatable) {
    final expectedLang = "de";
    final List<dynamic> translationList = translatable["translations"]["translation"]!;
    return translationList.where((translation) => translation["lang"] == expectedLang).firstOrNull?["value"] ??
        translationList.first["value"];
  }

  Future<List<CourseSummary>> myCourses() async {
    final List<dynamic> courseResources = await _callRestApi("slc.tm.cp/student/myCourses",
        params: {"\$orderBy": "title=ascnf", "\$skip": 0, "\$top": 20});

    return courseResources.map((courseResource) {
      final courseRegistration = courseResource["content"]["cpCourseGroupRegistrationDto"];
      final semesterHoursString = (courseRegistration["courseNormConfigs"] as List<dynamic>)
          .where((element) => element["key"] == "SST")
          .firstOrNull?["value"];

      return CourseSummary(
          id: courseRegistration["course"]["id"],
          localizedTitle: _getLocalized(courseRegistration["course"]["courseTitle"])!,
          localizedType: _getLocalized(courseRegistration["course"]["courseTypeDto"]["courseTypeName"])!,
          groupId: courseRegistration["courseGroupId"],
          localizedStudyProgramme: _getLocalized(courseRegistration["studyProgramme"]["studyName"])!,
          semesterHours: (semesterHoursString != null) ? int.parse(semesterHoursString) : null);
    }).toList(growable: false);
  }

  Future<List<Achievement>> myAchievements() async {
    final List<dynamic> achievementResources =
        await _callRestApi("slc.xm.ac/achievements", params: {"\$orderBy": "acDate=descnf"});

    return achievementResources.map((achievementResource) {
      final achievement = achievementResource["content"]["achievementDto"];
      return Achievement(
          id: achievement["id"],
          localizedCourseName: _getLocalized(achievement["cpCourseLibDto"]["courseTitle"])!,
          localizedStudyName: _getLocalized(achievement["studyBasicInfoLibDto"]["studyName"])!,
          localizedDegreeName:
              _getLocalized(achievement["studyBasicInfoLibDto"]["basicStudyProgrammeLibDto"]["degreeType"]["name"])!,
          courseId: achievement["cpCourseLibDto"]["id"],
          grade: achievement["gradeDto"]["value"],
          valid: achievement["achievementStatusType"] == "FINAL",
          passed: achievement["gradeDto"]["isPositive"],
          localizedSemester: _getLocalized(achievement["semesterLibDto"]["semesterDesignation"])!,
          dateTime: DateTime.parse(achievement["achievementDate"]["value"]));
    }).toList(growable: false);
  }

  Future<CourseDetail> course(int id) async {
    final resource = await _callRestApi("slc.tm.cp/student/courses/$id");
    final Map<String, dynamic> courseDetail = resource[0]["content"]["cpCourseDetailDto"];

    final semesterHoursString = (courseDetail["cpCourseDto"]["courseNormConfigs"] as List<dynamic>)
        .where((element) => element["key"] == "SST")
        .firstOrNull?["value"];

    return CourseDetail(
        id: courseDetail["cpCourseDto"]["id"],
        courseNumber: courseDetail["cpCourseDto"]["courseNumber"]["courseNumber"],
        localizedTitle: _getLocalized(courseDetail["cpCourseDto"]["courseTitle"])!,
        semesterHours: (semesterHoursString != null) ? int.parse(semesterHoursString) : null,
        localizedType: _getLocalized(courseDetail["cpCourseDto"]["courseTypeDto"]["courseTypeName"])!,
        localizedSemester: _getLocalized(courseDetail["cpCourseDto"]["semesterDto"]["semesterDesignation"])!,
        localizedOrganisation: _getLocalized(courseDetail["cpCourseDto"]["organisationResponsibleDto"]["name"])!,
        localizedLanguage: (courseDetail["cpCourseDto"]["courseLanguageDtos"] as List<dynamic>)
            .map((language) => _getLocalized(language["languageDto"]["name"])!)
            .join(", "),
        localizedCourseContent: _getLocalized(courseDetail["cpCourseDescriptionDto"]["courseContent"]),
        localizedCourseObjective: _getLocalized(courseDetail["cpCourseDescriptionDto"]["courseObjective"]));
  }

  Future<CourseGroupDetail> courseGroup(int courseId) async {
    final resource = await _callRestApi("slc.tm.cp/student/courseGroups/firstGroups/$courseId");
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

  Future<List<PlannedExam>> myRegisteredExams() async {
    final examOffers = await _callRestApi("slc.xm.exr/registered-exams", resourcesKey: "examOffers");
    return examOffers.map((exam) {
      final appointment = (exam["appointments"] as List<dynamic>?)?.firstOrNull;
      final String? roomId = appointment?["url"]?["href"]?.split("/")?.last;

      DateTime? date;
      if (exam["examDate"] != null && exam["examStart"] != null) {
        date = DateTime.parse(exam["examDate"]["value"] + "T" + exam["examStart"]["value"]);
      }

      return PlannedExam(
          id: exam["examId"],
          courseId: exam["courseId"],
          courseName: _getLocalized(exam["courseName"])!,
          roomName: appointment?["displayName"],
          roomId: roomId != null ? int.tryParse(roomId) : null,
          deregistrationEnd: DateTime.parse(exam["deRegistrationEnd"]["value"]),
          examers: (exam["examPersons"] as List<dynamic>)
              .where((examPerson) => examPerson["functionName"]["value"] == "Prüfer*in")
              .expand((examPerson) => (examPerson["identities"] as List<dynamic>)
                  .map((identity) => "${identity["firstName"]} ${identity["lastName"]}"))
              .toList(),
          date: date);
    }).toList();
  }

  Future<List<Study>> myStudies() async {
    final resources = await _callRestApi("slc.lib.sm/allStudies");
    return resources.map((resource) {
      final study = resource["content"]["studyBasicDto"];

      return Study(
          id: study["id"],
          germanName: study["studyName"]["value"],
          localizedName: _getLocalized(study["studyName"])!,
          localizedDegree: _getLocalized(study["basicStudyProgrammeLibDto"]["degreeType"]["name"])!);
    }).toList();
  }

  void logout() {
    isAuthenticated.value = false;
    currentAuthTokens = null;
    _storeAuthTokens();
  }
}
