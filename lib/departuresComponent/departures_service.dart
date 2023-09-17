import 'package:shared_preferences/shared_preferences.dart';

class Station {
  final String id;
  final String name;

  const Station(this.id, this.name);
}

const stations = [
  Station("de:08111:6008", "Universität"),
  Station("de:08111:6021", "Universität (Schleife)"),
  Station("de:08111:2603", "Schrane"),
  Station("de:08111:6112", "Hauptbf (Arnulf-Klett-Platz)"),
  Station("de:08111:6115", "Hauptbahnhof (oben)"),
  Station("de:08111:6118", "Hauptbahnhof (tief)"),
  Station("de:08111:229", "Börsenplatz"),
  Station("de:08111:2203", "Katharinenhospital"),
];

const lastStationKey = "lastStation";

Future<void> setLastStation(Station station) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.setString(lastStationKey, station.id);
}

Future<Station> getLastStation() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  final lastMensaLocationId = sharedPreferences.getString(lastStationKey);
  return stations.firstWhere((station) => station.id == lastMensaLocationId, orElse: () => stations.first);
}
