import 'package:campus_flutter/base/classes/location.dart';

enum Campus {
  vaihingen("Vaihingen"),
  stadtmitte("Stadtmitte");

  final String name;

  const Campus(this.name);
}

extension CampusExtension on Campus {
  static List<Campus> get campusPlaces {
    return [
      Campus.vaihingen,
      Campus.stadtmitte,
    ];
  }

  String? get image {
    switch (this) {
      case Campus.vaihingen:
        return "assets/images/campus/campus-stamm.jpeg";
      case Campus.stadtmitte:
        return "assets/images/campus/campus-olympia.jpg";
      default:
        return null;
    }
  }

  Location get location {
    switch (this) {
      case Campus.vaihingen:
        return Location(latitude: 48.14887567648079, longitude: 11.568029074814328);
      case Campus.stadtmitte:
        return Location(latitude: 48.17957305879896, longitude: 11.546601863009668);
    }
  }

  Map<Campus, Location> getAll() {
    return Map.fromEntries(Campus.values.map((e) => MapEntry(e, e.location)));
  }

  List<(String, int)> get popularRooms {
    switch (this) {
      case Campus.vaihingen:
        return [("V53.01", 7153), ("V57.01", 7007), ("V47.01", 6999)];
      case Campus.stadtmitte:
        return [("M17.01", 7215), ("M17.02", 7216)];
    }
  }

/*
  Station get defaultStation {
    switch (this) {
      case Campus.stammgelaende:
        return Station(
            name: "Technische Universität",
            apiName: "91000095",
            location: Location(
                latitude: 48.148145129847244, longitude: 11.566048520744298));
      case Campus.olympiapark:
        return Station(
            name: "Olympiazentrum",
            apiName: "91000350",
            location: Location(
                latitude: 48.17946648767361, longitude: 11.555783595899824));
      case Campus.klinikumRechts:
        return Station(
            name: "Max-Weber-Platz",
            apiName: "91000580",
            location: Location(
                latitude: 48.13573243097588, longitude: 11.599014647301777));
      case Campus.grosshadern:
        return Station(
            name: "Klinikum Großhadern",
            apiName: "91001540",
            location: Location(
                latitude: 48.10889880944028, longitude: 11.47363212095666));
      case Campus.garching:
        return Station(
            name: "Forschungszentrum",
            apiName: "1000460",
            location: Location(
                latitude: 48.26519145730091, longitude: 11.671545161597082));
      case Campus.freising:
        return Station(
            name: "Freising, Weihenstephan",
            apiName: "1002911",
            location: Location(
                latitude: 48.39799498961109, longitude: 11.723989661968458));
    }
  }

  List<Station> get allStations {
    switch (this) {
      case Campus.stammgelaende:
        return [
          defaultStation,
          Station(
              name: "Theresienstraße",
              apiName: "91000120",
              location: Location(
                  latitude: 48.1512235719802, longitude: 11.564211669898931)),
          Station(
              name: "Pinakotheken",
              apiName: "91000051",
              location: Location(
                  latitude: 48.148780089472, longitude: 11.571870970398924))
        ];
      case Campus.olympiapark:
        return [defaultStation];
      case Campus.klinikumRechts:
        return [
          defaultStation,
          Station(
              name: "Friedensengel/Villa Stuck",
              apiName: "91000073",
              location: Location(
                  latitude: 48.14074544433942, longitude: 11.600075277341709)),
        ];
      case Campus.grosshadern:
        return [
          defaultStation,
          Station(
              name: "Klinikum Großhadern Ost",
              apiName: "91001472",
              location: Location(
                  latitude: 48.11092668280441, longitude: 11.473909030506093)),
          Station(
              name: "Klinikum Großhadern Nord",
              apiName: "91001474",
              location: Location(
                  latitude: 48.11250562334001, longitude: 11.467122898318992))
        ];
      case Campus.garching:
        return [
          defaultStation,
          Station(
              name: "Lichtenbergstraße",
              apiName: "1002070",
              location: Location(
                  latitude: 48.26777168760462, longitude: 11.665502685140389))
        ];
      case Campus.freising:
        return [
          defaultStation,
          Station(
              name: "Freising, Forstzentrum",
              apiName: "1009413",
              location: Location(
                  latitude: 48.39924842116169, longitude: 11.716601891310122)),
          Station(
              name: "Freising, Weihenstephaner Berg",
              apiName: "1002617",
              location: Location(
                  latitude: 48.39581877364193, longitude: 11.725859432987532))
        ];
    }
  }*/
}
