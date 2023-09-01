import 'package:campus_flutter/departuresComponent/model/departure.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mvv_response.g.dart';

@JsonSerializable()
class MvvResponse {
  @JsonKey(name: "stopEvents")
  final List<Departure> departures;

  MvvResponse({required this.departures});

  factory MvvResponse.fromJson(Map<String, dynamic> json) => _$MvvResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MvvResponseToJson(this);
}
