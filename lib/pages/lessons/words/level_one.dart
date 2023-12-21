import 'dart:async';

import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/firebase_storage.dart';
import 'package:e_dukaxon/firestore_data/word_lessons.dart';
import 'package:e_dukaxon/pages/lessons/words/level_two.dart';
import 'package:e_dukaxon/pages/loading.dart';
import 'package:e_dukaxon/play_lesson.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart' as just_audio;

class WordsLevelOne extends StatefulWidget {
  final String lessonName;

  const WordsLevelOne({Key? key, required this.lessonName}) : super(key: key);

  @override
  State<WordsLevelOne> createState() => _WordsLevelOneState();
}

class _WordsLevelOneState extends State<WordsLevelOne> {
  late ScrollController scrollController;
  final playLesson = PlayLesson();

  String levelDescription = "";
  String uid = "";
  List<dynamic> texts = [];
  List<dynamic> images = [];
  List<dynamic> sounds = [];
  bool isLoading = true;
  bool showOverlay = true;
  bool isEnglish = true;
  bool isLoadingAudio = false;
  bool isPlaying = false;
  AudioPlayer audio = AudioPlayer();
  int currentIndex = 0;

  // List of audio players for the play lesson mode
  List<just_audio.AudioPlayer> players = [];

  // bool states for the TTS feature on lessons
  bool isPlayingAudio = false;
  bool isSpeakingTtsText = false;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    getLanguage().then((value) {
      getLevel1DataByName(widget.lessonName);
    });

