import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:e_dukaxon/data/letter_lessons.dart';
import 'package:e_dukaxon/pages/lessons/letters/level_three.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class LettersLevelTwo extends StatefulWidget {
  final String lessonName;

  const LettersLevelTwo({Key? key, required this.lessonName}) : super(key: key);

  @override
  State<LettersLevelTwo> createState() => _LettersLevelTwoState();
}

class _LettersLevelTwoState extends State<LettersLevelTwo> {
  String? levelDescription;
  List<dynamic> correctAnswers = [];
  List<String> sounds = [
    "assets/sounds/a_sound_female_UK.mp3",
    "assets/sounds/ai_sound_female_UK.mp3",
    "assets/sounds/air_sound_female_UK.mp3",
    "assets/sounds/ar_sound_female_UK.mp3",
    "assets/sounds/b_sound_female_UK.mp3",
    "assets/sounds/c_sound_female_UK.mp3",
    "assets/sounds/ch-chair_sound_female_UK.mp3",
    "assets/sounds/d_sound_female_UK.mp3",
    "assets/sounds/e_sound_female_UK.mp3",
    "assets/sounds/ear_sound_female_UK.mp3",
    "assets/sounds/ee_sound_female_UK.mp3",
    "assets/sounds/f_sound_female_UK.mp3",
    "assets/sounds/g_sound_female_UK.mp3",
    "assets/sounds/h_sound_female_UK.mp3",
    "assets/sounds/i_sound_female_UK.mp3",
    "assets/sounds/igh_sound_female_UK.mp3",
    "assets/sounds/j_sound_female_UK.mp3"
  ];
  List<String> soundChoices = []; // List to store the sound choices for buttons
  String? selectedSound; // Currently selected sound
  bool isLoading = true;
  bool isCorrectAtFirstAttempt = true;
  AssetsAudioPlayer audio = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    getLevelDataByName(widget.lessonName);
  }

  LetterLesson? getLetterLessonByName(
      List<LetterLesson> letterLessons, String lessonName) {
    return letterLessons.firstWhere((lesson) => lesson.name == lessonName);
  }

  void getLevelDataByName(String lessonName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/letter_lessons.json');

    try {
      final jsonString = await file.readAsString();
      final List<dynamic> jsonData = json.decode(jsonString);

      List<LetterLesson> letterLessons = jsonData.map((lesson) {
        return LetterLesson.fromJson(lesson);
      }).toList();

      LetterLesson? lesson = getLetterLessonByName(letterLessons, lessonName);

      if (lesson != null) {
        Level levelData = lesson.level2;
        print('Level 2 data for $lessonName: $levelData');

        correctAnswers.addAll(levelData.correctAnswers!);

        // Select a random sound from the correctAnswers list
        String correctSound =
            correctAnswers[Random().nextInt(correctAnswers.length)];

        // Create a list of remaining random sounds
        List<String> remainingRandomSounds = sounds..remove(correctSound);

        // Shuffle the remainingRandomSounds list and take 3 random elements
        List<String> randomSounds = List.from(remainingRandomSounds)..shuffle();
        randomSounds = randomSounds.take(3).toList();

        // Add the correct sound to the randomSounds list
        randomSounds.add(correctSound);

        if (mounted) {
          setState(() {
            levelDescription = levelData.description;
            soundChoices = List.from(randomSounds);
            isLoading = false;
          });
        }
      } else {
        print('LetterLesson with name $lessonName not found in JSON file');
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error reading letter_lessons.json: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    audio.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void showResultModal(BuildContext context, bool isCorrect) {
      if (isCorrect) {
        if (isCorrectAtFirstAttempt) {
          print("Score updated successfully!");
          addScoreToLessonBy(widget.lessonName, 10);
          isCorrectAtFirstAttempt = false;
        }
        audio.open(Audio('assets/sounds/correct.mp3'));
      } else {
        isCorrectAtFirstAttempt = false;
        audio.open(Audio('assets/sounds/wrong.mp3'));
      }

      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFFF2EAD3),
        isDismissible: isCorrect ? false : true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
        builder: (context) {
          return WillPopScope(
            onWillPop: () async {
              return isCorrect ? false : true;
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isCorrect ? Icons.check : Icons.close,
                        color: isCorrect
                            ? const Color.fromARGB(255, 52, 156, 55)
                            : const Color.fromARGB(255, 196, 47, 36),
                        size: 40,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isCorrect ? 'Correct!' : 'Incorrect. Please try again.',
                        style: const TextStyle(
                            fontSize: 24, fontFamily: "OpenDyslexic"),
                      ),
                    ],
                  ),
                  if (isCorrect)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LettersLevelThree(
                                  lessonName: widget.lessonName)),
                        );
                      },
                      child: const Text('Next'),
                    ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: isLoading
              ? [
                  const CircularProgressIndicator(),
                ]
              : [
                  Text(
                    levelDescription!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  // Display buttons with sounds in a 2x2 grid
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width / 5),
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      childAspectRatio: (1 / .4),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: soundChoices
                          .asMap()
                          .entries
                          .map(
                            (entry) => ElevatedButton.icon(
                              onPressed: () {
                                if (mounted) {
                                  setState(() {
                                    selectedSound = entry.value;
                                  });
                                }

                                int index = entry.key;

                                audio.open(Audio(soundChoices[index]));
                              },
                              label: const Text(''),
                              icon: const Icon(Icons.volume_up),
                              style: ElevatedButton.styleFrom(
                                primary: selectedSound == entry.value
                                    ? const Color.fromARGB(255, 27, 15, 2)
                                    : null,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        label: const Text("Check Answer"),
                        icon: const Icon(Icons.check),
                        style: const ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              Color.fromARGB(255, 52, 156, 55)),
                        ),
                        onPressed: () {
                          // Check if the selected sound is correct
                          bool isCorrect =
                              correctAnswers.contains(selectedSound);
                          // Display a message to the user based on the result
                          showResultModal(context, isCorrect);
                        },
                      ),
                    ],
                  ),
                ],
        ),
      ),
    );
  }
}
