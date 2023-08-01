// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Assessment _$AssessmentFromJson(Map<String, dynamic> json) => Assessment(
      (json['questions'] as List<dynamic>).map((e) => e as int).toList(),
      json['isDyslexic'] as bool,
      json['dyslexiaScore'] as int,
    );

Map<String, dynamic> _$AssessmentToJson(Assessment instance) =>
    <String, dynamic>{
      'questions': instance.questions,
      'isDyslexic': instance.isDyslexic,
      'dyslexiaScore': instance.dyslexiaScore,
    };
