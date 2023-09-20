// import 'dart:convert';
// import 'dart:io';

import 'package:e_dukaxon/auth.dart';
// import 'package:e_dukaxon/data/letter_lessons.dart';
// import 'package:e_dukaxon/firebase_storage.dart';
import 'package:e_dukaxon/firestore_data/letter_lessons.dart';
import 'package:e_dukaxon/homepage_tree.dart';
import 'package:e_dukaxon/pages/child_home.dart';
import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

class LettersResultPage extends StatefulWidget {
  final String lessonName;

  const LettersResultPage({super.key, required this.lessonName});

  @override
  State<LettersResultPage> createState() => _LettersResultPageState();
}

class _LettersResultPageState extends State<LettersResultPage> {
  int score = 0;
  int progress = 0;
  String uid = "";
  bool isLoading = true;
  AssetsAudioPlayer audio = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    getScore(widget.lessonName);
  }

  void playLessonFinishedSound() {
    if (score <= 40 && score >= 20) {
      audio.open(Audio('assets/sounds/lesson_finished_1.mp3'));
      if (progress < 100) {
        if (score == 40) {
          LetterLessonFirestore(userId: uid)
              .incrementProgressValue(widget.lessonName, 20);
        } else {
          LetterLessonFirestore(userId: uid)
              .incrementProgressValue(widget.lessonName, 10);
        }
      }
    } else {
      audio.open(Audio('assets/sounds/lesson_finished_2.mp3'));
      if (progress < 100) {
        LetterLessonFirestore(userId: uid)
            .incrementProgressValue(widget.lessonName, 5);
      }
    }
  }

  // LetterLesson? getLetterLessonByName(
  //     List<LetterLesson> letterLessons, String lessonName) {
  //   return letterLessons.firstWhere((lesson) => lesson.name == lessonName);
  // }

  Future<void> getScore(String lessonName) async {
    try {
      final userId = Auth().getCurrentUserId();
      Map<String, dynamic>? lessonData =
          await LetterLessonFirestore(userId: userId!)
              .getLessonData(lessonName);

      if (lessonData != null) {
        if (mounted) {
          setState(() {
            progress = lessonData['progress'];
            score = lessonData['score'];
            uid = userId;
            isLoading = false;
          });
        }

        playLessonFinishedSound();
      } else {
        print(
            'Letter lesson "$lessonName" was not found within the Firestore.');
        isLoading = true;
      }
    } catch (e) {
      print('Error reading letter_lessons.json: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Future<void> getScore(String lessonName) async {
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
  //       setState(() {
  //         progress = lesson.progress;
  //         score = lesson.score;
  //         isLoading = false;
  //       });

  //       // Call playLessonFinishedSound after the score is updated
  //       playLessonFinishedSound();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(),
                  Column(
                    children: [
                      Image.asset(
                        score <= 40 && score >= 20
                            ? 'assets/images/lesson_finished_1.png'
                            : 'assets/images/lesson_finished_2.png',
                        width: 150,
                      ),
                      if (score == 40)
                        Text(
                          'Excellent!',
                          style: Theme.of(context).textTheme.titleLarge,
                        )
                      else if (score < 40 && score >= 20)
                        Text(
                          'Good job!',
                          style: Theme.of(context).textTheme.titleLarge,
                        )
                      else
                        Column(
                          children: [
                            Text(
                              "That's okay!",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const Text(
                              'You can play this lesson again to get a higher score.',
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      Text('You got a score of $score/40!'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.green[600]),
                          ),
                          onPressed: () {
                            if (progress >= 40) {
                              LetterLessonFirestore(userId: uid)
                                  .unlockLesson(widget.lessonName);
                            }
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomePageTree()),
                            );
                          },
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Done'))
                    ],
                  )
                ],
              ),
            ),
    );
  }
}
