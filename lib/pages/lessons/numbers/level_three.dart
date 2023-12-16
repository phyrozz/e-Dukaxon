import 'dart:math';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/firestore_data/number_lessons.dart';
import 'package:e_dukaxon/pages/lessons/numbers/result.dart';
import 'package:e_dukaxon/pages/loading.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NumbersLevelThree extends StatefulWidget {
  final String lessonName;

  const NumbersLevelThree({super.key, required this.lessonName});

  @override
  State<NumbersLevelThree> createState() => _NumbersLevelThreeState();
}

class _NumbersLevelThreeState extends State<NumbersLevelThree> {
  String levelDescription = "";
  String uid = "";
  List<dynamic> answers = [];
  bool isLoading = true;
  bool showOverlay = true;
  bool isEnglish = true;
  final List<List<Offset>> _strokes = [];
  String currentlyTracedLetter = "";
  double accuracy = 0;
  AssetsAudioPlayer audio = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    getLanguage().then((value) => getLevelDataByName(widget.lessonName));
    currentlyTracedLetter = widget.lessonName;
    _strokes.add([]);
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

      if (lessonData != null && lessonData.containsKey('level3')) {
        Map<String, dynamic> levelData =
            lessonData['level3'] as Map<String, dynamic>;
        String description = levelData['description'] as String;
        Iterable<dynamic> _answers = levelData['answers'];

        if (mounted) {
          setState(() {
            levelDescription = description;
            answers.addAll(_answers);
            uid = userId;
            isLoading = false;
          });
        }
      } else {
        print(
            'Numbers lesson "$lessonName" was not found within the Firestore.');
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

  double calculateAccuracy(List<Offset> userStrokes, String letter,
      double canvasWidth, double canvasHeight) {
    Map<String, List<Offset>> templates = {
      'a': [
        const Offset(100, 120),
        const Offset(120, 290),
        const Offset(100, 150),
        const Offset(60, 140),
        const Offset(30, 155),
        const Offset(10, 200),
        const Offset(15, 250),
        const Offset(30, 270),
        const Offset(70, 280),
        const Offset(110, 260),
      ],
      'b': [
        const Offset(20, 50),
        const Offset(20, 290),
        const Offset(20, 180),
        const Offset(70, 155),
        const Offset(100, 155),
        const Offset(135, 180),
        const Offset(135, 230),
        const Offset(100, 270),
        const Offset(70, 270),
        const Offset(20, 250),
      ],
      'c': [
        const Offset(120, 185),
        const Offset(70, 150),
        const Offset(40, 150),
        const Offset(20, 180),
        const Offset(15, 240),
        const Offset(30, 270),
        const Offset(70, 270),
        const Offset(110, 250),
      ]
    };

    // Calculate accuracy by comparing user's strokes with the template
    double distanceSum = 0;
    int pointCount = 0;

    final offsetX = canvasWidth / 2 - 50;
    final offsetY = canvasHeight / 2 - 150;

    List<Offset> templateStrokes = templates[letter] ?? [];

    for (int i = 0; i < min(userStrokes.length, templateStrokes.length); i++) {
      Offset adjustedTemplatePoint = Offset(
        templateStrokes[i].dx + offsetX,
        templateStrokes[i].dy + offsetY,
      );

      double distance = (userStrokes[i] - adjustedTemplatePoint).distance;
      distanceSum += distance;
      pointCount++;
    }

    // Normalize distanceSum to a percentage
    double accuracyPercentage = 1000 * (1 - distanceSum / (pointCount * 100));
    return accuracyPercentage.clamp(0, 100);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void showResultModal(BuildContext context, bool isPassed) {
      if (isPassed) {
        NumberLessonFirestore(userId: uid)
            .addScoreToLessonBy(widget.lessonName, isEnglish ? "en" : "ph", 10);
        audio.open(Audio('assets/sounds/correct.mp3'));
      } else {
        audio.open(Audio('assets/sounds/wrong.mp3'));
      }

      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFFF2EAD3),
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
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NumbersResultPage(
                                lessonName: widget.lessonName)),
                      );
                    },
                    child: Text(isEnglish ? 'Next' : 'Susunod'),
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
            body: Stack(
              children: [
                GestureDetector(
                  onPanUpdate: (DragUpdateDetails details) {
                    if (mounted) {
                      setState(() {
                        RenderBox renderBox =
                            context.findRenderObject() as RenderBox;
                        Offset localPosition =
                            renderBox.globalToLocal(details.globalPosition) -
                                const Offset(0, 0);

                        // Offset the localPosition by the position of the CustomPaint widget
                        Offset customPaintOffset = renderBox.localToGlobal(
                            Offset.zero); // Convert to global position
                        localPosition -= customPaintOffset;

                        _strokes.last.add(localPosition);

                        // Check accuracy
                        if (mounted) {
                          setState(() {
                            if (_strokes.isNotEmpty) {
                              accuracy = calculateAccuracy(
                                  _strokes.last,
                                  currentlyTracedLetter,
                                  MediaQuery.of(context).size.width,
                                  MediaQuery.of(context).size.height);
                              print(
                                  'Accuracy: ${accuracy.toStringAsFixed(2)}%');
                            }
                          });
                        }
                      });
                    }
                  },
                  onPanStart: (DragStartDetails details) {
                    if (mounted) {
                      setState(() {
                        _strokes.add([]);
                        currentlyTracedLetter = widget.lessonName;
                      });
                    }
                  },
                  child: CustomPaint(
                    painter: Painter(
                        strokes: _strokes, letter: currentlyTracedLetter),
                    size: Size.infinite,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_rounded),
                      label: Text(isEnglish ? 'Done' : 'Tapos na'),
                      style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            Color.fromARGB(255, 52, 156, 55)),
                      ).copyWith(
                          textStyle: const MaterialStatePropertyAll(TextStyle(
                              fontFamily: "OpenDyslexic", fontSize: 18))),
                      onPressed: () {
                        if (accuracy > 80) {
                          showResultModal(context, true);
                        } else {
                          showResultModal(context, false);
                        }
                      },
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        levelDescription,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontSize: 26),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColorDark,
              child: const FaIcon(FontAwesomeIcons.eraser),
              onPressed: () {
                if (mounted) {
                  setState(() {
                    _strokes.clear();
                  });
                }
              },
            ),
          );
  }
}

