import 'package:campus_flutter/homeComponent/contactComponent/api/my_studies.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../base/helpers/api_operation.dart';
import '../../base/networking/apis/appusBackendApi/appus_backend_api.dart';
import '../model/news.dart';

class NewsApiOperation extends ApiOperation<List<News>> {

  @override
  String get cacheKey => "news";

  @override
  List<News> fromCached(Map<String, dynamic> map) =>
      (map["news"] as List<dynamic>).map((newsJson) => News.fromJson(newsJson)).toList();

  @override
  Map<String, dynamic> toCached(List<News> object) =>
      {"news": object.map((news) => news.toJson()).toList()};

  @override
  Future<List<News>> fetchOnline() async {
    final studies = await fetchAndWait(MyStudiesApiOperation(), const Duration(days: 5));
    final client = Dio();
    final newsJson = await client.get("$appusBackendBaseUrl/news/for_study",
        queryParameters: {"studies": studies.data.map((study) => study.germanName).toList(), "lang": Intl.getCurrentLocale().startsWith("de") ? "de" : "en"},
        options: Options(
          responseType: ResponseType.json,
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

    return (newsJson.data as List<dynamic>)
        .map((organisationJson) => News.fromJson(organisationJson))
        .toList();
  }
}
