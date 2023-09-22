// import 'dart:convert';
// import 'dart:io';
import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:e_dukaxon/auth.dart';
// import 'package:e_dukaxon/data/letter_lessons.dart';
import 'package:e_dukaxon/firebase_storage.dart';
import 'package:e_dukaxon/firestore_data/letter_lessons.dart';
import 'package:e_dukaxon/pages/lessons/letters/level_three.dart';
import 'package:e_dukaxon/pages/loading.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:path_provider/path_provider.dart';

class LettersLevelTwo extends StatefulWidget {
  final String lessonName;

  const LettersLevelTwo({Key? key, required this.lessonName}) : super(key: key);

  @override
  State<LettersLevelTwo> createState() => _LettersLevelTwoState();
}

class _LettersLevelTwoState extends State<LettersLevelTwo> {
  String levelDescription = "";
  String uid = "";
  List<dynamic> correctAnswers = [];
  List<String> sounds = [
    "sounds/a_sound_female_UK.mp3",
    "sounds/ai_sound_female_UK.mp3",
    "sounds/air_sound_female_UK.mp3",
    "sounds/ar_sound_female_UK.mp3",
    "sounds/b_sound_female_UK.mp3",
    "sounds/c_sound_female_UK.mp3",
    "sounds/ch-chair_sound_female_UK.mp3",
    "sounds/d_sound_female_UK.mp3",
    "sounds/e_sound_female_UK.mp3",
    "sounds/ear_sound_female_UK.mp3",
    "sounds/ee_sound_female_UK.mp3",
    "sounds/f_sound_female_UK.mp3",
    "sounds/g_sound_female_UK.mp3",
    "sounds/h_sound_female_UK.mp3",
    "sounds/i_sound_female_UK.mp3",
    "sounds/igh_sound_female_UK.mp3",
    "sounds/j_sound_female_UK.mp3"
  ];
  List<String> phSounds = [
    "sounds/ph/a.wav",
    "sounds/ph/ba.wav",
    "sounds/ph/be.wav",
    "sounds/ph/bi.wav",
    "sounds/ph/bo.wav",
    "sounds/ph/bu.wav",
    "sounds/ph/da.wav",
    "sounds/ph/de.wav",
    "sounds/ph/di.wav",
    "sounds/ph/do.wav",
    "sounds/ph/du.wav",
  ];
  List<String> soundChoices = []; // List to store the sound choices for buttons
  String? selectedSound; // Currently selected sound
  bool isLoading = true;
  bool isCorrectAtFirstAttempt = true;
  bool isEnglish = true;
  AssetsAudioPlayer audio = AssetsAudioPlayer();
  AudioPlayer networkAudio = AudioPlayer();

  @override
  void initState() {
    super.initState();
    getLanguage().then((value) => getLevelDataByName(widget.lessonName));
  }

  Future<void> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnglish = prefs.getBool('isEnglish') ?? true; // Default to English.

