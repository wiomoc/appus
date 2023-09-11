import 'package:dio/dio.dart';

import '../../base/helpers/api_operation.dart';
import '../../base/networking/apis/appusBackendApi/appus_backend_api.dart';
import '../model/room_location.dart';


class RoomLocationApiOperation extends ApiOperation<RoomLocation> {
  final int roomId;

  RoomLocationApiOperation(this.roomId);

  @override
  String get cacheKey => "room$roomId";

  @override
  RoomLocation fromCached(Map<String, dynamic> map) => RoomLocation.fromJson(map);

  @override
  Map<String, dynamic> toCached(RoomLocation object) => object.toJson();

  @override
  Future<RoomLocation> fetchOnline() async {
    final client = Dio();
    final roomLocationJson = await client.get("$appusBackendBaseUrl/map/room/$roomId",
        options: Options(
          responseType: ResponseType.json,
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));
    return RoomLocation.fromJson(roomLocationJson.data);
  }
}