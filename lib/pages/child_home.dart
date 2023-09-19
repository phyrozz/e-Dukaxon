import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/data/letter_lessons.dart';
import 'package:e_dukaxon/pages/lessons/letters/level_one.dart';
import 'package:e_dukaxon/user_firestore.dart';
import 'package:e_dukaxon/widgets/new_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:e_dukaxon/assessment_data.dart';

class ChildHomePage extends StatefulWidget {
  const ChildHomePage({super.key});

  @override
  State<ChildHomePage> createState() => _ChildHomePageState();
}

class _ChildHomePageState extends State<ChildHomePage> {
  List letterLessonNames = [];
  List letterLessonProgress = [];
  List unlockedLetterLessons = [];

  // Future<void> initializeGameDataOnFirestore() async {
  //   String? user = Auth().getCurrentUserId();
  //   await FirebaseFirestore.instance.collection('soundLessons').doc(user).set({
  //     "lessonOne": {
  //       "progress": 0,
  //       "lessonStartedAt": null,
  //     }
  //   });
  // }

  Future<void> letterLessons() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/letter_lessons.json');
      final jsonString = await file.readAsString();
      final List<dynamic> jsonData = json.decode(jsonString);

      List<String> letterNames = [];
      List<bool> unlockedLessons = [];
      List<int> letterProgress = [];

      List<LetterLesson> letterLessons = jsonData.map((lesson) {
        return LetterLesson.fromJson(lesson);
      }).toList();

      for (var lesson in letterLessons) {
        letterNames.add(lesson.name);
        unlockedLessons.add(lesson.isUnlocked);
        letterProgress.add(lesson.progress);
      }

