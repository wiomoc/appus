import 'package:json_annotation/json_annotation.dart';

part 'room_location.g.dart';

@JsonSerializable()
class Room {
  final int id;
  final String number;
  final String? usage;
  final int? seats;

  Room({required this.id, required this.number, required this.usage, required this.seats});

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

  Map<String, dynamic> toJson() => _$RoomToJson(this);
}

@JsonSerializable()
class RoomFloorPosition {
  final int id;
  final String number;
  final List<int> position;

  RoomFloorPosition({required this.id, required this.number, required this.position});

  factory RoomFloorPosition.fromJson(Map<String, dynamic> json) => _$RoomFloorPositionFromJson(json);

  Map<String, dynamic> toJson() => _$RoomFloorPositionToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Floor {
  final int id;
  final String name;
  final String? planImageUrl;
  final List<RoomFloorPosition> rooms;

  Floor({required this.id, required this.name, required this.planImageUrl, required this.rooms});

  factory Floor.fromJson(Map<String, dynamic> json) => _$FloorFromJson(json);

  Map<String, dynamic> toJson() => _$FloorToJson(this);
}

@JsonSerializable()
class Building {
  final int aref;
  final String street;
  final String city;
  final List<double>? coordinates;
  final String? geojson;

  Building(
      {required this.aref, required this.street, required this.city, required this.coordinates, required this.geojson});

  factory Building.fromJson(Map<String, dynamic> json) => _$BuildingFromJson(json);

  Map<String, dynamic> toJson() => _$BuildingToJson(this);
}

@JsonSerializable()
class RoomLocation {
  final Room room;
  final Floor floor;
  final Building building;

  RoomLocation({required this.room, required this.floor, required this.building});

  factory RoomLocation.fromJson(Map<String, dynamic> json) => _$RoomLocationFromJson(json);

  Map<String, dynamic> toJson() => _$RoomLocationToJson(this);
}
