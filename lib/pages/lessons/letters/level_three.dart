// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:e_dukaxon/auth.dart';
// import 'package:e_dukaxon/data/letter_lessons.dart';
import 'package:e_dukaxon/firebase_storage.dart';
import 'package:e_dukaxon/firestore_data/letter_lessons.dart';
import 'package:e_dukaxon/pages/lessons/letters/level_four.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';

class LettersLevelThree extends StatefulWidget {
  final String lessonName;

  const LettersLevelThree({Key? key, required this.lessonName})
      : super(key: key);

  @override
  State<LettersLevelThree> createState() => _LettersLevelThreeState();
}

class _LettersLevelThreeState extends State<LettersLevelThree> {
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
  String? selectedSoundChoice;
  bool isLoading = true;
  bool isAnswered = false;
  AssetsAudioPlayer audio = AssetsAudioPlayer();
  AudioPlayer networkAudio = AudioPlayer();

  @override
  void initState() {
    super.initState();
    getLevelDataByName(widget.lessonName);
  }

  // LetterLesson? getLetterLessonByName(
  //     List<LetterLesson> letterLessons, String lessonName) {
  //   return letterLessons.firstWhere((lesson) => lesson.name == lessonName);
  // }

  void getLevelDataByName(String lessonName) async {
    try {
      final userId = Auth().getCurrentUserId();
      Map<String, dynamic>? lessonData =
          await LetterLessonFirestore(userId: userId!)
              .getLessonData(lessonName);

      if (lessonData != null && lessonData.containsKey('level3')) {
        Map<String, dynamic> levelData =
            lessonData['level3'] as Map<String, dynamic>;
        String description = levelData['description'] as String;
        Iterable<dynamic> _correctAnswers = levelData['correctAnswers'];

        _correctAnswers = await Future.wait(
            _correctAnswers.map((e) => AssetFirebaseStorage().getAsset(e)));

        List<Future<String>> soundFutures = sounds.map((e) {
          return AssetFirebaseStorage().getAsset(e).then((String? result) {
            // Handle the possibility of null values here, if necessary
            return result ?? ''; // Return an empty string if the result is null
          });
        }).toList();

        sounds = await Future.wait(soundFutures);

        correctAnswers = _correctAnswers.toList();

        List<String> shuffleList = sounds..shuffle();
        String pickRandomSound = shuffleList[0];

        if (mounted) {
          setState(() {
            levelDescription = description;
            selectedSoundChoice = pickRandomSound;
            uid = userId;
            isLoading = false;
          });
        }
      } else {
        print(
            'Letter lesson "$lessonName" was not found within the Firestore.');
        isLoading = true;
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
  //       Level levelData = lesson.level3;
  //       print('Level 3 data for $lessonName: $levelData');

  //       correctAnswers.addAll(levelData.correctAnswers!);

  //       List<String> shuffleList = sounds..shuffle();
  //       String pickRandomSound = shuffleList[0];

  //       setState(() {
  //         levelDescription = levelData.description;
  //         selectedSoundChoice = pickRandomSound;
  //         isLoading = false;
  //       });

  //       audio.open(Audio(selectedSoundChoice!));
  //     } else {
  //       print('LetterLesson with name $lessonName not found in JSON file');
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     print('Error reading letter_lessons.json: $e');
  //     setState(() {
  //       isLoading = false;
  //     });
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
        LetterLessonFirestore(userId: uid)
            .addScoreToLessonBy(widget.lessonName, 10);
        audio.open(Audio('assets/sounds/correct.mp3'));
      } else {
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
                        isCorrect ? 'Correct!' : 'Incorrect.',
                        style: const TextStyle(
                            fontSize: 24, fontFamily: "OpenDyslexic"),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LettersLevelFour(
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
                    levelDescription,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  // Display buttons with sounds in a 2x2 grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 130,
                        width: 130,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await networkAudio
                                .play(UrlSource(selectedSoundChoice!));
                            // audio.open(Audio(selectedSoundChoice!));
                          },
                          label: const Text(''),
                          icon: const Icon(
                            Icons.volume_up,
                            size: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ButtonBar(
                        children: [
                          ElevatedButton.icon(
                            onPressed: isAnswered
                                ? null
                                : () {
                                    // Check if the selectedSoundChoice is in the correctAnswers list
                                    bool isCorrect = correctAnswers
                                        .contains(selectedSoundChoice);
                                    // Show the result modal
                                    showResultModal(context, !isCorrect);
                                    // Set isAnswered to true so the user cannot answer again
                                    if (mounted) {
                                      setState(() {
                                        isAnswered = true;
                                      });
                                    }
                                  },
                            icon: const Icon(Icons.close_rounded),
                            label: const Text('No'),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  const Color.fromARGB(255, 187, 68, 59)),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: isAnswered
                                ? null
                                : () {
                                    // Check if the selectedSoundChoice is in the correctAnswers list
                                    bool isCorrect = correctAnswers
                                        .contains(selectedSoundChoice);
                                    // Show the result modal
                                    showResultModal(context, isCorrect);
                                    // Set isAnswered to true so the user cannot answer again
                                    if (mounted) {
                                      setState(() {
                                        isAnswered = true;
                                      });
                                    }
                                  },
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('Yes'),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.green[600]),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
        ),
      ),
    );
  }
}
