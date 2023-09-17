import 'package:json_annotation/json_annotation.dart';

part 'rating.g.dart';


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