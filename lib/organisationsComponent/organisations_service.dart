import 'package:dio/dio.dart';

import 'models.dart';

class OrganisationsService {
  Future<List<Organisation>> fetchOrganisations(List<String> ids) async {
    final client = Dio();
    final organisationsJson = await client.get("http://localhost:8000/organisations",
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
