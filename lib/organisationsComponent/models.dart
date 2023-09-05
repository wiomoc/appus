import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

@JsonSerializable()
class Link {
  @JsonKey(name: "localized_title")
  final String localizedTitle;
  final String? icon;
  final String href;

  Link({required this.localizedTitle, required this.icon, required this.href});

  factory Link.fromJson(Map<String, dynamic> json) => _$LinkFromJson(json);

  Map<String, dynamic> toJson() => _$LinkToJson(this);
}

@JsonSerializable()
class Event {
  @JsonKey(name: "localized_title")
  final String localizedTitle;
  final String? icon;
  final String href;
  final DateTime date;

  Event({required this.localizedTitle, required this.icon, required this.href, required this.date});

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  Map<String, dynamic> toJson() => _$EventToJson(this);
}

@JsonSerializable()
class News {
  @JsonKey(name: "localized_title")
  final String? localizedTitle;
  @JsonKey(name: "localized_text")
  final String? localizedText;
  final String? image;
  final String href;
  final DateTime date;

  News({this.localizedTitle, this.localizedText, this.image, required this.href, required this.date});

  factory News.fromJson(Map<String, dynamic> json) => _$NewsFromJson(json);

  Map<String, dynamic> toJson() => _$NewsToJson(this);
}

@JsonSerializable()
class Organisation {
  final String id;
  @JsonKey(name: "icon_url")
  final String iconUrl;
  @JsonKey(name: "localized_name")
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