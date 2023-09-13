import 'package:dio/dio.dart';

import '../../base/helpers/api_operation.dart';
import '../../base/networking/apis/appusBackendApi/appus_backend_api.dart';
import '../model/room_location.dart';


class BuildingLocationApiOperation extends ApiOperation<Building> {
  final int aref;

  BuildingLocationApiOperation(this.aref);

  @override
  String get cacheKey => "building$aref";

  @override
  Building fromCached(Map<String, dynamic> map) => Building.fromJson(map);

  @override
  Map<String, dynamic> toCached(Building object) => object.toJson();

  @override
  Future<Building> fetchOnline() async {
    final client = Dio();
    final roomLocationJson = await client.get("$appusBackendBaseUrl/map/building/$aref",
        options: Options(
          responseType: ResponseType.json,
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));
    return Building.fromJson(roomLocationJson.data);
  }
}