class Painter extends CustomPainter {
  final String letter;
  List<List<Offset>> strokes;

  Painter({required this.strokes, required this.letter});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the background color
    Paint backgroundPaint = Paint()..color = const Color(0xFFF2EAD3);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Draw the letter on the canvas
    const textStyle = TextStyle(
        color: Color.fromARGB(255, 175, 175, 175),
        fontSize: 300,
        fontFamily: 'Comic Sans');
    var textSpan = TextSpan(
      text: letter,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    // final offsetX = (size.width - textPainter.width) / 2; // Center horizontally
    // final offsetY = (size.height - textPainter.height) / 2; // Center vertically
    double offsetX = size.width / 2 - 50; // Center horizontally
    double offsetY = size.height / 2 - 150; // Center vertically

    Offset centerOffset = Offset(offsetX, offsetY);

    // Draw the letter "b" at the centered offset
    textPainter.paint(canvas, centerOffset);

    // Draw the brush strokes
    Paint paint = Paint()
      ..color = const Color(0xFF3F2305)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10.0;

    for (final stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        if (!stroke[i].isInfinite) {
          canvas.drawLine(stroke[i], stroke[i + 1], paint);
        }
      }
    }

    // Draw the template (visualization)
    Paint templatePaint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30.0;

    List<Offset> templateStrokes = getTemplateForLetter(letter);

    Path templatePath = Path();
    if (templateStrokes.isNotEmpty) {
      templatePath.moveTo(
          templateStrokes[0].dx + offsetX, templateStrokes[0].dy + offsetY);
      for (int i = 1; i < templateStrokes.length; i++) {
        templatePath.lineTo(
            templateStrokes[i].dx + offsetX, templateStrokes[i].dy + offsetY);
      }
    }
    canvas.drawPath(templatePath, templatePaint);
  }

  List<Offset> getTemplateForLetter(String letter) {
    Map<String, List<Offset>> templates = {
      'a': [
        const Offset(100, 120),
        const Offset(120, 290),
        const Offset(100, 150),
        const Offset(60, 140),
        const Offset(30, 155),
        const Offset(10, 200),
        const Offset(15, 250),
        const Offset(30, 270),
        const Offset(70, 280),
        const Offset(110, 260),
      ],
      'b': [
        const Offset(20, 50),
        const Offset(20, 290),
        const Offset(20, 180),
        const Offset(70, 155),
        const Offset(100, 155),
        const Offset(135, 180),
        const Offset(135, 230),
        const Offset(100, 270),
        const Offset(70, 270),
        const Offset(20, 250),
      ],
      'c': [
        const Offset(120, 185),
        const Offset(70, 150),
        const Offset(40, 150),
        const Offset(20, 180),
        const Offset(15, 240),
        const Offset(30, 270),
        const Offset(70, 270),
        const Offset(110, 250),
      ]
    };

    return templates[letter] ?? [];
  }

  @override
  bool shouldRepaint(Painter oldDelegate) => true;
}
