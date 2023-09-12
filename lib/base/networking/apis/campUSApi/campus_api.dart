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
  final String username;
  final String password;
  final String profile;
  final String psessionid;
  final String accessToken;

  AuthTokens(
      {required this.username,
      required this.password,
      required this.profile,
      required this.psessionid,
      required this.accessToken});

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
      username: json["username"]!,
      password: json["password"]!,
      profile: json["profile"]!,
      psessionid: json["psessionid"]!,
      accessToken: json["accessToken"]!);

  Map<String, String> toJson() => {
        "username": username,
        "password": password,
        "profile": profile,
        "psessionid": psessionid,
        "accessToken": accessToken
      };

  @override
  String toString() {
    return 'AuthState{username: $username, profile: $profile, psessionid: $psessionid, accessToken: $accessToken}';
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
        username: username,
        password: password,
        profile: cookies["CO_PROFILE"]!.value,
        psessionid: cookies["PSESSIONID"]!.value,
        accessToken: accessToken);
    _storeAuthTokens();
  }

  Future<List<dynamic>> callRestApi(String path,
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
    final responseData = response.data;
    String? newAccessToken;
    if (response is Map<String, dynamic>) {
      newAccessToken = responseData["accessToken"];
    }
    if (newAccessToken != null) {
      currentAuthTokens = AuthTokens(
          username: currentAuthTokens!.username,
          password: currentAuthTokens!.password,
          profile: currentAuthTokens!.profile,
          psessionid: currentAuthTokens!.psessionid,
          accessToken: newAccessToken);
      _storeAuthTokens();
    } else {
      try {
        await login(currentAuthTokens!.username, currentAuthTokens!.password);
      } on InvalidCampusCredentialsException catch (_) {
        currentAuthTokens = null;
        isAuthenticated.value = false;
        _storeAuthTokens();
        return;
      } catch (_) {
        throw CampusApiException("Could not refresh access token");
      }
    }
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

  static String? getLocalized(Map<String, dynamic>? translatable) {
    final expectedLang = "de";
    final List<dynamic>? translationList = translatable?["translations"]?["translation"];
    return translationList?.where((translation) => translation["lang"] == expectedLang).firstOrNull?["value"] ??
        translationList?.first["value"];
  }



  Future<List<Study>> myStudies() async {
    final resources = await callRestApi("slc.lib.sm/allStudies");
    return resources.map((resource) {
      final study = resource["content"]["studyBasicDto"];

      return Study(
          id: study["id"],
          germanName: study["studyName"]["value"],
          localizedName: getLocalized(study["studyName"])!,
          localizedDegree: getLocalized(study["basicStudyProgrammeLibDto"]["degreeType"]["name"])!);
    }).toList();
  }

  void logout() {
    isAuthenticated.value = false;
    currentAuthTokens = null;
    _storeAuthTokens();
  }
}
