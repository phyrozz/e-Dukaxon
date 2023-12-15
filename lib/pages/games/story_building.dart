import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/firestore_data/games.dart';
import 'package:e_dukaxon/homepage_tree.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoryBuildingGame extends StatefulWidget {
  const StoryBuildingGame({Key? key}) : super(key: key);

  @override
  State<StoryBuildingGame> createState() => _StoryBuildingGameState();
}

class _StoryBuildingGameState extends State<StoryBuildingGame> {
  String sentence = "The quick brown fox jumps over the lazy dog";
  List<String> wordList = [];
  List<String?> placedWords = [null, null, null, null, null];
  List<String> sentenceList = [];

  AssetsAudioPlayer audio = AssetsAudioPlayer();
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

  List<String> buildWordList(String sentence) {
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
      ".",
      ","
    ]; // Words omitted from the list are prepositions, conjunctions, and symbols

    List<String> words = sentence.split(' ');
    List<String> filteredWords = words
        .map((word) => word.replaceAll(RegExp(r'[^\w\s]'), ''))
        .where((word) => !omitted.contains(word.toLowerCase()))
        .toList();
    filteredWords.shuffle();
    List<String> resultWords = filteredWords.take(5).toList();

    return resultWords;
  }

  List<String> buildSentenceList(String sentence) {
    List<String> words = sentence.split(' ');
    return words;
  }

  @override
  void initState() {
    getLanguage();
    setState(() {
      wordList = buildWordList(sentence);
      sentenceList = buildSentenceList(sentence);
    });
    print(wordList.contains(sentenceList[4]));
    print(wordList);
    print(sentenceList);
    print(placedWords);
    super.initState();
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
                                builder: (context) =>
                                    const StoryBuildingGame()),
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
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isEnglish
                  ? "Tap and drag the blocks on the left to the right place."
                  : "Pindutin at iurong ang mga kahon sa tamang lugar.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Column(
              children: [
                // List of drag targets
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(sentenceList.length, (index) {
                    if (wordList.contains(sentenceList[index])) {
                      return DragTarget<String>(
                        builder: (BuildContext context,
                            List<String?> candidateData,
                            List<dynamic> rejectedData) {
                          return buildWordTile(sentenceList[index],
                              isDragTarget: true);
                        },
                        onWillAccept: (data) => true,
                        onAccept: (data) {
                          // Check if the index is within the valid range
                          if (index >= 0 && index < placedWords.length) {
                            // Check if the correct drag target is being selected
                            if (wordList.contains(sentenceList[index])) {
                              setState(() {
                                placedWords[index] = data;
                              });

                              // Remove the accepted word from the wordList
                              wordList.remove(data);
                            }
                          }
                        },
                      );
                    } else {
                      return Text(sentenceList[index]);
                    }
                  }),
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
          if (wordList.isEmpty) {
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

  Widget buildWordTile(String word,
      {bool isFeedback = false, bool isDragTarget = false}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8.0),
        color: isFeedback
            ? Theme.of(context).primaryColorDark.withOpacity(0.7)
            : isDragTarget
                ? placedWords.contains(word)
                    ? Theme.of(context).primaryColorDark
                    : Theme.of(context).primaryColorLight
                : Theme.of(context).primaryColorDark,
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
