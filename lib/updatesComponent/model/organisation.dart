import 'package:json_annotation/json_annotation.dart';

import 'news.dart';

part 'organisation.g.dart';

@JsonSerializable()
class Link {
  final String title;
  final String? icon;
  final String href;

  Link({required this.title, required this.icon, required this.href});

  factory Link.fromJson(Map<String, dynamic> json) => _$LinkFromJson(json);

  Map<String, dynamic> toJson() => _$LinkToJson(this);
}

@JsonSerializable()
class Event {
  final String title;
  final String? icon;
  final String href;
  final DateTime date;

  Event({required this.title, required this.icon, required this.href, required this.date});

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  Map<String, dynamic> toJson() => _$EventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Organisation {
  final String id;
  final String iconUrl;
  final String name;
  final List<Link> links;
  final List<Event> events;
  final List<News> news;

  Organisation(
      {required this.id,
        required this.iconUrl,
        required this.name,
        required this.links,
        required this.events,
        required this.news});

  factory Organisation.fromJson(Map<String, dynamic> json) => _$OrganisationFromJson(json);

  Map<String, dynamic> toJson() => _$OrganisationToJson(this);
}