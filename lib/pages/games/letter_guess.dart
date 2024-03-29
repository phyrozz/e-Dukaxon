import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/firebase_storage.dart';
import 'package:e_dukaxon/firestore_data/games.dart';
import 'package:e_dukaxon/firestore_data/letter_lessons.dart';
import 'package:e_dukaxon/homepage_tree.dart';
import 'package:e_dukaxon/pages/loading.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LetterGuessPage extends StatefulWidget {
  const LetterGuessPage({super.key});

  @override
  State<LetterGuessPage> createState() => _LetterGuessPageState();
}

class _LetterGuessPageState extends State<LetterGuessPage> {
  String levelDescription = "";
  String uid = "";

  // TODO: Store these lists on Firestore and retrieve them here
  List<dynamic> correctAnswers = [];
  List<String> letters = ['Aa', 'Bb', 'Cc', 'Dd', 'Ee'];
  List<String> images = [
    "images/apple.png",
    "images/bat.png",
    "images/boy.png",
    "images/cat.png",
    "images/chair.png",
    "images/dog.png",
    "images/ear.png",
    "images/food.png",
    "images/head.png",
    "images/rain.png",
  ];
  List<String> phImages = [
    "images/ph/durian.png",
    "images/ph/doktor.png",
    "images/ph/dila.png",
    "images/ph/dentista.png",
    "images/ph/daga.png",
    "images/ph/baka.png",
    "images/ph/buko.png",
    "images/ph/bigas.png",
    "images/ph/bola.png",
    "images/ph/bahay.png",
    "images/ph/bag.png",
    "images/ph/aklat.png",
    "images/ph/aso.png",
  ];
  List<String> imageChoices = [];
  String selectedLetter = "";
  String? selectedImage;
  bool isLoading = true;
  bool isCorrectAtFirstAttempt = true;
  bool isEnglish = true;
  AssetsAudioPlayer audio = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    getRandomLetter()
        .then((_) => getLanguage())
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

      if (lessonData != null && lessonData.containsKey('level7')) {
        Map<String, dynamic> levelData =
            lessonData['level7'] as Map<String, dynamic>;
        String description = levelData['description'] as String;
        Iterable<dynamic> _correctAnswers = levelData['correctAnswers'];

        _correctAnswers = await Future.wait(
            _correctAnswers.map((e) => AssetFirebaseStorage().getAsset(e)));

        List<Future<String>> imageFutures = isEnglish
            ? images.map((e) {
                return AssetFirebaseStorage()
                    .getAsset(e)
                    .then((String? result) {
                  return result ?? '';
                });
              }).toList()
            : phImages.map((e) {
                return AssetFirebaseStorage()
                    .getAsset(e)
                    .then((String? result) {
                  return result ?? '';
                });
              }).toList();

        images = await Future.wait(imageFutures);

        correctAnswers = _correctAnswers.toList();

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

        // Shuffle the choices again
        randomImages = randomImages..shuffle();

        if (mounted) {
          setState(() {
            levelDescription = description;
            imageChoices = List.from(randomImages);
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
          isLoading = true;
        });
      }
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
          GameFirestore(userId: Auth().getCurrentUserId()!)
              .addScoreToGame("letterGuess", isCorrect);
          isCorrectAtFirstAttempt = false;
        }
        audio.open(Audio('assets/sounds/correct.wav'));
      } else {
        isCorrectAtFirstAttempt = false;
        GameFirestore(userId: Auth().getCurrentUserId()!)
            .addScoreToGame("letterGuess", false);
        audio.open(Audio('assets/sounds/incorrect.wav'));
      }

      showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).primaryColorLight,
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
                                  builder: (context) =>
                                      const LetterGuessPage()),
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
                          height: 20,
                        ),
                        // Display buttons with sounds in a 2x2 grid
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width / 4),
                          child: GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            childAspectRatio: (1 / .45),
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
                                      backgroundColor: selectedImage ==
                                              entry.value
                                          ? const Color.fromARGB(255, 27, 15, 2)
                                          : null,
                                    ),
                                    child:
                                        Image.network(imageChoices[entry.key]),
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