    if (mounted) {
      setState(() {
        this.isEnglish = isEnglish;
      });
    }
  }

  void getLevelDataByName(String lessonName) async {
    try {
      final userId = Auth().getCurrentUserId();
      Map<String, dynamic>? lessonData =
          await LetterLessonFirestore(userId: userId!)
              .getLessonData(lessonName, isEnglish ? "en" : "ph");

      if (lessonData != null && lessonData.containsKey('level2')) {
        Map<String, dynamic> levelData =
            lessonData['level2'] as Map<String, dynamic>;
        String description = levelData['description'] as String;
        Iterable<dynamic> _correctAnswers = levelData['correctAnswers'];

        _correctAnswers = await Future.wait(
            _correctAnswers.map((e) => AssetFirebaseStorage().getAsset(e)));

        List<Future<String>> soundFutures = isEnglish
            ? sounds.map((e) {
                return AssetFirebaseStorage()
                    .getAsset(e)
                    .then((String? result) {
                  // Handle the possibility of null values here, if necessary
                  return result ??
                      ''; // Return an empty string if the result is null
                });
              }).toList()
            : phSounds.map((e) {
                return AssetFirebaseStorage()
                    .getAsset(e)
                    .then((String? result) {
                  // Same function but if locale = "ph"
                  return result ?? '';
                });
              }).toList();

        sounds = await Future.wait(soundFutures);

        correctAnswers = _correctAnswers.toList();

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
        randomSounds = randomSounds..shuffle();

        if (mounted) {
          setState(() {
            levelDescription = description;
            soundChoices = List.from(randomSounds);
            uid = userId;
            isLoading = false;
          });
        }
        print(soundChoices);
      } else {
        print(
            'Letter lesson "$lessonName" was not found within the Firestore.');
        isLoading = true;
      }
    } catch (e) {
      print('Error reading letter_lessons.json: $e');
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
    }
  }

  // LetterLesson? getLetterLessonByName(
  //     List<LetterLesson> letterLessons, String lessonName) {
  //   return letterLessons.firstWhere((lesson) => lesson.name == lessonName);
  // }

  // void getLevelDataByName(String lessonName) async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   final file = File('${directory.path}/letter_lessons.json');

  //   try {
  //     final jsonString = await file.readAsString();
  //     final List<dynamic> jsonData = json.decode(jsonString);

  //     List<LetterLesson> letterLessons = jsonData.map((lesson) {
  //       return LetterLesson.fromJson(lesson);
  //     }).toList();

  //     LetterLesson? lesson = getLetterLessonByName(letterLessons, lessonName);

  //     if (lesson != null) {
  //       Level levelData = lesson.level2;
  //       print('Level 2 data for $lessonName: $levelData');

  //       correctAnswers.addAll(levelData.correctAnswers!);

  //       // Select a random sound from the correctAnswers list
  //       String correctSound =
  //           correctAnswers[Random().nextInt(correctAnswers.length)];

  //       // Create a list of remaining random sounds
  //       List<String> remainingRandomSounds = sounds..remove(correctSound);

  //       // Shuffle the remainingRandomSounds list and take 3 random elements
  //       List<String> randomSounds = List.from(remainingRandomSounds)..shuffle();
  //       randomSounds = randomSounds.take(3).toList();

  //       // Add the correct sound to the randomSounds list
  //       randomSounds.add(correctSound);

  //       if (mounted) {
  //         setState(() {
  //           levelDescription = levelData.description;
  //           soundChoices = List.from(randomSounds);
  //           isLoading = false;
  //         });
  //       }
  //     } else {
  //       print('LetterLesson with name $lessonName not found in JSON file');
  //       if (mounted) {
  //         setState(() {
  //           isLoading = false;
  //         });
  //       }
  //     }
  //   } catch (e) {
  //     print('Error reading letter_lessons.json: $e');
  //     if (mounted) {
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }
  //   }
  // }

  @override
  void dispose() {
    super.dispose();
    audio.dispose();
    networkAudio.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void showResultModal(BuildContext context, bool isCorrect) {
      if (isCorrect) {
        if (isCorrectAtFirstAttempt) {
          print("Score updated successfully!");
          LetterLessonFirestore(userId: uid).addScoreToLessonBy(
              widget.lessonName, isEnglish ? "en" : "ph", 10);
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
                        isCorrect
                            ? (isEnglish ? 'Correct!' : 'Tama!')
                            : (isEnglish
                                ? 'Incorrect. Please try again.'
                                : 'Mali. Puwede ka pang pumili ng sagot.'),
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
                      child: Text(isEnglish ? 'Next' : 'Susunod'),
                    ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      body: isLoading
          ? const LoadingPage()
          : Padding(
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
                          levelDescription,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        // Display buttons with sounds in a 2x2 grid
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width / 5),
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
                                    onPressed: () async {
                                      if (mounted) {
                                        setState(() {
                                          selectedSound = entry.value;
                                        });
                                      }

                                      int index = entry.key;

                                      await AudioPlayer()
                                          .play(UrlSource(soundChoices[index]));
                                      // audio.open(Audio(soundChoices[index]));
                                    },
                                    label: const Text(''),
                                    icon: const Icon(Icons.volume_up),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: selectedSound ==
                                              entry.value
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
                              label: Text(isEnglish
                                  ? "Check Answer"
                                  : "Tingnan ang Sagot"),
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
