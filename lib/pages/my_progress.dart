import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/firestore_data/games.dart';
import 'package:e_dukaxon/pages/loading.dart';
import 'package:e_dukaxon/widgets/new_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProgressPage extends StatefulWidget {
  const MyProgressPage({super.key});

  @override
  State<MyProgressPage> createState() => _MyProgressPageState();
}

class _MyProgressPageState extends State<MyProgressPage> {
  bool isParentMode = false;
  bool isLoading = true;
  int correctLetterGuess = 0;
  int incorrectLetterGuess = 0;
  int correctLetterTracing = 0;
  int incorrectLetterTracing = 0;
  int correctSoundQuiz = 0;
  int incorrectSoundQuiz = 0;

  @override
  void initState() {
    getParentModeValue();
    getGameScores();
    super.initState();
  }

  Future<void> getParentModeValue() async {
    final prefs = await SharedPreferences.getInstance();
    final prefValue = prefs.getBool('isParentMode');

    if (mounted) {
      setState(() {
        isParentMode = prefValue!;
        isLoading = false;
      });
    }
  }

  Future<void> getGameScores() async {
    String userId = Auth().getCurrentUserId()!;

    final letterGuessCorrects = await GameFirestore(userId: userId)
        .getGameScore(userId, "letterGuess", "noOfCorrects");

    final letterGuessWrongs = await GameFirestore(userId: userId)
        .getGameScore(userId, "letterGuess", "noOfWrongs");

    final soundQuizCorrects = await GameFirestore(userId: userId)
        .getGameScore(userId, "soundQuiz", "noOfCorrects");

    final soundQuizWrongs = await GameFirestore(userId: userId)
        .getGameScore(userId, "soundQuiz", "noOfWrongs");

    final traceLetterCorrects = await GameFirestore(userId: userId)
        .getGameScore(userId, "traceLetter", "noOfCorrects");

    final traceLetterWrongs = await GameFirestore(userId: userId)
        .getGameScore(userId, "traceLetter", "noOfWrongs");

    setState(() {
      correctLetterGuess = letterGuessCorrects;
      incorrectLetterGuess = letterGuessWrongs;
      correctSoundQuiz = soundQuizCorrects;
      incorrectSoundQuiz = soundQuizWrongs;
      correctLetterTracing = traceLetterCorrects;
      incorrectLetterTracing = traceLetterWrongs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const LoadingPage()
          : CustomScrollView(
              slivers: [
                WelcomeCustomAppBar(
                    text: "Progress", isParentMode: isParentMode),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        const Text('Games'),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Sound Quiz',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Passing rate: ',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  'Number of correct answers: $correctSoundQuiz',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  'Number of incorrect answers: $incorrectSoundQuiz',
                                  style: Theme.of(context).textTheme.bodySmall,
                                )
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Letter Tracing',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Passing rate: ',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  'Number of correct answers: $correctLetterTracing',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  'Number of incorrect answers: $incorrectLetterTracing',
                                  style: Theme.of(context).textTheme.bodySmall,
                                )
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Guess the Letter',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Passing rate: ',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  'Number of correct answers: $correctLetterGuess',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  'Number of incorrect answers: $incorrectLetterGuess',
                                  style: Theme.of(context).textTheme.bodySmall,
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
