import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/firebase_storage.dart';
import 'package:e_dukaxon/firestore_data/letter_lessons.dart';
import 'package:e_dukaxon/homepage_tree.dart';
import 'package:e_dukaxon/pages/lessons/letters/level_four.dart';
import 'package:e_dukaxon/pages/loading.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_dukaxon/firestore_data/games.dart';

class SoundQuizPage extends StatefulWidget {
  const SoundQuizPage({super.key});

  @override
  State<SoundQuizPage> createState() => _SoundQuizPageState();
}

class _SoundQuizPageState extends State<SoundQuizPage> {
  String levelDescription = "";
  String uid = "";
  String selectedLetter = "";
  List<String> letters = [];
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
  String? selectedSoundChoice;
  bool isLoading = true;
  bool isAnswered = false;
  bool isEnglish = true;
  AssetsAudioPlayer audio = AssetsAudioPlayer();
  AudioPlayer networkAudio = AudioPlayer();

  @override
  void initState() {
    super.initState();
    getLanguage()
        .then((value) => getLettersList())
        .then((value) => getRandomLetter())
        .then((value) => getLevelDataByName(selectedLetter));
  }

  Future<void> getRandomLetter() async {
    final random = Random();
    final randomIndex = random.nextInt(letters.length);
    final l = letters[randomIndex];

    setState(() {
      selectedLetter = l;
    });
  }

  Future<void> getLettersList() async {
    try {
      // Replace 'userId' with your actual user ID
      final userId = Auth().getCurrentUserId();
      final lettersCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('letters')
          .doc(isEnglish ? "en" : "ph")
          .collection('lessons');

      QuerySnapshot querySnapshot = await lettersCollection.get();

      List<String> lettersList = [];

      for (var doc in querySnapshot.docs) {
        String name = doc['name'];
        lettersList.add(name);
      }

      setState(() {
        letters = lettersList;
      });
    } catch (e) {
      print('Error retrieving letters: $e');
    }
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

      if (lessonData != null && lessonData.containsKey('level3')) {
        Map<String, dynamic> levelData =
            lessonData['level3'] as Map<String, dynamic>;
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
        setState(() {
          isLoading = true;
        });
      }
    } catch (e) {
      print('Error reading letter_lessons.json: $e');
      if (!context.mounted) return;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  LettersLevelFour(lessonName: lessonName)));
    }
  }

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
        GameFirestore(userId: uid).addScoreToGame("soundQuiz", isCorrect);
        audio.open(Audio('assets/sounds/correct.wav'));
      } else {
        GameFirestore(userId: uid).addScoreToGame("soundQuiz", isCorrect);
        audio.open(Audio('assets/sounds/incorrect.wav'));
      }

      showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                            : (isEnglish ? 'Incorrect.' : 'Mali.'),
                        style: const TextStyle(
                            fontSize: 24, fontFamily: "OpenDyslexic"),
                      ),
                    ],
                  ),
                  ButtonBar(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomePageTree()),
                          );
                        },
                        child: Text(isEnglish ? 'Done' : 'Tapos na'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SoundQuizPage()),
                          );
                        },
                        child: Text(isEnglish ? 'Next' : 'Susunod'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return isLoading
        ? const LoadingPage()
        : Scaffold(
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
                                  label: Text(isEnglish ? 'No' : 'Hindi'),
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
                                  label: Text(isEnglish ? 'Yes' : 'Opo'),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.green[600]),
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
