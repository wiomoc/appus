import 'package:dio/dio.dart';

import 'models.dart';

class MapService {
  Future<RoomLocation> fetchRoomLocation(int id) async {
    final client = Dio();
    final roomLocationJson = await client.get("http://10.53.31.135:8000/map/room/$id",
        options: Options(
          responseType: ResponseType.json,
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

    return RoomLocation.fromJson(roomLocationJson.data);
  }
}
