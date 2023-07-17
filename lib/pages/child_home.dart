import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_dukaxon/widgets/app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChildHomePage extends StatefulWidget {
  const ChildHomePage({super.key});

  @override
  State<ChildHomePage> createState() => _ChildHomePageState();
}

class _ChildHomePageState extends State<ChildHomePage> {
  // Add more lessons based on needs assessment
  List letterLessonRoutes = [
    '/games/traceLetter',
    '/games/traceLetter',
    '/games/traceLetter',
    '/games/traceLetter',
    '/games/traceLetter',
  ];
  List letterLessonNames = [
    'Lesson 1',
    'Lesson 2',
    'Lesson 3',
    'Lesson 4',
    'Lesson 5',
  ];
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

  List<bool> unlockedLetterLessons = [true, false, false, false, false];
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
    checkNewAccountAndNavigate();
    // Rebuild the screen after 3s which will process the animation from green to blue
    Future.delayed(const Duration(milliseconds: 300))
        .then((value) => setState(() {
              headerPosition = Alignment.bottomCenter;
              containerPosition = Alignment.bottomCenter;
              containerOpacity = 1.0;
            }));
  }

  Future<void> checkNewAccountAndNavigate() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? currentUser = auth.currentUser;

    // Retrieve the user document from Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .get();

    // Check if it's a new account
    if (userDoc.exists && userDoc.data()?['isNewAccount'] == true) {
      // Show the assessment page
      Navigator.pushReplacementNamed(context, '/assessment/init');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(isHomePage: true),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
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
                itemCount: letterLessonRoutes.length,
                itemBuilder: (context, index) {
                  bool isUnlocked = unlockedLetterLessons[index];
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: InkWell(
                      onTap: isUnlocked
                          ? () => Navigator.pushNamed(
                              context, letterLessonRoutes[index])
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
                                    isUnlocked ? letterLessonNames[index] : '',
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
            child: Container(
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
                itemCount: letterLessonRoutes.length,
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
            child: Container(
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
            child: Container(
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
