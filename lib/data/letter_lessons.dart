import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';

part 'letter_lessons.g.dart';

@JsonSerializable()
class LetterLesson {
  String name;
  int progress;
  int score;
  bool isUnlocked;
  Level level1;
  Level level2;
  Level level3;
  Level level4;
  Level level5;
  Level level6;
  Level level7;

  LetterLesson(
      {required this.name,
      required this.progress,
      required this.score,
      required this.isUnlocked,
      required this.level1,
      required this.level2,
      required this.level3,
      required this.level4,
      required this.level5,
      required this.level6,
      required this.level7});

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
    score: 0,
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
      description: "Is this the sound of letter Aa?",
      correctAnswers: [
        "assets/sounds/a_sound_female_UK.mp3",
        "assets/sounds/ai_sound_female_UK.mp3"
      ],
    ),
    level4: Level(
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
    level5: Level(
      description: "Please write the small letter a.",
      answers: ["a"],
    ),
    level6: Level(
      description: "Please write the capital letter A.",
      answers: ["A"],
    ),
    level7: Level(
      description: "Which of these starts with the letter Aa?",
      correctAnswers: ["assets/images/apple.png"],
    ),
  );

  final letterBb = LetterLesson(
      name: "Bb",
      progress: 0,
      score: 0,
      isUnlocked: false,
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
        description: "Is this the sound of letter Bb?",
        correctAnswers: ["assets/sounds/b_sound_female_UK.mp3"],
      ),
      level4: Level(
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
      level5: Level(
          description: "Please write the small letter b.", answers: ["b"]),
      level6: Level(
        description: "Please write the capital letter B.",
        answers: ["B"],
      ),
      level7: Level(
          description: "Which of these starts with the letter Bb?",
          correctAnswers: ["assets/images/boy.png", "assets/images/bat.png"]));

  final letterCc = LetterLesson(
      name: "Cc",
      progress: 0,
      score: 0,
      isUnlocked: false,
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
        description: "Is this the sound of letter Cc?",
        correctAnswers: [
          "assets/sounds/c_sound_female_UK.mp3",
          "assets/sounds/ch-chair_sound_female_UK.mp3"
        ],
      ),
      level4: Level(
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
      level5: Level(
          description: "Please write the small letter c.", answers: ["c"]),
      level6: Level(
        description: "Please write the capital letter C.",
        answers: ["C"],
      ),
      level7: Level(
          description: "Which of these starts with the letter Cc?",
          correctAnswers: [
            "assets/images/cat.png",
            "assets/images/chair.png"
          ]));

  final letterDd = LetterLesson(
      name: "Dd",
      progress: 0,
      score: 0,
      isUnlocked: false,
      level1: Level(description: "The letter Dd", texts: [
        "This is the letter Dd. It only makes one sound.",
        "The d in dog sounds like:",
        "The d in food sounds like:"
      ], sounds: [
        null,
        "assets/sounds/d_sound_female_UK.mp3",
        "assets/sounds/d_sound_female_UK.mp3"
      ], images: [
        null,
        "assets/images/dog.png",
        "assets/images/food.png"
      ]),
      level2: Level(
        description: "Which one sounds like the letter Dd?",
        correctAnswers: [
          "assets/sounds/d_sound_female_UK.mp3",
        ],
      ),
      level3: Level(
        description: "Is this the sound of letter Dd?",
        correctAnswers: [
          "assets/sounds/d_sound_female_UK.mp3",
        ],
      ),
      level4: Level(
        description: "How to write the letter Dd?",
        texts: [
          "This is how to write the letter Dd.",
          "Let's start with the capital letter D. This is how you would write it.",
          "And this is how you would write the small letter d."
        ],
        images: [
          null,
          "assets/images/capital_d_trace.gif",
          "assets/images/small_d_trace.gif"
        ],
      ),
      level5: Level(
          description: "Please write the small letter d.", answers: ["d"]),
      level6: Level(
        description: "Please write the capital letter D.",
        answers: ["D"],
      ),
      level7: Level(
          description: "Which of these starts with the letter Dd?",
          correctAnswers: [
            "assets/images/dog.png",
          ]));

  final letterEe = LetterLesson(
      name: "Ee",
      progress: 0,
      score: 0,
      isUnlocked: false,
      level1: Level(description: "The letter Ee", texts: [
        "This is the letter Ee. It has many different sounds.",
        "The e in ear sounds like:",
        "The e in head sounds like:",
        "The e in bee sounds like:",
      ], sounds: [
        null,
        "assets/sounds/ear_sound_female_UK.mp3",
        "assets/sounds/e_sound_female_UK.mp3",
        "assets/sounds/ee_sound_female_UK.mp3",
      ], images: [
        null,
        "assets/images/ear.png",
        "assets/images/head.png",
        "assets/images/bee.png",
      ]),
      level2: Level(
        description: "Which one sounds like the letter Ee?",
        correctAnswers: [
          "assets/sounds/ear_sound_female_UK.mp3",
          "assets/sounds/e_sound_female_UK.mp3",
          "assets/sounds/ee_sound_female_UK.mp3",
        ],
      ),
      level3: Level(
        description: "Is this the sound of letter Ee?",
        correctAnswers: [
          "assets/sounds/ear_sound_female_UK.mp3",
          "assets/sounds/e_sound_female_UK.mp3",
          "assets/sounds/ee_sound_female_UK.mp3",
        ],
      ),
      level4: Level(
        description: "How to write the letter Ee?",
        texts: [
          "This is how to write the letter Ee.",
          "Let's start with the capital letter E. This is how you would write it.",
          "And this is how you would write the small letter e."
        ],
        images: [
          null,
          "assets/images/capital_e_trace.gif",
          "assets/images/small_e_trace.gif"
        ],
      ),
      level5: Level(
          description: "Please write the small letter e.", answers: ["e"]),
      level6: Level(
        description: "Please write the capital letter E.",
        answers: ["E"],
      ),
      level7: Level(
          description: "Which of these starts with the letter Ee?",
          correctAnswers: [
            "assets/images/ear.png",
          ]));

  final jsonString = json.encode([
    letterAa.toJson(),
    letterBb.toJson(),
    letterCc.toJson(),
    letterDd.toJson(),
    letterEe.toJson()
  ]);
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/letter_lessons.json');
  await file.writeAsString(jsonString);
}