      setState(() {
        letterLessonNames = letterNames;
        unlockedLetterLessons = unlockedLessons;
        letterLessonProgress = letterProgress;
      });
    } catch (e) {
      print('Error reading JSON file: $e');
    }
  }

  List numberLessonRoutes = [
    '/games/traceLetter',
    '/games/traceLetter',
    '/games/traceLetter',
    '/games/traceLetter',
    '/games/traceLetter',
  ];
  List numberLessonNames = [
    'Lesson 1',
    'Lesson 2',
    'Lesson 3',
    'Lesson 4',
    'Lesson 5',
  ];
  List wordLessonRoutes = [
    '/games/traceLetter',
    '/games/traceLetter',
    '/games/traceLetter',
    '/games/traceLetter',
    '/games/traceLetter',
    '/games/traceLetter',
    '/games/traceLetter',
  ];
  List wordLessonNames = [
    'Lesson 1',
    'Lesson 2',
    'Lesson 3',
    'Lesson 4',
    'Lesson 5',
    'Lesson 6',
    'Lesson 7',
  ];
  List sentenceLessonRoutes = [
    '/games/traceLetter',
    '/games/traceLetter',
    '/games/traceLetter',
    '/games/traceLetter',
  ];
  List sentenceLessonNames = [
    'Lesson 1',
    'Lesson 2',
    'Lesson 3',
    'Lesson 4',
  ];

  List<bool> unlockedNumberLessons = [false, false, false, false, false];
  List<bool> unlockedWordLessons = [
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  List<bool> unlockedSentenceLessons = [false, false, false, false];

  Alignment headerPosition = Alignment.topLeft;
  Alignment containerPosition = Alignment.bottomLeft;
  double containerOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    // initializeGameDataOnFirestore();
    // initLetterLessonData();
    // addNewLetterLesson();
    letterLessons();
    checkNewAccountAndNavigate();
    // Rebuild the screen after 3s which will process the animation
    Future.delayed(const Duration(milliseconds: 300))
        .then((value) => setState(() {
              headerPosition = Alignment.bottomCenter;
              containerPosition = Alignment.bottomCenter;
              containerOpacity = 1.0;
            }));

    if (!isParent) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown
      ]);
    }
  }

  Future<void> checkNewAccountAndNavigate() async {
    String? userId = Auth().getCurrentUserId();

    // Retrieve the user document from Firestore
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    // Check if it's a new account
    if (await UserFirestore(userId: userId!).getIsNewAccount()) {
      // Show the assessment page
      Navigator.pushReplacementNamed(context, '/assessment/init');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const WelcomeCustomAppBar(
            text: "Let's play!",
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 100.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 12,
                  ),
                  AnimatedAlign(
                    alignment: headerPosition,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOutCubic,
                    child: AnimatedOpacity(
                      opacity: containerOpacity,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      child: const Text(
                        'Letters',
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200.0,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 1.0,
                ),
                itemCount: letterLessonNames.length,
                itemBuilder: (context, index) {
                  bool isUnlocked = unlockedLetterLessons[index];
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: InkWell(
                      onTap: () {
                        if (isUnlocked) {
                          if (letterLessonProgress[index] >= 0) {
                            resetScore(letterLessonNames[index]);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LettersLevelOne(
                                        lessonName: letterLessonNames[index])));
                          }
                          // else if (letterLessonProgress[index] >= 25 &&
                          //     letterLessonProgress[index] < 50) {
                          //   LettersLevelOne(lessonName: letterLessonNames[index]);
                          // }
                        }
                      },
                      child: AnimatedOpacity(
                        opacity: isUnlocked
                            ? containerOpacity
                            : containerOpacity / 2,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutCubic,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    isUnlocked ? letterLessonNames[index] : '',
                                    style: const TextStyle(
                                        fontSize: 32.0, color: Colors.white),
                                  ),
                                ),
                                AnimatedAlign(
                                  alignment: containerPosition,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOutCubic,
                                  child: AnimatedOpacity(
                                    opacity: isUnlocked ? containerOpacity : 0,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOutCubic,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Container(
                                        width: 100.0,
                                        height: 100.0,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              blurRadius: 20,
                                              color: Color.fromARGB(
                                                  255, 121, 74, 25),
                                            ),
                                          ],
                                          color: Color(0xFFDFD7BF),
                                        ),
                                        child: CustomPaint(
                                          painter: CircularProgressBarPainter(
                                              letterLessonProgress[index]),
                                          child: Center(
                                            child: Text(
                                              '${letterLessonProgress[index]}%',
                                              style: const TextStyle(
                                                fontSize: 24.0,
                                                color: Color(0xFF3F2305),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 100.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 12,
                  ),
                  AnimatedAlign(
                    alignment: headerPosition,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOutCubic,
                    child: AnimatedOpacity(
                      opacity: containerOpacity,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      child: const Text(
                        'Numbers',
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200.0,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 1.0,
                ),
                itemCount: numberLessonRoutes.length,
                itemBuilder: (context, index) {
                  bool isUnlocked = unlockedNumberLessons[index];
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: InkWell(
                      onTap: isUnlocked
                          ? () => Navigator.pushNamed(
                              context, numberLessonRoutes[index])
                          : null,
                      child: AnimatedOpacity(
                        opacity: isUnlocked
                            ? containerOpacity
                            : containerOpacity / 2,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutCubic,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    isUnlocked ? numberLessonNames[index] : '',
                                    style: const TextStyle(
                                        fontSize: 18.0, color: Colors.white),
                                  ),
                                ),
                                AnimatedAlign(
                                  alignment: containerPosition,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOutCubic,
                                  child: AnimatedOpacity(
                                    opacity: isUnlocked ? containerOpacity : 0,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOutCubic,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Container(
                                        width: 100.0,
                                        height: 100.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color.fromARGB(
                                                255, 121, 74, 25),
                                            width: 10.0,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              blurRadius: 20,
                                              color: Color.fromARGB(
                                                  255, 121, 74, 25),
                                            ),
                                          ],
                                          color: const Color(0xFFDFD7BF),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            '${75}%',
                                            // '${progressPercentage.toStringAsFixed(0)}%',
                                            style: TextStyle(
                                              fontSize: 24.0,
                                              color: Color(0xFF3F2305),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 100.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 12,
                  ),
                  AnimatedAlign(
                    alignment: headerPosition,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOutCubic,
                    child: AnimatedOpacity(
                      opacity: containerOpacity,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      child: const Text(
                        'Words',
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200.0,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 1.0,
                ),
                itemCount: wordLessonRoutes.length,
                itemBuilder: (context, index) {
                  bool isUnlocked = unlockedWordLessons[index];
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: InkWell(
                      onTap: isUnlocked
                          ? () => Navigator.pushNamed(
                              context, wordLessonRoutes[index])
                          : null,
                      child: AnimatedOpacity(
                        opacity: isUnlocked
                            ? containerOpacity
                            : containerOpacity / 2,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutCubic,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    isUnlocked ? wordLessonNames[index] : '',
                                    style: const TextStyle(
                                        fontSize: 18.0, color: Colors.white),
                                  ),
                                ),
                                AnimatedAlign(
                                  alignment: containerPosition,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOutCubic,
                                  child: AnimatedOpacity(
                                    opacity: isUnlocked ? containerOpacity : 0,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOutCubic,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Container(
                                        width: 100.0,
                                        height: 100.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color.fromARGB(
                                                255, 121, 74, 25),
                                            width: 10.0,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              blurRadius: 20,
                                              color: Color.fromARGB(
                                                  255, 121, 74, 25),
                                            ),
                                          ],
                                          color: const Color(0xFFDFD7BF),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            '${75}%',
                                            // '${progressPercentage.toStringAsFixed(0)}%',
                                            style: TextStyle(
                                              fontSize: 24.0,
                                              color: Color(0xFF3F2305),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 100.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 12,
                  ),
                  AnimatedAlign(
                    alignment: headerPosition,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOutCubic,
                    child: AnimatedOpacity(
                      opacity: containerOpacity,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      child: const Text(
                        'Sentences',
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200.0,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 1.0,
                ),
                itemCount: sentenceLessonRoutes.length,
                itemBuilder: (context, index) {
                  bool isUnlocked = unlockedSentenceLessons[index];
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: InkWell(
                      onTap: isUnlocked
                          ? () => Navigator.pushNamed(
                              context, sentenceLessonRoutes[index])
                          : null,
                      child: AnimatedOpacity(
                        opacity: isUnlocked
                            ? containerOpacity
                            : containerOpacity / 2,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutCubic,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    isUnlocked
                                        ? sentenceLessonNames[index]
                                        : '',
                                    style: const TextStyle(
                                        fontSize: 18.0, color: Colors.white),
                                  ),
                                ),
                                AnimatedAlign(
                                  alignment: containerPosition,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOutCubic,
                                  child: AnimatedOpacity(
                                    opacity: isUnlocked ? containerOpacity : 0,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOutCubic,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Container(
                                        width: 100.0,
                                        height: 100.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color.fromARGB(
                                                255, 121, 74, 25),
                                            width: 10.0,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              blurRadius: 20,
                                              color: Color.fromARGB(
                                                  255, 121, 74, 25),
                                            ),
                                          ],
                                          color: const Color(0xFFDFD7BF),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            '${75}%',
                                            // '${progressPercentage.toStringAsFixed(0)}%',
                                            style: TextStyle(
                                              fontSize: 24.0,
                                              color: Color(0xFF3F2305),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CircularProgressBarPainter extends CustomPainter {
  final int progress;

  CircularProgressBarPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 10.0;
    final Paint borderPaint = Paint()
      ..color = const Color.fromARGB(255, 121, 74, 25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final Paint progressPaint = Paint()
      ..color = const Color(0xFFDFD7BF)
      ..style = PaintingStyle.fill;

    final double center = size.width / 2;
    final double radius = center - strokeWidth;

    // Draw the circular border
    canvas.drawCircle(Offset(center, center), radius, borderPaint);

    // Draw the progress arc
    double remainingAngle = 2 * pi * (100 - progress) / 100;
    canvas.drawArc(
        Rect.fromCircle(center: Offset(center, center), radius: radius + 5),
        -pi / 2,
        remainingAngle,
        true,
        progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// class SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
//   final double minHeight;
//   final double maxHeight;
//   final Widget child;
//   final String headerText;

//   SliverHeaderDelegate({
//     required this.minHeight,
//     required this.maxHeight,
//     required this.child,
//     required this.headerText,
//   });

//   @override
//   double get minExtent => minHeight;

//   @override
//   double get maxExtent => maxHeight;

//   @override
//   Widget build(
//     BuildContext context,
//     double shrinkOffset,
//     bool overlapsContent,
//   ) {
//     return Container(
//       color: Theme.of(context).primaryColor,
//       alignment: Alignment.center,
//       child: Text(
//         headerText,
//         style: const TextStyle(
//           fontSize: 32.0,
//           color: Colors.black,
//         ),
//       ),
//     );
//   }

//   @override
//   bool shouldRebuild(covariant SliverHeaderDelegate oldDelegate) {
//     return maxHeight != oldDelegate.maxHeight ||
//         minHeight != oldDelegate.minHeight ||
//         child != oldDelegate.child;
//   }
// }
