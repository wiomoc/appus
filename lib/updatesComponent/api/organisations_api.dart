import 'package:campus_flutter/homeComponent/contactComponent/api/my_studies.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../base/helpers/api_operation.dart';
import '../../base/networking/apis/appusBackendApi/appus_backend_api.dart';
import '../model/organisation.dart';

class OrganisationsApiOperation extends ApiOperation<List<Organisation>> {

  @override
  String get cacheKey => "organisations";

  @override
  List<Organisation> fromCached(Map<String, dynamic> map) =>
      (map["orgs"] as List<dynamic>).map((orgJson) => Organisation.fromJson(orgJson)).toList();

  @override
  Map<String, dynamic> toCached(List<Organisation> object) => {"orgs": object.map((org) => org.toJson()).toList()};

  @override
  Future<List<Organisation>> fetchOnline() async {
    final studies = await fetchAndWait(MyStudiesApiOperation(), const Duration(days: 5));
    final client = Dio();
    final organisationsJson = await client.get("$appusBackendBaseUrl/organisations",
        queryParameters: {"studies": studies.data.map((study) => study.germanName).toList(), "lang": Intl.getCurrentLocale().startsWith("de") ? "de" : "en"},
        options: Options(
          responseType: ResponseType.json,
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

    return (organisationsJson.data as List<dynamic>)
        .map((organisationJson) => Organisation.fromJson(organisationJson))
        .toList();
  }
}
