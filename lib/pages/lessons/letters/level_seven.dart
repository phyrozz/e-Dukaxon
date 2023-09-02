import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:e_dukaxon/data/letter_lessons.dart';
import 'package:e_dukaxon/pages/lessons/letters/level_three.dart';
import 'package:e_dukaxon/pages/lessons/letters/result.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class LettersLevelSeven extends StatefulWidget {
  final String lessonName;

  const LettersLevelSeven({Key? key, required this.lessonName})
      : super(key: key);

  @override
  State<LettersLevelSeven> createState() => _LettersLevelSevenState();
}

class _LettersLevelSevenState extends State<LettersLevelSeven> {
  String? levelDescription;
  List<dynamic> correctAnswers = [];
  List<String> images = [
    "assets/images/apple.png",
    "assets/images/bat.png",
    "assets/images/boy.png",
    "assets/images/cat.png",
    "assets/images/chair.png",
  ];
  List<String> imageChoices = [];
  String? selectedImage;
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
        Level levelData = lesson.level7;
        print('Level 7 data for $lessonName: $levelData');

        correctAnswers.addAll(levelData.correctAnswers!);

        // Select a random sound from the correctAnswers list
        String correctImage =
            correctAnswers[Random().nextInt(correctAnswers.length)];

        // Create a list of remaining random sounds
        List<String> remainingRandomImages = images..remove(correctImage);

        // Shuffle the remainingRandomSounds list and take 3 random elements
        List<String> randomImages = List.from(remainingRandomImages)..shuffle();
        randomImages = randomImages.take(3).toList();

        // Add the correct sound to the randomSounds list
        randomImages.add(correctImage);

        setState(() {
          levelDescription = levelData.description;
          imageChoices = List.from(randomImages);
          isLoading = false;
        });
      } else {
        print('LetterLesson with name $lessonName not found in JSON file');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error reading letter_lessons.json: $e');
      setState(() {
        isLoading = false;
      });
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
                              builder: (context) => LettersResultPage(
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
                        horizontal: MediaQuery.of(context).size.width / 4),
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      childAspectRatio: (1 / .5),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: imageChoices
                          .asMap()
                          .entries
                          .map(
                            (entry) => ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedImage = entry.value;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                primary: selectedImage == entry.value
                                    ? const Color.fromARGB(255, 27, 15, 2)
                                    : null,
                              ),
                              child: Image.asset(imageChoices[entry.key]),
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
                              correctAnswers.contains(selectedImage);
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
