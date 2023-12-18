import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/firestore_data/games.dart';
import 'package:e_dukaxon/homepage_tree.dart';
import 'package:e_dukaxon/pages/loading.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WordPlaceGame extends StatefulWidget {
  const WordPlaceGame({Key? key}) : super(key: key);

  @override
  State<WordPlaceGame> createState() => _WordPlaceGameState();
}

class _WordPlaceGameState extends State<WordPlaceGame> {
  String sentence = "";
  int difficulty = 0;
  List<String> wordList = [];
  List<String?> placedWords = [];
  List<String> sentenceList = [];
  List<String?> incompleteSentenceList = [];

  AssetsAudioPlayer audio = AssetsAudioPlayer();
  bool isLoading = true;
  bool isEnglish = true;

  Future<void> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnglish = prefs.getBool('isEnglish') ?? true;

    if (mounted) {
      setState(() {
        this.isEnglish = isEnglish;
      });
    }
  }

  Future<void> getRandomSentence(bool locale) async {
    var collection = FirebaseFirestore.instance
        .collection('games')
        .doc('wordPlace')
        .collection('locale')
        .doc(isEnglish ? 'en' : 'ph')
        .collection('sentences');

    // Get all documents from the 'sentences' collection
    var documents = await collection.get();

    if (documents.docs.isNotEmpty) {
      // Get a random index using Random class
      var randomIndex = Random().nextInt(documents.docs.length);

      // Get the random document
      var randomDocument = documents.docs[randomIndex];

      // Get the "sentence" field value from the random document
      var randomSentence = randomDocument['sentence'];
      var docDifficulty = randomDocument['difficulty'];

      setState(() {
        difficulty = docDifficulty;
        sentence = randomSentence;
      });
    } else {
      print('No documents found in the collection');
    }
  }

  List<String> buildWordList(String sentence, int difficulty) {
    List<String> resultWords;
    List<String> omitted = [
      "the",
      "over",
      "and",
      "in",
      "on",
      "with",
      "to",
      "from",
      "at",
      "ay",
      "ang",
      "ng",
      "na",
      "mga",
      "nga",
      "sa",
      ".",
      ",",
      "-"
    ]; // Words omitted from the list are prepositions, conjunctions, and symbols

    List<String> words = sentence.split(' ');
    List<String> filteredWords = words
        .map((word) => word.replaceAll(RegExp(r'[^\w\s]'), ''))
        .where((word) => !omitted.contains(word.toLowerCase()))
        .toList();
    filteredWords.shuffle();

    // Take a number of items on the list based on the difficulty of the game
    switch (difficulty) {
      case 1:
        resultWords = filteredWords.take(2).toList();
        break;
      case 2:
        resultWords = filteredWords.take(3).toList();
        break;
      case 3:
        resultWords = filteredWords.take(5).toList();
        break;
      default:
        resultWords = filteredWords.take(8).toList();
        break;
    }

    return resultWords;
  }

  List<String?> buildIncompleteSentenceList(
      List<String> wordList, List<String> sentenceList) {
    return sentenceList
        .map((word) => wordList.contains(word) ? word : null)
        .toList();
  }

  List<String> buildSentenceList(String sentence) {
    List<String> words = sentence.split(' ');
    return words;
  }

  @override
  void initState() {
    super.initState();
    getLanguage().then((_) {
      getRandomSentence(isEnglish).then((_) {
        setState(() {
          wordList = buildWordList(sentence, difficulty);
          sentenceList = buildSentenceList(sentence);
          incompleteSentenceList =
              buildIncompleteSentenceList(wordList, sentenceList);
          placedWords = List.filled(sentenceList.length, null);
          isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    void showResultModal(BuildContext context, bool isPassed) {
      if (isPassed) {
        GameFirestore(userId: Auth().getCurrentUserId()!)
            .addScoreToGame("storyBuilding", isPassed);
        audio.open(Audio('assets/sounds/correct.mp3'));
      } else {
        GameFirestore(userId: Auth().getCurrentUserId()!)
            .addScoreToGame("storyBuilding", isPassed);
        audio.open(Audio('assets/sounds/wrong.mp3'));
      }

      showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        isDismissible: isPassed ? false : true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
        builder: (context) {
          return WillPopScope(
            onWillPop: () async {
              return isPassed ? false : true;
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isPassed ? Icons.check : Icons.close,
                        color: isPassed
                            ? const Color.fromARGB(255, 52, 156, 55)
                            : const Color.fromARGB(255, 196, 47, 36),
                        size: 40,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isPassed
                            ? (isEnglish ? 'Great job!' : 'Mahusay!')
                            : ('Better luck next time.'),
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
                                builder: (context) => const WordPlaceGame()),
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

    return Scaffold(
      body: isLoading
          ? const LoadingPage()
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEnglish
                        ? "Tap and drag the blocks on the left to the right place."
                        : "Pindutin at iurong ang mga kahon sa tamang lugar.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  Column(
                    children: [
                      // List of drag targets
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: sentenceList.asMap().entries.map((entry) {
                          int index = entry.key;
                          String word = entry.value;
                          if (incompleteSentenceList[index] != null) {
                            return Draggable<String>(
                              data: placedWords[index] ?? "",
                              feedback: buildWordTile(placedWords[index] ?? "",
                                  isDragTarget: true),
                              child: DragTarget<String>(
                                builder: (BuildContext context,
                                    List<String?> candidateData,
                                    List<dynamic> rejectedData) {
                                  return placedWords[index] != null
                                      ? buildWordTile(placedWords[index]!,
                                          isDragTarget: true)
                                      : inactiveDragTarget();
                                },
                                onWillAccept: (data) => true,
                                onAccept: (data) {
                                  setState(() {
                                    // Check if the word is already placed in any of the targets
                                    for (int i = 0;
                                        i < placedWords.length;
                                        i++) {
                                      if (placedWords[i] == data) {
                                        // If yes, remove it from the target
                                        placedWords[i] = null;
                                        // Add it back to the wordList
                                        wordList.add(data);
                                        break; // Break the loop once the word is found and removed
                                      }
                                    }
                                    // Place the new word on the current target
                                    placedWords[index] = data;
                                    // Remove the accepted word from the wordList
                                    wordList.remove(data);
                                  });
                                },
                              ),
                            );
                          } else {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Text(
                                word,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            );
                          }
                        }).toList(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: wordList.map((word) {
                          return Visibility(
                            visible: !placedWords.contains(word),
                            child: Draggable<String>(
                              data: word,
                              feedback: buildWordTile(word, isFeedback: true),
                              childWhenDragging: buildEmptyWordTile(),
                              child: buildWordTile(word),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          bool isCorrect = true;

          // Check if the placed words match the sentenceList
          for (int i = 0; i < placedWords.length; i++) {
            if (placedWords[i] != incompleteSentenceList[i]) {
              isCorrect = false;
              break; // Break the loop if a mismatch is found
            }
          }

          if (isCorrect) {
            showResultModal(context, true); // Answer is correct
          } else {
            showResultModal(context, false); // Incorrect
          }
        },
        label: const Text('Done'),
        icon: const Icon(Icons.check),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Function to build an inactive drag target without text
  Widget inactiveDragTarget() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8.0),
        color: Theme.of(context).primaryColorLight,
      ),
      width: 80,
      height: 40,
    );
  }

  Widget buildWordTile(String word,
      {bool isFeedback = false, bool isDragTarget = false}) {
    Color backgroundColor;

    if (isFeedback) {
      backgroundColor = Theme.of(context).primaryColorDark.withOpacity(0.7);
    } else if (isDragTarget) {
      backgroundColor = placedWords.contains(word)
          ? Theme.of(context).primaryColorDark
          : Theme.of(context).primaryColorLight;
    } else {
      backgroundColor = Theme.of(context).primaryColorDark;
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8.0),
        color: backgroundColor,
      ),
      child: Text(
        word,
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
    );
  }

  Widget buildEmptyWordTile() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.grey.withOpacity(0.5),
      ),
      width: 0,
      height: 40,
    );
  }
}
