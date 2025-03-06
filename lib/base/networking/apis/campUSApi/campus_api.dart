import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash/stash_api.dart';

import '../../../../providers_get_it.dart';
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

class CampusApi {
  static const String authTokenPrefKey = "campus_auth_token";

  late final Future<void> isInitialized;
  final ValueNotifier<bool?> isAuthenticated = ValueNotifier(null);

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
        debugPrint(error.toString());
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
    final response = await call("ee/rest/$path", params, requireAuth: requireAuth, appendAccessToken: requireAuth);
    final Map<String, dynamic> responseData = response.data;
    final resource = responseData[resourcesKey];
    if (resource == null) {
      throw CampusApiException("${responseData["status"]} - ${responseData["title"]}");
    }
    return resource;
  }

  Future<void> _refreshToken() async {
    final response = await call("ee/rest/auth/token/refresh", null, method: "post", suppressTokenRefresh: true);
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

  Future<Response<dynamic>> call(String path, Map<String, dynamic>? params,
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
    if (response.statusCode == 401 && appendAccessToken) {
      if (suppressTokenRefresh) {
        throw CampusApiException("Could not refresh access token");
      }
      await _refreshToken();
      return call(path, params,
          requireAuth: requireAuth, responseType: responseType, appendAccessToken: true, suppressTokenRefresh: true);
    }
    return response;
  }

  static String? getLocalized(Map<String, dynamic>? translatable) {
    final expectedLang = Intl.getCurrentLocale().startsWith("de") ? "de" : "en";
    final List<dynamic>? translationList = translatable?["translations"]?["translation"];
    return translationList?.where((translation) => translation["lang"] == expectedLang).firstOrNull?["value"] ??
        translationList?.first["value"];
  }

  void logout() {
    isAuthenticated.value = false;
    currentAuthTokens = null;
    _storeAuthTokens();
    final cache = getIt<Cache<Map>>();
    cache.clear();
  }
}
