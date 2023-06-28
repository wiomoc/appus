// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tuition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tuition _$TuitionFromJson(Map<String, dynamic> json) => Tuition(
      amount: stringToDouble(json['soll'] as String),
      deadline: json['frist'] == null
          ? null
          : DateTime.parse(json['frist'] as String),
      semester: json['semester_bezeichnung'] as String?,
      semesterID: json['semester_id'] as String?,
    );

Map<String, dynamic> _$TuitionToJson(Tuition instance) => <String, dynamic>{
      'soll': instance.amount,
      'frist': instance.deadline?.toIso8601String(),
      'semester_bezeichnung': instance.semester,
      'semester_id': instance.semesterID,
    };

TuitionData _$TuitionDataFromJson(Map<String, dynamic> json) => TuitionData(
      profilesAttribute:
          Tuitions.fromJson(json['rowset'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TuitionDataToJson(TuitionData instance) =>
    <String, dynamic>{
      'rowset': instance.profilesAttribute,
    };

Tuitions _$TuitionsFromJson(Map<String, dynamic> json) => Tuitions(
      tuition: Tuition.fromJson(json['row'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TuitionsToJson(Tuitions instance) => <String, dynamic>{
      'row': instance.tuition,
    };