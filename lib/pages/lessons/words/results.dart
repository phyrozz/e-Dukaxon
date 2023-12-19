import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/firestore_data/word_lessons.dart';
import 'package:e_dukaxon/homepage_tree.dart';
import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WordsResultPage extends StatefulWidget {
  final String lessonName;

  const WordsResultPage({super.key, required this.lessonName});

  @override
  State<WordsResultPage> createState() => _WordsResultPageState();
}

class _WordsResultPageState extends State<WordsResultPage> {
  int totalScore = 0;
  int score = 0;
  int progress = 0;
  String uid = "";
  bool isLoading = true;
  bool isEnglish = true;
  bool isParentMode = false;
  AssetsAudioPlayer audio = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    getPrefValues()
        .then((_) => getTotalScore(widget.lessonName))
        .then((_) => getScore(widget.lessonName))
        .then((_) {
      if (progress >= 50) {
        WordLessonFirestore(userId: uid)
            .unlockLesson(widget.lessonName, isEnglish ? "en" : "ph");
      }
      // isParent = false;
    });
  }

  Future<void> getPrefValues() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnglish = prefs.getBool('isEnglish') ?? true; // Default to English.
    final isParentMode = prefs.getBool('isParentMode') ?? true;

    if (mounted) {
      setState(() {
        this.isEnglish = isEnglish;
        this.isParentMode = isParentMode;
      });
    }
  }

  void playLessonFinishedSound() {
    if (score <= totalScore && score >= totalScore / 2) {
      audio.open(Audio('assets/sounds/lesson_finished_1.mp3'));
      if (progress < 100) {
        if (score == totalScore) {
          WordLessonFirestore(userId: uid).incrementProgressValue(
              widget.lessonName, isEnglish ? "en" : "ph", 20);
        } else {
          WordLessonFirestore(userId: uid).incrementProgressValue(
              widget.lessonName, isEnglish ? "en" : "ph", 10);
        }
      }
    } else {
      audio.open(Audio('assets/sounds/lesson_finished_2.mp3'));
      if (progress < 100) {
        WordLessonFirestore(userId: uid).incrementProgressValue(
            widget.lessonName, isEnglish ? "en" : "ph", 5);
      }
    }
  }

  Future<void> getScore(String lessonName) async {
    try {
      final userId = Auth().getCurrentUserId();
      Map<String, dynamic>? lessonData =
          await WordLessonFirestore(userId: userId!)
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

  Future<void> getTotalScore(String lessonName) async {
    try {
      final userId = Auth().getCurrentUserId();
      Map<String, dynamic>? lessonData =
          await WordLessonFirestore(userId: userId!)
              .getLessonData(lessonName, isEnglish ? "en" : "ph");

      if (lessonData != null) {
        if (mounted) {
          setState(() {
            totalScore = lessonData['total'];
            isLoading = false;
          });
        }
      } else {
        print(
            'Letter lesson "$lessonName" was not found within the Firestore.');
        isLoading = true;
      }
    } catch (e) {
      print('Error: $e');
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
                        score <= totalScore && score >= totalScore / 2
                            ? 'assets/images/lesson_finished_1.png'
                            : 'assets/images/lesson_finished_2.png',
                        width: 150,
                      ),
                      if (score == totalScore)
                        Text(
                          isEnglish ? 'Excellent!' : 'Napakahusay!',
                          style: Theme.of(context).textTheme.titleLarge,
                        )
                      else if (score < totalScore && score >= totalScore / 2)
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
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      Text(isEnglish
                          ? 'You got a score of $score/$totalScore!'
                          : 'Nakakuha ka ng $score/$totalScore!'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                          style: const ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                                Color.fromARGB(255, 52, 156, 55)),
                          ).copyWith(
                              textStyle: const MaterialStatePropertyAll(
                                  TextStyle(
                                      fontFamily: "OpenDyslexic",
                                      fontSize: 18))),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomePageTree()),
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
