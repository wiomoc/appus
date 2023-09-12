import 'package:campus_flutter/base/extensions/cast.dart';

import '../../base/helpers/api_operation.dart';
import '../../base/networking/apis/campUSApi/campus_api.dart';
import '../../providers_get_it.dart';
import '../model/room_search_entry.dart';

class RoomSearchApiOperation extends ApiOperation<List<RoomSearchEntry>> {
  final String searchText;

  RoomSearchApiOperation(this.searchText);

  @override
  String get cacheKey => "roomSearch$searchText";

  @override
  List<RoomSearchEntry> fromCached(Map<String, dynamic> map) =>
      (map["rooms"] as List<dynamic>).map((courseJson) => RoomSearchEntry.fromJson(courseJson)).toList();

  @override
  Map<String, dynamic> toCached(List<RoomSearchEntry> object) =>
      {"rooms": object.map((room) => room.toJson()).toList()};

  @override
  Future<List<RoomSearchEntry>> fetchOnline() async {
    final campusApi = getIt.get<CampusApi>();
    final roomsJson = await campusApi
        .callRestApi("brm.rbm.search/rooms", params: {"q": searchText});
    return cast<List<dynamic>>(roomsJson)!
        .map((room) => RoomSearchEntry.fromJson(room["content"]["roomSearchDto"]))
        .toList(growable: false);
  }
}
