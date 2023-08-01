import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';

part 'letter_lessons.g.dart';

@JsonSerializable()
class LetterLesson {
  String name;
  int progress;
  bool isUnlocked;
  Level level1;
  Level level2;
  Level level3;
  Level level4;
  Level level5;

  LetterLesson({
    required this.name,
    required this.progress,
    required this.isUnlocked,
    required this.level1,
    required this.level2,
    required this.level3,
    required this.level4,
    required this.level5,
  });

  factory LetterLesson.fromJson(Map<String, dynamic> json) =>
      _$LetterLessonFromJson(json);
  Map<String, dynamic> toJson() => _$LetterLessonToJson(this);
}

@JsonSerializable()
class Level {
  String description;
  List<String>? texts;
  List<dynamic>? sounds;
  List<dynamic>? images;
  List<dynamic>? correctAnswers;
  List<dynamic>? answers;

  Level({
    required this.description,
    this.texts,
    this.sounds,
    this.images,
    this.correctAnswers,
    this.answers,
  });

  factory Level.fromJson(Map<String, dynamic> json) => _$LevelFromJson(json);
  Map<String, dynamic> toJson() => _$LevelToJson(this);
}

Future<void> initLetterLessonData() async {
  final letterAa = LetterLesson(
    name: "Aa",
    progress: 0,
    isUnlocked: true,
    level1: Level(
      description: "The letter Aa",
      texts: [
        "This is the letter Aa. It has many different sounds.",
        "This is an apple. The letter Aa in apple sounds like:",
        "Look! It's raining. The Aa in rain sounds like:"
      ],
      sounds: [
        null,
        "assets/sounds/a_sound_female_UK.mp3",
        "assets/sounds/ai_sound_female_UK.mp3"
      ],
      images: [null, "assets/images/apple.png", "assets/images/rain.png"],
    ),
    level2: Level(
      description: "Which one sounds like the letter Aa?",
      correctAnswers: [
        "assets/sounds/a_sound_female_UK.mp3",
        "assets/sounds/ai_sound_female_UK.mp3"
      ],
    ),
    level3: Level(
      description: "How to write the letter Aa?",
      texts: [
        "This is how to write the letter Aa",
        "Let's start with the capital letter A. This is how to write it",
        "And this is how to write the small letter a"
      ],
      images: [
        null,
        "assets/images/capital_a_trace.gif",
        "assets/images/small_a_trace.gif"
      ],
    ),
    level4: Level(
      description: "Please write the letter Aa.",
      answers: ["A", "a"],
    ),
    level5: Level(
      description: "Which one is the letter Aa?",
      correctAnswers: [null, null, null, null, null, null],
    ),
  );

  final letterBb = LetterLesson(
      name: "Bb",
      progress: 0,
      isUnlocked: true,
      level1: Level(
        description: "The letter Bb",
        texts: [
          "This is the letter Bb. It only has one sound.",
          "The b in boy sounds like:",
          "The b in bat sounds like:"
        ],
        sounds: [
          null,
          "assets/sounds/b_sound_female_UK.mp3",
          "assets/sounds/b_sound_female_UK.mp3"
        ],
        images: [null, "assets/images/boy.png", "assets/images/bat.png"],
      ),
      level2: Level(
        description: "Which one sounds like the letter Bb?",
        correctAnswers: ["assets/sounds/b_sound_female_UK.mp3"],
      ),
      level3: Level(
        description: "How to write the letter Bb?",
        texts: [
          "This is how to write the letter Bb",
          "Let's start with the capital letter B. This is how to write it",
          "And this is how to write the small letter b"
        ],
        images: [
          null,
          "assets/images/capital_b_trace.gif",
          "assets/images/small_b_trace.gif"
        ],
      ),
      level4: Level(
          description: "Please write the letter Bb.", answers: ["B", "b"]),
      level5: Level(
          description: "Which one is the letter Bb?",
          correctAnswers: [null, null, null, null, null, null]));

  final letterCc = LetterLesson(
      name: "Cc",
      progress: 0,
      isUnlocked: true,
      level1: Level(description: "The letter Cc", texts: [
        "This is the letter Cc. It has many different sounds.",
        "The c in cat sounds like:",
        "The c in chair sounds like:"
      ], sounds: [
        null,
        "assets/sounds/c_sound_female_UK.mp3",
        "assets/sounds/ch-chair_sound_female_UK.mp3"
      ], images: [
        null,
        "assets/images/cat.png",
        "assets/images/chair.png"
      ]),
      level2: Level(
        description: "Which one sounds like the letter Cc?",
        correctAnswers: [
          "assets/sounds/c_sound_female_UK.mp3",
          "assets/sounds/ch-chair_sound_female_UK.mp3"
        ],
      ),
      level3: Level(
        description: "How to write the letter Cc?",
        texts: [
          "This is how to write the letter Cc",
          "Let's start with the capital letter C. This is how to write it",
          "And this is how to write the small letter c"
        ],
        images: [
          null,
          "assets/images/capital_c_trace.gif",
          "assets/images/small_c_trace.gif"
        ],
      ),
      level4: Level(
          description: "Please write the letter Cc.", answers: ["C", "c"]),
      level5: Level(
          description: "Which one is the letter Cc?",
          correctAnswers: [null, null, null, null, null, null]));

  final jsonString =
      json.encode([letterAa.toJson(), letterBb.toJson(), letterCc.toJson()]);
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/letter_lessons.json');
  await file.writeAsString(jsonString);
}

Future<void> changeProgressValueBy(String lessonName, int value) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/letter_lessons.json');

  try {
    final jsonString = await file.readAsString();
    final List<dynamic> jsonData = json.decode(jsonString);

    List<LetterLesson> letterLessons = jsonData.map((lesson) {
      return LetterLesson.fromJson(lesson);
    }).toList();

    // Find the specific LetterLesson you want to update
    LetterLesson? lessonToUpdate =
        letterLessons.firstWhere((element) => element.name == lessonName);

    if (lessonToUpdate != null) {
      // Update the progress value
      lessonToUpdate.progress += value;

      // Write the updated JSON data back to the file
      final updatedJsonData =
          letterLessons.map((lesson) => lesson.toJson()).toList();
      await file.writeAsString(json.encode(updatedJsonData));
    } else {
      print('LetterLesson with name $lessonName not found in JSON file');
    }
  } catch (e) {
    print('Error reading/writing letter_lessons.json: $e');
  }
}
