// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'letter_lessons.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LetterLesson _$LetterLessonFromJson(Map<String, dynamic> json) => LetterLesson(
      name: json['name'] as String,
      progress: json['progress'] as int,
      score: json['score'] as int,
      isUnlocked: json['isUnlocked'] as bool,
      level1: Level.fromJson(json['level1'] as Map<String, dynamic>),
      level2: Level.fromJson(json['level2'] as Map<String, dynamic>),
      level3: Level.fromJson(json['level3'] as Map<String, dynamic>),
      level4: Level.fromJson(json['level4'] as Map<String, dynamic>),
      level5: Level.fromJson(json['level5'] as Map<String, dynamic>),
      level6: Level.fromJson(json['level6'] as Map<String, dynamic>),
      level7: Level.fromJson(json['level7'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LetterLessonToJson(LetterLesson instance) =>
    <String, dynamic>{
      'name': instance.name,
      'progress': instance.progress,
      'score': instance.score,
      'isUnlocked': instance.isUnlocked,
      'level1': instance.level1,
      'level2': instance.level2,
      'level3': instance.level3,
      'level4': instance.level4,
      'level5': instance.level5,
      'level6': instance.level6,
      'level7': instance.level7,
    };

Level _$LevelFromJson(Map<String, dynamic> json) => Level(
      description: json['description'] as String,
      texts:
          (json['texts'] as List<dynamic>?)?.map((e) => e as String).toList(),
      sounds: json['sounds'] as List<dynamic>?,
      images: json['images'] as List<dynamic>?,
      correctAnswers: json['correctAnswers'] as List<dynamic>?,
      answers: json['answers'] as List<dynamic>?,
    );

Map<String, dynamic> _$LevelToJson(Level instance) => <String, dynamic>{
      'description': instance.description,
      'texts': instance.texts,
      'sounds': instance.sounds,
      'images': instance.images,
      'correctAnswers': instance.correctAnswers,
      'answers': instance.answers,
    };
