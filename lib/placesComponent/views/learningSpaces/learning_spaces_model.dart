import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'learning_spaces_model.g.dart';

@JsonSerializable()
class Translatable {
  final String id;
  final String de;
  final String en;

  Translatable({required this.id, required this.de, required this.en});

  factory Translatable.fromJson(Map<String, dynamic> json) => _$TranslatableFromJson(json);

  Map<String, dynamic> toJson() => _$TranslatableToJson(this);

  @override
  String toString() {
    final locale = Intl.getCurrentLocale();
    if (locale.startsWith("de")) {
      return de;
    } else {
      return en;
    }
  }
}

@JsonSerializable()
class Campus {
  final String id;
  final String label;

  Campus({required this.id, required this.label});

  factory Campus.fromJson(Map<String, dynamic> json) => _$CampusFromJson(json);

  Map<String, dynamic> toJson() => _$CampusToJson(this);

  @override
  String toString() {
    return label;
  }
}

@JsonSerializable()
class Room {
  final String id;
  final String name;
  final String address;
  final int? raumKey;
  final String location;
  final String type;
  final String? tikName;
  final String accessGroups;
  final List<({String days, String hours})> open;
  final ({double lat, double lng}) coordinates;
  final int? seats;
  final List<String>? equipment;
  final String? thumbnail;
  final List<String>? images;

  Room(
      {required this.id,
      required this.name,
      required this.address,
      required this.raumKey,
      required this.location,
      required this.type,
      required this.tikName,
      required this.accessGroups,
      required this.open,
      required this.coordinates,
      required this.seats,
      required this.equipment,
      required this.thumbnail,
      required this.images});

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

  Map<String, dynamic> toJson() => _$RoomToJson(this);
}

@JsonSerializable()
class LearningSpaces {
  final List<Translatable> accessGroups;
  final List<Campus> locations;
  final List<Translatable> types;
  final List<Translatable> equipment;
  final List<Room> rooms;

  LearningSpaces(
      {required this.accessGroups,
      required this.locations,
      required this.types,
      required this.equipment,
      required this.rooms});

  factory LearningSpaces.fromJson(Map<String, dynamic> json) => _$LearningSpacesFromJson(json);

  Map<String, dynamic> toJson() => _$LearningSpacesToJson(this);
}
