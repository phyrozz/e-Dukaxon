import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:e_dukaxon/data/letter_lessons.dart';
import 'package:e_dukaxon/pages/child_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:path_provider/path_provider.dart';
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
  bool isLoading = true;
  AssetsAudioPlayer audio = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    getScore(widget.lessonName);
  }

  void playLessonFinishedSound() {
    if (progress < 100) {
      incrementProgressValue(widget.lessonName, 10);
    }

    if (score <= 40 && score >= 20) {
      audio.open(Audio('assets/sounds/lesson_finished_1.mp3'));
    } else {
      audio.open(Audio('assets/sounds/lesson_finished_2.mp3'));
    }
  }

  LetterLesson? getLetterLessonByName(
      List<LetterLesson> letterLessons, String lessonName) {
    return letterLessons.firstWhere((lesson) => lesson.name == lessonName);
  }

  Future<void> getScore(String lessonName) async {
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
        setState(() {
          progress = lesson.progress;
          score = lesson.score;
          isLoading = false;
        });

        // Call playLessonFinishedSound after the score is updated
        playLessonFinishedSound();
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
                      Text('You got a score of ${score}/40!'),
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
                            if (progress >= 50) {
                              unlockLesson(widget.lessonName);
                            }
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ChildHomePage()),
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
