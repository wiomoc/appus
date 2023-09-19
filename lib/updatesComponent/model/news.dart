import 'package:json_annotation/json_annotation.dart';

part 'news.g.dart';

@JsonSerializable()
class News {
  final String? title;
  final String? text;
  final String? image;
  final String link;
  final DateTime date;

  News({this.title, this.text, this.image, required this.link, required this.date});

  factory News.fromJson(Map<String, dynamic> json) => _$NewsFromJson(json);

  Map<String, dynamic> toJson() => _$NewsToJson(this);
}
