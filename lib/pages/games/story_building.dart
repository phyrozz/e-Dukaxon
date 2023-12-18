import 'dart:math';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/firestore_data/games.dart';
import 'package:e_dukaxon/homepage_tree.dart';
import 'package:e_dukaxon/pages/loading.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoryBuildingGame extends StatefulWidget {
  const StoryBuildingGame({Key? key}) : super(key: key);

  @override
  State<StoryBuildingGame> createState() => _StoryBuildingGameState();
}

class _StoryBuildingGameState extends State<StoryBuildingGame> {
  List<dynamic> sentenceList = [];
  List<String?> placedSentences = [];
  List<dynamic> storyList = [];

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

  Future<void> getRandomStory(bool locale) async {
    var collection = FirebaseFirestore.instance
        .collection('games')
        .doc('storyBuilding')
        .collection('locale')
        .doc(isEnglish ? 'en' : 'ph')
        .collection('stories');

    // Get all documents from the 'sentences' collection
    var documents = await collection.get();

    if (documents.docs.isNotEmpty) {
      // Get a random index using Random class
      var randomIndex = Random().nextInt(documents.docs.length);

      // Get the random document
      var randomDocument = documents.docs[randomIndex];

      // Get the "sentence" field value from the random document
      List<dynamic> randomStory = randomDocument['story'];

      setState(() {
        sentenceList = randomStory;
      });
    } else {
      print('No documents found in the collection');
    }
  }

  List<dynamic> buildSentenceList(List<dynamic> story) {
    story.shuffle();
    return story;
  }

  @override
  void initState() {
    super.initState();
    getLanguage().then((_) {
      getRandomStory(isEnglish).then((_) {
        setState(() {
          storyList = buildSentenceList(sentenceList);
          placedSentences = List.filled(storyList.length, null);
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
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
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
                          fontSize: 24,
                          fontFamily: "OpenDyslexic",
                        ),
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
                              builder: (context) => const HomePageTree(),
                            ),
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
                              builder: (context) => const StoryBuildingGame(),
                            ),
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
                        ? "Tap and drag the blocks in the right order."
                        : "Pindutin at iurong ang mga kahon sa tamang ayos.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Expanded(
                    child: ReorderableListView(
                      onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          final dynamic item = storyList.removeAt(oldIndex);
                          storyList.insert(newIndex, item);
                        });
                      },
                      children: storyList
                          .map(
                            (word) => ReorderableDelayedDragStartListener(
                              key: ValueKey(word),
                              index: storyList.indexOf(word),
                              child: DragTarget<String>(
                                builder: (BuildContext context,
                                    List<String?> candidateData,
                                    List<dynamic> rejectedData) {
                                  return Draggable<String>(
                                    data: word,
                                    feedback:
                                        buildWordTile(word, isFeedback: true),
                                    child: buildWordTile(word),
                                  );
                                },
                                onWillAccept: (data) => true,
                                onAccept: (data) {
                                  setState(() {
                                    if (data != null) {
                                      final int oldIndex =
                                          storyList.indexOf(data);
                                      final int newIndex =
                                          storyList.indexOf(word);
                                      storyList.removeAt(oldIndex);
                                      storyList.insert(newIndex, data);
                                    }
                                  });
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          bool isCorrect = ListEquality().equals(placedSentences, storyList);

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

  Widget buildWordTile(String word, {bool isFeedback = false}) {
    Color backgroundColor;

    if (isFeedback) {
      backgroundColor = Theme.of(context).primaryColorDark.withOpacity(0.7);
    } else {
      backgroundColor = Theme.of(context).primaryColorDark;
    }

    return Container(
      key: ValueKey(word),
      padding: const EdgeInsets.all(4.0),
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8.0),
        color: backgroundColor,
      ),
      child: Text(
        word,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
    );
  }
}
