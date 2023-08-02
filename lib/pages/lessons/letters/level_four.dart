import 'dart:convert';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:e_dukaxon/data/letter_lessons.dart';
import 'package:e_dukaxon/pages/lessons/letters/level_five.dart';
import 'package:e_dukaxon/pages/lessons/letters/level_two.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gif_view/gif_view.dart';

class LettersLevelFour extends StatefulWidget {
  final String lessonName;

  const LettersLevelFour({Key? key, required this.lessonName})
      : super(key: key);

  @override
  State<LettersLevelFour> createState() => _LettersLevelFourState();
}

class _LettersLevelFourState extends State<LettersLevelFour> {
  String? levelDescription;
  List<String> texts = [];
  List<dynamic> images = [];
  bool isLoading = true;
  bool showOverlay = true;
  final List<GifController> gifControllers = [];
  final List<String> gifControllerStatuses = [];

  @override
  void initState() {
    super.initState();
    getLevelDataByName(widget.lessonName);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showOverlay = false;
        });
      }
    });
  }

  LetterLesson? getLetterLessonByName(
      List<LetterLesson> letterLessons, String lessonName) {
    return letterLessons.firstWhere((lesson) => lesson.name == lessonName);
  }

  void getLevelDataByName(String lessonName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/letter_lessons.json');

    try {
      final jsonString = await file.readAsString();
      final List<dynamic> jsonData = json.decode(jsonString);

      List<LetterLesson> letterLessons = jsonData.map((lesson) {
        return LetterLesson.fromJson(lesson);
      }).toList();

      LetterLesson? lesson = getLetterLessonByName(letterLessons, lessonName);

      if (lesson != null) {
        Level levelData = lesson.level4;
        // print('Level 3 data for $lessonName: $levelData');
        setState(() {
          levelDescription = levelData.description;
          texts.clear();
          texts.addAll(levelData.texts!);
          images.addAll(levelData.images!);
          for (var i = 0; i < images.length; i++) {
            gifControllers.add(GifController(
                autoPlay: false,
                loop: false,
                onFinish: () {
                  for (int i = 0; i < gifControllerStatuses.length; i++) {
                    gifControllerStatuses[i] = "stopped";
                  }
                  ;
                }));
            gifControllerStatuses.add("stoped");
          }
          isLoading = false;
        });

        // print(images);
      } else {
        // print('LetterLesson with name $lessonName not found in JSON file');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // print('Error reading letter_lessons.json: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
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
                          levelDescription!,
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Text(
                          widget.lessonName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 72, fontWeight: FontWeight.bold),
                        ),
                        Column(
                          children: texts != null
                              ? texts.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  String text = entry.value;

                                  List<Widget> columnChildren = [
                                    const SizedBox(height: 20),
                                    if (images[index] is String)
                                      Column(
                                        children: [
                                          GifView.asset(
                                            images[index],
                                            controller: gifControllers[index],
                                            width: 200,
                                            frameRate: 15,
                                          ),
                                          SizedBox(height: 10),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              if (gifControllerStatuses[
                                                      index] ==
                                                  "playing") {
                                                gifControllers[index].stop();
                                                if (mounted) {
                                                  setState(() {
                                                    gifControllerStatuses[
                                                        index] = "stoped";
                                                  });
                                                }
                                              } else {
                                                gifControllers[index].play();
                                                if (mounted) {
                                                  setState(() {
                                                    gifControllerStatuses[
                                                        index] = "playing";
                                                  });
                                                }
                                              }
                                            },
                                            label: Text(
                                                gifControllerStatuses[index] ==
                                                        "playing"
                                                    ? 'Stop'
                                                    : 'Play'),
                                            icon:
                                                gifControllerStatuses[index] ==
                                                        "playing"
                                                    ? Icon(Icons.stop_rounded)
                                                    : Icon(Icons
                                                        .play_arrow_rounded),
                                          ),
                                        ],
                                      ),
                                    const SizedBox(height: 20),
                                    Text(
                                      text,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    const SizedBox(height: 50),
                                  ];
                                  return Column(
                                    children: columnChildren,
                                  );
                                }).toList()
                              : [],
                        ),
                        const SizedBox(height: 50),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              label: const Text("Done"),
                              icon: const Icon(Icons.check),
                              style: const ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    Color.fromARGB(255, 52, 156, 55)),
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LettersLevelFive(
                                            lessonName: widget.lessonName,
                                          )),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height - 75,
            left: MediaQuery.of(context).size.width / 2 - 140,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {},
              child: AnimatedOpacity(
                opacity: showOverlay ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: Row(
                        children: const [
                          Text(
                            'Scroll down to read more',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.arrow_downward,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
