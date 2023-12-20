import 'dart:convert';

import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/firebase_storage.dart';
import 'package:e_dukaxon/firestore_data/letter_lessons.dart';
import 'package:e_dukaxon/main.dart';
import 'package:e_dukaxon/pages/lessons/letters/level_two.dart';
import 'package:e_dukaxon/pages/loading.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart' as just_audio;
import 'package:http/http.dart' as http;

class LettersLevelOne extends StatefulWidget {
  final String lessonName;

  const LettersLevelOne({Key? key, required this.lessonName}) : super(key: key);

  @override
  State<LettersLevelOne> createState() => _LettersLevelOneState();
}

class _LettersLevelOneState extends State<LettersLevelOne> {
  late ScrollController scrollController;
  final ttsPlayer = just_audio.AudioPlayer();

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
          await LetterLessonFirestore(userId: userId!)
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
                  LettersLevelTwo(lessonName: lessonName)));
    }
  }

  // Function to scroll through the page
  void scrollPage(double scrollValue) {
    scrollController.animateTo(
      scrollController.offset + scrollValue,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> playTextsAndScroll() async {
    for (int i = 0; i < texts.length; i++) {
      // Play TTS for the current text
      await playTextToSpeech(texts[i]).then((value) => {
            // Scroll the page
            if (i < texts.length - 1)
              {
                // Scroll down for all texts except the last one
                scrollPage(500)
              }
          });
    }
  }

  //For the Text To Speech
  Future<void> playTextToSpeech(String text) async {
    try {
      String voiceRachel =
          '21m00Tcm4TlvDq8ikWAM'; //Rachel voice - change if you know another Voice ID

      String url = 'https://api.elevenlabs.io/v1/text-to-speech/$voiceRachel';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'audio/mpeg',
          'xi-api-key': EL_API_KEY,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "text": text,
          "model_id": "eleven_multilingual_v2",
          "voice_settings": {"stability": 1, "similarity_boost": 1}
        }),
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes; //get the bytes ElevenLabs sent back
        await ttsPlayer.setAudioSource(MyCustomSource(
            bytes)); //send the bytes to be read from the JustAudio library
        ttsPlayer.play(); //play the audio
      } else {
        // throw Exception('Failed to load audio');
        print('Failed to load audio');
        return;
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    audio.dispose();
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
                                            builder: (context) =>
                                                LettersLevelTwo(
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
        onPressed: () {
          // Play TTS for the page's description
          playTextToSpeech(levelDescription).then((_) {
            // Scroll down after the description is finished
            scrollPage(200);

            // Play TTS for the texts and scroll
            playTextsAndScroll();
          });
        },
        label: const Text("Play"),
        icon: const Icon(Icons.play_arrow),
      ),
    );
  }
}

// Feed the retrieved AI TTS audio bytes into the player
class MyCustomSource extends just_audio.StreamAudioSource {
  final List<int> bytes;
  MyCustomSource(this.bytes);

  @override
  Future<just_audio.StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return just_audio.StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}
