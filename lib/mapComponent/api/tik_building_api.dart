import 'package:dio/dio.dart';

import '../../base/helpers/api_operation.dart';
import '../model/building_summary.dart';

class TikBuildingApiOperation extends ApiOperation<List<BuildingSummary>> {
  @override
  String get cacheKey => "tikbuildings";

  @override
  List<BuildingSummary> fromCached(Map<String, dynamic> map) =>
      (map["buildings"] as List<dynamic>).map((buildingJson) => BuildingSummary.fromJson(buildingJson)).toList();

  @override
  Map<String, dynamic> toCached(List<BuildingSummary> object) =>  {"buildings": object.map((event) => event.toJson()).toList()};

  @override
  Future<List<BuildingSummary>> fetchOnline() async {
    final client = Dio();
    final roomLocationJson = await client.get("https://lageplan.uni-stuttgart.de/api/getArea.php",
        options: Options(
          responseType: ResponseType.json,
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));
    return (roomLocationJson.data as List<dynamic>)
        .map((buildingJson) => BuildingSummary.fromJson(buildingJson))
        .toList();
  }
}
