import 'package:campus_flutter/base/helpers/api_operation.dart';
import 'package:campus_flutter/vvsComponent/model/departure.dart';
import 'package:dio/dio.dart';

import '../views/departures_details_view.dart';

class DeparturesApiOperation extends ApiOperation<List<Departure>> {
  final Station station;

  DeparturesApiOperation(this.station);

  @override
  String get cacheKey => "dep${station.id}";

  @override
  List<Departure> fromCached(Map<String, dynamic> map) =>
      (map["deps"] as List<dynamic>).map((courseJson) => Departure.fromJson(courseJson)).toList();

  @override
  Map<String, dynamic> toCached(List<Departure> object) =>
      {"deps": object.map((departure) => departure.toJson()).toList()};

  @override
  Future<List<Departure>> fetchOnline() async {

    final client = Dio();
    final response = await client.get("https://www3.vvs.de/mngvvs/XML_DM_REQUEST",
        queryParameters: {
          "SpEncId": 0,
          "coordOutputFormat": "EPSG:4326",
          "deleteAssignedStops": 1,
          "itdDate": "20230902",
          "itdTime": "1543",
          "limit": 40,
          "macroWebDep": true,
          "mode": "direct",
          "name_dm": station.id,
          "outputFormat": "rapidJSON",
          "serverInfo": 0,
          "type_dm": "any",
          "useRealtime": 1,
          "version": "10.2.10.139"
        },
        options: Options(responseType: ResponseType.json));

    return (response.data["stopEvents"]! as List<dynamic>)
        .map((stopEvent) => Departure(
        timePlanned: DateTime.parse(stopEvent["departureTimePlanned"]),
        timeEstimated: stopEvent["departureTimeEstimated"] != null
            ? DateTime.parse(stopEvent["departureTimeEstimated"])
            : null,
        number: stopEvent["transportation"]["number"],
        vehicleType: VehicleType.fromVVSString(stopEvent["transportation"]["product"]["name"]),
        destination: stopEvent["transportation"]["destination"]["name"],
        platform: stopEvent["location"]["disassembledName"]))
        .toList();
  }
}


