import 'package:json_annotation/json_annotation.dart';

part 'meal_model.g.dart';

List<String> _splitString(String? string) {
  if (string == null) return [];
  return string.split(",");
}

@JsonSerializable()
class Meal {
  final String category;
  final String meal;
  final String? description;
  @JsonKey(name: "price1")
  final String price;
  @JsonKey(name: "foto")
  final String? photoPath;

  @JsonKey(fromJson: _splitString)
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

@JsonSerializable(fieldRename: FieldRename.snake)
class RatingComment {
  final double stars;
  final String? comment;
  final DateTime date;
  final String? imageUrl;
  final String? thumbImageUrl;

  RatingComment(
      {required this.stars, required this.comment, required this.date, this.imageUrl, this.thumbImageUrl});

  factory RatingComment.fromJson(Map<String, dynamic> json) => _$RatingCommentFromJson(json);

  Map<String, dynamic> toJson() => _$RatingCommentToJson(this);
}

@JsonSerializable()
class Rating {
  final double? stars;
  final List<RatingComment> comments;

  Rating({required this.stars, required this.comments});

  factory Rating.fromJson(Map<String, dynamic> json) => _$RatingFromJson(json);

  Map<String, dynamic> toJson() => _$RatingToJson(this);
}
