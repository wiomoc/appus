import 'package:campus_flutter/searchComponent/protocols/searchable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../searchComponent/model/comparison_token.dart';

part 'room_search_entry.g.dart';

@JsonSerializable()
class RoomSearchEntry extends Searchable {
  final int id;
  final String code;
  final String additionalInfo;
  final String address;

  RoomSearchEntry({required this.id, required this.code, required this.additionalInfo, required this.address});

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<ComparisonToken> get comparisonTokens =>
      [ComparisonToken(value: additionalInfo), ComparisonToken(value: address)];

  factory RoomSearchEntry.fromJson(Map<String, dynamic> json) => _$RoomSearchEntryFromJson(json);

  Map<String, dynamic> toJson() => _$RoomSearchEntryToJson(this);
}