Future<void> addNewLetterLesson() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/letter_lessons.json');

  try {
    final jsonString = await file.readAsString();
    final List<dynamic> jsonData = json.decode(jsonString);

    List<LetterLesson> letterLessons = jsonData.map((lesson) {
      return LetterLesson.fromJson(lesson);
    }).toList();

    // Check if the lesson with the given name already exists
    if (letterLessons.any((lesson) => lesson.name == 'Ee')) {
      print('LetterLesson with name Ee already exists in JSON file');
      return;
    }

    // Create the new LetterLesson object with default values
    LetterLesson newLetterLesson = LetterLesson(
        name: "Ee",
        progress: 0,
        score: 0,
        isUnlocked: false,
        level1: Level(description: "The letter Ee", texts: [
          "This is the letter Ee. It has many different sounds.",
          "The e in ear sounds like:",
          "The e in head sounds like:",
          "The e in bee sounds like:",
        ], sounds: [
          null,
          "assets/sounds/ear_sound_female_UK.mp3",
          "assets/sounds/e_sound_female_UK.mp3",
          "assets/sounds/ee_sound_female_UK.mp3",
        ], images: [
          null,
          "assets/images/ear.png",
          "assets/images/head.png",
          "assets/images/bee.png",
        ]),
        level2: Level(
          description: "Which one sounds like the letter Ee?",
          correctAnswers: [
            "assets/sounds/ear_sound_female_UK.mp3",
            "assets/sounds/e_sound_female_UK.mp3",
            "assets/sounds/ee_sound_female_UK.mp3",
          ],
        ),
        level3: Level(
          description: "Is this the sound of letter Ee?",
          correctAnswers: [
            "assets/sounds/ear_sound_female_UK.mp3",
            "assets/sounds/e_sound_female_UK.mp3",
            "assets/sounds/ee_sound_female_UK.mp3",
          ],
        ),
        level4: Level(
          description: "How to write the letter Ee?",
          texts: [
            "This is how to write the letter Ee.",
            "Let's start with the capital letter E. This is how you would write it.",
            "And this is how you would write the small letter e."
          ],
          images: [
            null,
            "assets/images/capital_e_trace.gif",
            "assets/images/small_e_trace.gif"
          ],
        ),
        level5: Level(
            description: "Please write the small letter e.", answers: ["e"]),
        level6: Level(
          description: "Please write the capital letter E.",
          answers: ["E"],
        ),
        level7: Level(
            description: "Which of these starts with the letter Ee?",
            correctAnswers: [
              "assets/images/ear.png",
            ]));

    // Add the new LetterLesson to the list
    letterLessons.add(newLetterLesson);

    // Write the updated JSON data back to the file
    final updatedJsonData =
        letterLessons.map((lesson) => lesson.toJson()).toList();
    await file.writeAsString(json.encode(updatedJsonData));

    print('LetterLesson with name Ee added successfully!');
  } catch (e) {
    print('Error reading/writing letter_lessons.json: $e');
  }
}

