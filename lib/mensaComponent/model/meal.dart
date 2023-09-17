import 'package:json_annotation/json_annotation.dart';

part 'meal.g.dart';

List<String> _splitString(String? string) {
  if (string == null) return [];
  return string.split(",");
}

String _joinString(List<String> strings) => strings.join(",");


@JsonSerializable()
class Meal {
  final String category;
  final String meal;
  final String? description;
  @JsonKey(name: "price1")
  final String price;
  @JsonKey(name: "foto")
  final String? photoPath;

  @JsonKey(fromJson: _splitString, toJson: _joinString)
  final List<String> additives;

  Meal(
      {required this.category,
      required this.meal,
      required this.description,
      required this.price,
      required this.photoPath,
      required this.additives});

  String? get photoUrl {
    if (photoPath == null || photoPath == "") return null;
    return "https://sws2.maxmanager.xyz/assets/$photoPath";
  }

  String get name {
    if (description == null || description == "") return meal;
    return "$meal $description";
  }

  factory Meal.fromJson(Map<String, dynamic> json) => _$MealFromJson(json);

  Map<String, dynamic> toJson() => _$MealToJson(this);
}


