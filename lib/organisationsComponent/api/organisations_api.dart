import 'package:dio/dio.dart';

import '../../base/helpers/api_operation.dart';
import '../../base/networking/apis/appusBackendApi/appus_backend_api.dart';
import '../model/organisation.dart';

class OrganisationsApiOperation extends ApiOperation<List<Organisation>> {
  final List<String> ids;

  OrganisationsApiOperation(this.ids);

  @override
  String get cacheKey => "organisations";

  @override
  List<Organisation> fromCached(Map<String, dynamic> map) =>
      (map["orgs"] as List<dynamic>).map((courseJson) => Organisation.fromJson(courseJson)).toList();

  @override
  Map<String, dynamic> toCached(List<Organisation> object) =>
      {"orgs": object.map((course) => course.toJson()).toList()};

  @override
  Future<List<Organisation>> fetchOnline() async {
    final client = Dio();
    final organisationsJson = await client.get("$appusBackendBaseUrl/organisations",
        queryParameters: {"orgs": ids},
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
