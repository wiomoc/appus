import 'package:json_annotation/json_annotation.dart';

part 'organisation.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Link {
  final String localizedTitle;
  final String? icon;
  final String href;

  Link({required this.localizedTitle, required this.icon, required this.href});

  factory Link.fromJson(Map<String, dynamic> json) => _$LinkFromJson(json);

  Map<String, dynamic> toJson() => _$LinkToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Event {
  final String localizedTitle;
  final String? icon;
  final String href;
  final DateTime date;

  Event({required this.localizedTitle, required this.icon, required this.href, required this.date});

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  Map<String, dynamic> toJson() => _$EventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class News {
  final String? localizedTitle;
  final String? localizedText;
  final String? image;
  final String href;
  final DateTime date;

  News({this.localizedTitle, this.localizedText, this.image, required this.href, required this.date});

  factory News.fromJson(Map<String, dynamic> json) => _$NewsFromJson(json);

  Map<String, dynamic> toJson() => _$NewsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Organisation {
  final String id;
  final String iconUrl;
  final String localizedName;
  final List<Link> links;
  final List<Event> events;
  final List<News> news;

  Organisation(
      {required this.id,
        required this.iconUrl,
        required this.localizedName,
        required this.links,
        required this.events,
        required this.news});

  factory Organisation.fromJson(Map<String, dynamic> json) => _$OrganisationFromJson(json);

  Map<String, dynamic> toJson() => _$OrganisationToJson(this);
}