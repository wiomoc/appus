import 'package:json_annotation/json_annotation.dart';

part 'meal_model.g.dart';

@JsonSerializable()
class Meal {
  final String category;
  final String meal;
  final String? description;
  @JsonKey(name: "price1")
  final String price;
  @JsonKey(name: "foto")
  final String? photoPath;

  Meal(
      {required this.category,
        required this.meal,
        required this.description,
        required this.price,
        required this.photoPath});

  factory Meal.fromJson(Map<String, dynamic> json) => _$MealFromJson(json);

  Map<String, dynamic> toJson() => _$MealToJson(this);
}