    // Add event listener for playback status
    audio.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showOverlay = false;
        });
      }
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

  void getLevel1DataByName(String lessonName) async {
    try {
      final userId = Auth().getCurrentUserId();
      Map<String, dynamic>? lessonData =
          await WordLessonFirestore(userId: userId!)
              .getLessonData(lessonName, isEnglish ? "en" : "ph");

      if (lessonData != null && lessonData.containsKey('level1')) {
        Map<String, dynamic> level1Data =
            lessonData['level1'] as Map<String, dynamic>;
        String description = level1Data['description'] as String;
        Iterable<dynamic> _texts = level1Data['texts'];
        Iterable<dynamic> _images = level1Data['images'];
        Iterable<dynamic> _sounds = level1Data['sounds'];

        _images = await Future.wait(
            _images.map((e) => AssetFirebaseStorage().getAsset(e)));
        _sounds = await Future.wait(
            _sounds.map((e) => AssetFirebaseStorage().getAsset(e)));

        if (mounted) {
          setState(() {
            levelDescription = description;
            texts = _texts.toList();
            images = _images.toList();
            sounds = _sounds.toList();
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
      if (!context.mounted) return;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  WordsLevelTwo(lessonName: lessonName)));
    }
  }

  Future<void> playTextsAndScroll() async {
    // Check if the scroll position is not at the top
    if (scrollController.offset > 0) {
      // Scroll to the top before continuing with the function
      scrollController.animateTo(0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutCubic);
    }

    // Filter out null items from the sounds list
    List nonNullSounds = sounds.where((sound) => sound != null).toList();
    List ttsTextSounds = texts.toList();

    players = List.generate(
      nonNullSounds.length + ttsTextSounds.length,
      (_) => just_audio.AudioPlayer(),
    );

    try {
      for (int i = 0; i < players.length; i++) {
        if (i == 0) {
          // Plays the first index of the texts list
          await players[i].setAudioSource(
              await playLesson.getTtsAudioSource(ttsTextSounds[0]!));
          if (mounted) {
            setState(() {
              isSpeakingTtsText = true;
            });
          }
          await players[i].play();
          if (mounted) {
            setState(() {
              isSpeakingTtsText = false;
            });
          }
          playLesson.scrollPage(scrollController, 300);
        } else {
          if (i % 2 == 1) {
            // If the index is odd, play TTS audio

            int ttsIndex = (i - 1) ~/ 2 + 1;
            await players[i].setAudioSource(
                await playLesson.getTtsAudioSource(ttsTextSounds[ttsIndex]!));

            if (mounted) {
              setState(() {
                isSpeakingTtsText = true;
              });
            }
            // Play the audio
            await players[i].play();
            if (mounted) {
              setState(() {
                isSpeakingTtsText = false;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                isPlaying = true;
              });
            }
            // If the index is even, play lesson audio
            int lessonIndex = (i - 2) ~/ 2;
            await players[i].setAudioSource(await playLesson
                .getLessonAudioSource(nonNullSounds[lessonIndex]!));

            // Play the audio
            await players[i].play();
            if (mounted) {
              setState(() {
                isPlaying = false;
              });
            }
            // Scrolls the page after each audio playback
            playLesson.scrollPage(
                scrollController, MediaQuery.of(context).size.height);
          }
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
    audio.dispose();
    for (var e in players) {
      e.dispose();
    }
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const LoadingPage()
          : Stack(
              children: [
                SingleChildScrollView(
                  controller: scrollController,
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
                                levelDescription,
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
                                children: texts.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  String text = entry.value;

                                  List<Widget> columnChildren = [
                                    const SizedBox(height: 20),
                                    if (images[index] is String)
                                      Image.network(
                                        images[index] is String
                                            ? images[index] as String
                                            : '', // Use an empty string if the image is not a String (placeholder)
                                        width: 200,
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null) {
                                            // Image has finished loading
                                            return child;
                                          } else {
                                            // Image is still loading, show a CircularProgressIndicator
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        (loadingProgress
                                                                .expectedTotalBytes ??
                                                            1)
                                                    : null,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    const SizedBox(height: 20),
                                    Container(
                                      decoration: ShapeDecoration(
                                          color: isSpeakingTtsText
                                              ? Colors.yellow
                                              : Colors.transparent,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)))),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Text(
                                          text,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    if (sounds[index] is String)
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          if (isPlaying) {
                                            // If currently in playback state, stop the audio
                                            await audio.stop();
                                          } else {
                                            // If not in playback state, start playing the audio
                                            if (mounted) {
                                              setState(() {
                                                isLoadingAudio = true;
                                              });
                                            }

                                            await audio
                                                .play(UrlSource(sounds[index]));
                                            if (mounted) {
                                              setState(() {
                                                isLoadingAudio = false;
                                              });
                                            }
                                          }
                                        },
                                        icon: isPlaying
                                            ? const Icon(Icons.stop)
                                            : const Icon(Icons.volume_up),
                                        label: isPlaying
                                            ? const Text("Stop")
                                            : Text(isEnglish
                                                ? "Listen"
                                                : "Pakinggan"),
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStatePropertyAll(
                                                    isPlaying
                                                        ? Theme.of(context)
                                                            .focusColor
                                                        : Theme.of(context)
                                                            .primaryColorDark)),
                                      ),
                                    const SizedBox(height: 50),
                                  ];
                                  return Column(
                                    children: columnChildren,
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 50),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                      isEnglish
                                          ? 'Click the button to start playing'
                                          : 'Pindutin ito upang magsimulang maglaro',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(fontSize: 18)),
                                  const Icon(
                                    Icons.arrow_right_alt_rounded,
                                    size: 40,
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton.icon(
                                    label:
                                        Text(isEnglish ? "Done" : "Tapos na"),
                                    icon: const Icon(Icons.check),
                                    style: const ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(
                                          Color.fromARGB(255, 52, 156, 55)),
                                    ),
                                    onPressed: () => Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => WordsLevelTwo(
                                                lessonName:
                                                    widget.lessonName))),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 80,
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
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Center(
                            child: Row(
                              children: [
                                Text(
                                  isEnglish
                                      ? 'Scroll down to read more'
                                      : 'Pumindot pababa upang mabasa lahat',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Icon(
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (isPlayingAudio) {
            // If currently playing, stop the audio
            for (var player in players) {
              player.dispose();
            }
            if (mounted) {
              setState(() {
                isPlayingAudio = false;
              });
            }
          } else {
            // If not playing, start playing TTS and scroll
            if (mounted) {
              setState(() {
                isPlayingAudio = true;
              });
            }

            await playTextsAndScroll();
            if (mounted) {
              setState(() {
                isPlayingAudio = false;
              });
            }
          }
        },
        label: Text(isPlayingAudio ? "Stop" : "Play"),
        icon: Icon(isPlayingAudio ? Icons.stop : Icons.play_arrow),
        backgroundColor: isPlayingAudio
            ? Theme.of(context).focusColor
            : Theme.of(context).primaryColorDark,
      ),
    );
  }
}
