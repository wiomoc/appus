import 'package:json_annotation/json_annotation.dart';

part 'study.g.dart';

@JsonSerializable()
class Study {
  final int id;
  final String germanName;
  final String localizedName;
  final String localizedDegree;

  Study({required this.id, required this.germanName, required this.localizedName, required this.localizedDegree});

  factory Study.fromJson(Map<String, dynamic> json) => _$StudyFromJson(json);

  Map<String, dynamic> toJson() => _$StudyToJson(this);

  @override
  String toString() {
    return 'Study{id: $id, germanName: $germanName, localizedName: $localizedName, localizedDegree: $localizedDegree}';
  }
}
