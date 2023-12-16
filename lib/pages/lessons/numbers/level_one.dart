import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/firebase_storage.dart';
import 'package:e_dukaxon/firestore_data/number_lessons.dart';
import 'package:e_dukaxon/pages/lessons/numbers/level_two.dart';
import 'package:e_dukaxon/pages/loading.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NumbersLevelOne extends StatefulWidget {
  final String lessonName;

  const NumbersLevelOne({Key? key, required this.lessonName}) : super(key: key);

  @override
  State<NumbersLevelOne> createState() => _NumbersLevelOneState();
}

class _NumbersLevelOneState extends State<NumbersLevelOne> {
  String levelDescription = "";
  String uid = "";
  List<dynamic> texts = [];
  List<dynamic> images = [];
  List<dynamic> sounds = [];
  bool isLoading = true;
  bool showOverlay = true;
  bool isEnglish = true;
  AudioPlayer audio = AudioPlayer();

  @override
  void initState() {
    getLanguage().then((value) {
      getLevelDataByName(widget.lessonName);
    });
    super.initState();
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

  void getLevelDataByName(String lessonName) async {
    try {
      final userId = Auth().getCurrentUserId();
      Map<String, dynamic>? lessonData =
          await NumberLessonFirestore(userId: userId!)
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
            'Number lesson "$lessonName" was not found within the Firestore.');
        isLoading = true;
      }
    } catch (e) {
      print('Error: $e');
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
    return Scaffold(
      body: isLoading
          ? const LoadingPage()
          : Stack(
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
                                        images[index] as String,
                                        width: 30,
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
                                          onPressed: () => audio
                                              .play(UrlSource(sounds[index])),
                                          icon: const Icon(Icons.volume_up),
                                          label: Text(isEnglish
                                              ? "Listen"
                                              : "Pakinggan")),
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
                                                NumbersLevelTwo(
                                                    lessonName:
                                                        widget.lessonName))),
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
    );
  }
}
