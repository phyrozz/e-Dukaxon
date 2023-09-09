import 'dart:convert';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:e_dukaxon/data/letter_lessons.dart';
import 'package:e_dukaxon/pages/lessons/letters/level_two.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LettersLevelOne extends StatefulWidget {
  final String lessonName;

  const LettersLevelOne({Key? key, required this.lessonName}) : super(key: key);

  @override
  State<LettersLevelOne> createState() => _LettersLevelOneState();
}

class _LettersLevelOneState extends State<LettersLevelOne> {
  String? levelDescription;
  List<String> texts = [];
  List<dynamic> images = [];
  List<dynamic> sounds = [];
  bool isLoading = true;
  bool showOverlay = true;
  bool isEnglish = true;
  AssetsAudioPlayer audio = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    getLevel1DataByName(widget.lessonName);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showOverlay = false;
        });
      }
    });
    getLanguage();
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

  LetterLesson? getLetterLessonByName(
      List<LetterLesson> letterLessons, String lessonName) {
    return letterLessons.firstWhere((lesson) => lesson.name == lessonName);
  }

  void getLevel1DataByName(String lessonName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/letter_lessons.json');

    try {
      final jsonString = await file.readAsString();
      final List<dynamic> jsonData = json.decode(jsonString);

      List<LetterLesson> letterLessons = jsonData.map((lesson) {
        return LetterLesson.fromJson(lesson);
      }).toList();

      // // Filter the letterLessons list to include only lessons with "locale" set to "en"
      // final List<LetterLesson> enLessons = letterLessons
      //     .where((lesson) =>
      //         isEnglish ? lesson.locale == "en" : lesson.locale == "ph")
      //     .toList();

      LetterLesson? lesson = getLetterLessonByName(letterLessons, lessonName);

      if (lesson != null) {
        Level levelData = lesson.level1;
        print('Level 1 data for $lessonName: $levelData');
        if (mounted) {
          setState(() {
            levelDescription = levelData.description;
            texts.clear();
            texts.addAll(levelData.texts!);
            images.addAll(levelData.images!);
            sounds.addAll(levelData.sounds!);
            isLoading = false;
          });
        }
      } else {
        print('LetterLesson with name $lessonName not found in JSON file');
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error reading letter_lessons.json: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
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
                                      Image.asset(
                                        images[index] as String,
                                        width: 200,
                                      ),
                                    const SizedBox(height: 20),
                                    Text(
                                      text,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    const SizedBox(height: 20),
                                    if (sounds[index] is String)
                                      ElevatedButton.icon(
                                          onPressed: () =>
                                              audio.open(Audio(sounds[index])),
                                          icon: const Icon(Icons.volume_up),
                                          label: const Text("Listen")),
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
                            Text('Click the button to start playing',
                                style: Theme.of(context).textTheme.bodySmall),
                            const Icon(
                              Icons.arrow_right_alt_rounded,
                              size: 40,
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              label: const Text("Done"),
                              icon: const Icon(Icons.check),
                              style: const ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    Color.fromARGB(255, 52, 156, 55)),
                              ),
                              onPressed: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LettersLevelTwo(
                                          lessonName: widget.lessonName))),
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
              child: AnimatedOpacity(
                opacity: showOverlay ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Center(
                      child: Row(
                        children: [
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
