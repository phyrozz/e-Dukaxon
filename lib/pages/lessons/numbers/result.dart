import 'package:e_dukaxon/assessment_data.dart';
import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/firestore_data/number_lessons.dart';
import 'package:e_dukaxon/pages/child_home.dart';
import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NumbersResultPage extends StatefulWidget {
  final String lessonName;

  const NumbersResultPage({super.key, required this.lessonName});

  @override
  State<NumbersResultPage> createState() => _NumbersResultPageState();
}

class _NumbersResultPageState extends State<NumbersResultPage> {
  int score = 0;
  int progress = 0;
  String uid = "";
  bool isLoading = true;
  bool isEnglish = true;
  AssetsAudioPlayer audio = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    getLanguage().then((_) => getScore(widget.lessonName)).then((_) {
      if (progress >= 50) {
        NumberLessonFirestore(userId: uid)
            .unlockLesson(widget.lessonName, isEnglish ? "en" : "ph");
      }
      isParent = false;
    });
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

  void playLessonFinishedSound() {
    if (score <= 20 && score >= 10) {
      audio.open(Audio('assets/sounds/lesson_finished_1.mp3'));
      if (progress < 100) {
        if (score == 20) {
          NumberLessonFirestore(userId: uid).incrementProgressValue(
              widget.lessonName, isEnglish ? "en" : "ph", 20);
        } else {
          NumberLessonFirestore(userId: uid).incrementProgressValue(
              widget.lessonName, isEnglish ? "en" : "ph", 10);
        }
      }
    } else {
      audio.open(Audio('assets/sounds/lesson_finished_2.mp3'));
      if (progress < 100) {
        NumberLessonFirestore(userId: uid).incrementProgressValue(
            widget.lessonName, isEnglish ? "en" : "ph", 5);
      }
    }
  }

  Future<void> getScore(String lessonName) async {
    try {
      final userId = Auth().getCurrentUserId();
      Map<String, dynamic>? lessonData =
          await NumberLessonFirestore(userId: userId!)
              .getUserLessonData(lessonName, isEnglish ? "en" : "ph");

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
                        score <= 20 && score >= 10
                            ? 'assets/images/lesson_finished_1.png'
                            : 'assets/images/lesson_finished_2.png',
                        width: 150,
                      ),
                      if (score == 20)
                        Text(
                          isEnglish ? 'Excellent!' : 'Napakahusay!',
                          style: Theme.of(context).textTheme.titleLarge,
                        )
                      else if (score < 20 && score >= 10)
                        Text(
                          isEnglish ? 'Good job!' : 'Mahusay!',
                          style: Theme.of(context).textTheme.titleLarge,
                        )
                      else
                        Column(
                          children: [
                            Text(
                              isEnglish ? "That's okay!" : "Okay lang iyan!",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              isEnglish
                                  ? 'You can play this lesson again to get a higher score.'
                                  : 'Puwede mo ulit laruin ang lesson na ito para makakuha ng mas mataas na marka.',
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      Text(isEnglish
                          ? 'You got a score of $score/20!'
                          : 'Nakakuha ka ng $score/20!'),
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
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ChildHomePage()),
                            );
                          },
                          icon: const Icon(Icons.check_rounded),
                          label: Text(isEnglish ? 'Done' : 'Tapos na'))
                    ],
                  )
                ],
              ),
            ),
    );
  }
}
