import 'package:campus_flutter/vvsComponent/model/departure.dart';
import 'package:dio/dio.dart';

import '../views/departures_details_view.dart';

class DeparturesService {
  static Future<List<Departure>> fetchDepartures(Station station) async {
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
            timeEstimated: stopEvent["departureTimeEstimated"] != null? DateTime.parse(stopEvent["departureTimeEstimated"]): null,
            number: stopEvent["transportation"]["number"],
            vehicleType: VehicleType.fromVVSString(stopEvent["transportation"]["product"]["name"]),
            destination: stopEvent["transportation"]["destination"]["name"],
            platform: stopEvent["location"]["disassembledName"]))
        .toList();
  }
}
