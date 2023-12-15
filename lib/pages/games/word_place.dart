import 'package:flutter/material.dart';

class WordPlaceGame extends StatefulWidget {
  const WordPlaceGame({Key? key}) : super(key: key);

  @override
  State<WordPlaceGame> createState() => _WordPlaceGameState();
}

class _WordPlaceGameState extends State<WordPlaceGame> {
  List<String> wordList = ['Apple', 'Banana', 'Orange', 'Grapes', 'Mango'];
  List<String?> placedWords = [null, null, null, null, null];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Tap and drag the blocks on the left to the right place.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: wordList.map((word) {
                      return Visibility(
                        visible: !placedWords.contains(word),
                        child: Draggable<String>(
                          data: word,
                          child: buildWordTile(word),
                          feedback: buildWordTile(word, isFeedback: true),
                          childWhenDragging: buildEmptyWordTile(),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // List of drag targets
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(placedWords.length, (index) {
                      return DragTarget<String>(
                        builder: (BuildContext context,
                            List<String?> candidateData,
                            List<dynamic> rejectedData) {
                          return buildWordTile(placedWords[index] ?? '',
                              isDragTarget: true);
                        },
                        onWillAccept: (data) => true,
                        onAccept: (data) {
                          setState(() {
                            placedWords[index] = data;
                          });
                        },
                      );
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (placedWords.every((word) => word != null)) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Congratulations!'),
                  content: Text('You correctly placed all the words.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Incomplete'),
                  content: Text('Please place all the words.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        },
        child: Icon(Icons.check),
      ),
    );
  }

  Widget buildWordTile(String word,
      {bool isFeedback = false, bool isDragTarget = false}) {
    return Container(
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.all(8.0),
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
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.all(8.0),
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
