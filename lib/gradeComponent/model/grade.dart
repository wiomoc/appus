import 'package:campus_flutter/searchComponent/model/comparison_token.dart';
import 'package:campus_flutter/searchComponent/protocols/searchable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'grade.g.dart';

@JsonSerializable()
class Grade extends Searchable {
  String get id {
    return "${date.toIso8601String()}-$lvNumber";
  }

  @JsonKey(name: "datum")
  final DateTime date;
  @JsonKey(name: "lv_nummer")
  final String lvNumber;
  @JsonKey(name: "lv_semester")
  final String semester;
  @JsonKey(name: "lv_titel")
  String title;
  @JsonKey(name: "pruefer_nachname")
  final String examiner;
  @JsonKey(name: "uninotenamekurz")
  final String? grade;
  @JsonKey(name: "exam_typ_name")
  final String examType;
  @JsonKey(name: "modus")
  final String modus;
  @JsonKey(name: "studienidentifikator")
  String studyID;
  @JsonKey(name: "studienbezeichnung")
  final String studyDesignation;
  @JsonKey(name: "st_studium_nr")
  final String studyNumber;

  String get modusShort {
    switch (modus) {
      case "Schriftlich":
        return "Written";
      case "Beurteilt/immanenter Prüfungscharakter":
        return "Graded";
      case "Schriftlich und Mündlich":
        return "Written/Oral";
      case "Mündlich":
        return "Oral";
      default:
        return "Unknown";
    }
  }

  Grade(
      {required this.date,
      required this.lvNumber,
      required this.semester,
      required this.title,
      required this.examiner,
      required this.grade,
      required this.examType,
      required this.modus,
      required this.studyID,
      required this.studyDesignation,
      required this.studyNumber});

  factory Grade.fromJson(Map<String, dynamic> json) => _$GradeFromJson(json);

  Map<String, dynamic> toJson() => _$GradeToJson(this);

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<ComparisonToken> get comparisonTokens => [
        ComparisonToken(value: title),
        ComparisonToken(value: examiner),
        ComparisonToken(value: grade ?? "", type: ComparisonTokenType.raw),
        ComparisonToken(value: lvNumber),
        ComparisonToken(value: modus),
        ComparisonToken(value: semester),
        ComparisonToken(value: studyDesignation),
      ];
}

@JsonSerializable()
class GradeData {
  @JsonKey(name: "rowset")
  Grades? gradesAttribute;

  GradeData({required this.gradesAttribute});

  factory GradeData.fromJson(Map<String, dynamic> json) =>
      _$GradeDataFromJson(json);

  Map<String, dynamic> toJson() => _$GradeDataToJson(this);
}

@JsonSerializable()
class Grades {
  @JsonKey(name: "row")
  final List<Grade> personalGrades;

  Grades({required this.personalGrades});

  factory Grades.fromJson(Map<String, dynamic> json) => _$GradesFromJson(json);

  Map<String, dynamic> toJson() => _$GradesToJson(this);
}
