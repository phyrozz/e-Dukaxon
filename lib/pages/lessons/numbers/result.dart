import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/firestore_data/number_lessons.dart';
import 'package:e_dukaxon/homepage_tree.dart';
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
  int totalScore = 0;
  int score = 0;
  int progress = 0;
  int accumulatedScore = 0;
  int finalScore = 0;
  int newFinalScore = 0;
  int dailyStreak = 0;
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
        NumberLessonFirestore(userId: uid)
            .unlockLesson(widget.lessonName, isEnglish ? "en" : "ph");
      }
      updateAccumulatedScoresAndLessonTakenCounter(widget.lessonName)
          .then((value) => addCounterOnLesson(widget.lessonName));
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
      audio.open(Audio('assets/sounds/congratulations.wav'));
      if (progress < 100) {
        if (score == totalScore) {
          NumberLessonFirestore(userId: uid).incrementProgressValue(
              widget.lessonName, isEnglish ? "en" : "ph", 20);
        } else {
          NumberLessonFirestore(userId: uid).incrementProgressValue(
              widget.lessonName, isEnglish ? "en" : "ph", 10);
        }
      }
    } else {
      audio.open(Audio('assets/sounds/game_over.wav'));
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
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getTotalScore(String lessonName) async {
    try {
      final userId = Auth().getCurrentUserId();
      Map<String, dynamic>? lessonData =
          await NumberLessonFirestore(userId: userId!)
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

  // Accumulated scores are tracked on each lessons in the app to gather the user's accuracy as they continue to
  // answer the lesson.
  // This can be helpful for parents keeping track of their child's progress.
  Future<void> updateAccumulatedScoresAndLessonTakenCounter(
      String lessonName) async {
    try {
      final userId = Auth().getCurrentUserId();
      Map<String, dynamic>? userLessonData =
          await NumberLessonFirestore(userId: userId!)
              .getUserLessonData(lessonName, isEnglish ? "en" : "ph");

      if (userLessonData != null) {
        int accumulatedScore =
            userLessonData['accumulatedScore'] ?? 0; // Default to 0 if null
        int lessonTaken =
            userLessonData['lessonTaken'] ?? 0; // Default to 0 if null

        accumulatedScore += score;
        lessonTaken++; // Increment by 1 every time the lesson is accomplished. This way, the accumulated total score for this lesson can be determined in order to get the
        // accuracy of that lesson for the user.

        // Making this as a counter instead of just getting the accumulated total scores of that lesson then just easily dividing together with the accumulated score by 100 so
        // that it can also act as the number of retries the user has made for that lesson. Needed for the analytics.

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          // For the daily streak counter
          // Update the lastUpdatedStreak to the current time to avoid resetting the daily streak if the value has not been updated for the past 24 hours
          'lastUpdatedStreak': FieldValue.serverTimestamp(),
        });

        // Retrieve the daily streak and final score values from the users document
        DocumentReference userRef =
            FirebaseFirestore.instance.collection('users').doc(userId);

        DocumentSnapshot userSnapshot = await userRef.get();
        int dailyStreak = userSnapshot.exists
            ? ((userSnapshot.data() as Map<String, dynamic>)['dailyStreak'] ??
                0)
            : 0;
        int finalScore = userLessonData["finalScore"] ?? 0;

        // Store the retrieved accumulated score and daily streak
        setState(() {
          this.accumulatedScore = accumulatedScore;
          this.dailyStreak = dailyStreak;
          this.finalScore = finalScore;
        });

        int newFinalScore =
            finalScore + (dailyStreak == 0 ? score : (score * dailyStreak));

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('numbers')
            .doc(isEnglish ? "en" : "ph")
            .collection('lessons')
            .doc(lessonName)
            .update({
          'accumulatedScore': accumulatedScore,
          'lessonTaken': lessonTaken,
          // Perform necessary calculations to increment the final score into the final score field
          'finalScore': newFinalScore,
        });

        setState(() {
          this.newFinalScore = newFinalScore;
        });
      } else {
        print(
            'User lesson data for "$lessonName" was not found within the Firestore.');
      }
    } catch (e) {
      print('Error updating accumulated scores: $e');
    }
  }

  // Counter on a lesson document (not the user's lesson document) indicates the number of times the lesson was played by users
  // For admin analytics
  Future<void> addCounterOnLesson(String lessonName) async {
    try {
      DocumentReference lessonRef = FirebaseFirestore.instance
          .collection('numbers')
          .doc(isEnglish ? "en" : "ph")
          .collection('lessons')
          .doc(lessonName);

      DocumentSnapshot lessonSnapshot = await lessonRef.get();
      int currentCounter = lessonSnapshot.exists
          ? ((lessonSnapshot.data() as Map<String, dynamic>)['counter'] ?? 0)
          : 0;
      int newCounter = currentCounter + 1;

      await lessonRef.update({
        'counter': newCounter,
      });
    } catch (e) {
      print('Error updating lesson counter: $e');
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
                            // Text(
                            //   isEnglish
                            //       ? 'You can play this lesson again to get a higher score.'
                            //       : 'Puwede mo ulit laruin ang lesson na ito para makakuha ng mas mataas na marka.',
                            //   style: TextStyle(fontSize: 20),
                            // ),
                          ],
                        ),
                      // Text(isEnglish
                      //     ? 'You got a score of $score/20!'
                      //     : 'Nakakuha ka ng $score/20!'),
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