Future<void> incrementProgressValue(String lessonName, int value) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/letter_lessons.json');

  try {
    final jsonString = await file.readAsString();
    final List<dynamic> jsonData = json.decode(jsonString);

    List<LetterLesson> letterLessons = jsonData.map((lesson) {
      return LetterLesson.fromJson(lesson);
    }).toList();

    LetterLesson? lessonToUpdate =
        letterLessons.firstWhere((element) => element.name == lessonName);

    if (lessonToUpdate != null) {
      // add score by value
      lessonToUpdate.progress += value;

      final updatedJsonData =
          letterLessons.map((lesson) => lesson.toJson()).toList();
      await file.writeAsString(json.encode(updatedJsonData));
      print('Score updated successfully!');
    } else {
      print('LetterLesson with name $lessonName not found in JSON file');
    }
  } catch (e) {
    print('Error reading/writing letter_lessons.json: $e');
  }
}

Future<void> addScoreToLessonBy(String lessonName, int value) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/letter_lessons.json');

  try {
    final jsonString = await file.readAsString();
    final List<dynamic> jsonData = json.decode(jsonString);

    List<LetterLesson> letterLessons = jsonData.map((lesson) {
      return LetterLesson.fromJson(lesson);
    }).toList();

    LetterLesson? lessonToUpdate =
        letterLessons.firstWhere((element) => element.name == lessonName);

    if (lessonToUpdate != null) {
      // add score by value
      lessonToUpdate.score += value;

      final updatedJsonData =
          letterLessons.map((lesson) => lesson.toJson()).toList();
      await file.writeAsString(json.encode(updatedJsonData));
      print('Score updated successfully!');
    } else {
      print('LetterLesson with name $lessonName not found in JSON file');
    }
  } catch (e) {
    print('Error reading/writing letter_lessons.json: $e');
  }
}

Future<void> resetScore(String lessonName) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/letter_lessons.json');

  try {
    final jsonString = await file.readAsString();
    final List<dynamic> jsonData = json.decode(jsonString);

    List<LetterLesson> letterLessons = jsonData.map((lesson) {
      return LetterLesson.fromJson(lesson);
    }).toList();

    LetterLesson? lessonToUpdate =
        letterLessons.firstWhere((element) => element.name == lessonName);

    if (lessonToUpdate != null) {
      // Reset the score value for that lesson to 0
      lessonToUpdate.score = 0;

      final updatedJsonData =
          letterLessons.map((lesson) => lesson.toJson()).toList();
      await file.writeAsString(json.encode(updatedJsonData));
      print('Score has reset successfully!');
    } else {
      print('LetterLesson with name $lessonName not found in JSON file');
    }
  } catch (e) {
    print('Error reading/writing letter_lessons.json: $e');
  }
}

Future<void> unlockLesson(String lessonName) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/letter_lessons.json');

  try {
    final jsonString = await file.readAsString();
    final List<dynamic> jsonData = json.decode(jsonString);

    List<LetterLesson> letterLessons = jsonData.map((lesson) {
      return LetterLesson.fromJson(lesson);
    }).toList();

    int currentIndex =
        letterLessons.indexWhere((element) => element.name == lessonName);

    if (currentIndex >= 0 && currentIndex < letterLessons.length - 1) {
      // Change the value of isUnlocked to true for the next lesson
      letterLessons[currentIndex + 1].isUnlocked = true;

      final updatedJsonData =
          letterLessons.map((lesson) => lesson.toJson()).toList();
      await file.writeAsString(json.encode(updatedJsonData));
      print('Lesson has unlocked successfully!');
    } else {
      print(
          'LetterLesson with name $lessonName not found or is the last lesson');
    }
  } catch (e) {
    print('Error reading/writing letter_lessons.json: $e');
  }
}
