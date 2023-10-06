import 'package:json_annotation/json_annotation.dart';

part 'building_summary.g.dart';

@JsonSerializable()
class BuildingSummary {
  @JsonKey(name: "addr_street")
  final String street;
  @JsonKey(name: "addr_city")
  final String city;
  @JsonKey(name: "id")
  final int aref;

  BuildingSummary({required this.street, required this.city, required this.aref});

  factory BuildingSummary.fromJson(Map<String, dynamic> json) => _$BuildingSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$BuildingSummaryToJson(this);
}
