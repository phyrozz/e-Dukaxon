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

  @override
  void initState() {
    super.initState();
    checkNewAccountAndNavigate();
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
                children: const [
                  SizedBox(
                    width: 12,
                  ),
                  Text(
                    'Letters',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
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
                    padding: const EdgeInsets.all(12.0),
                    child: InkWell(
                      onTap: isUnlocked
                          ? () => Navigator.pushNamed(
                              context, letterLessonRoutes[index])
                          : null,
                      child: Opacity(
                        opacity: isUnlocked ? 1.0 : 0.5,
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).primaryColorDark,
                                blurRadius: isUnlocked ? 10.0 : 0,
                              ),
                            ],
                          ),
                          child: Card(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: Text(
                                    isUnlocked ? letterLessonNames[index] : '',
                                    style: const TextStyle(fontSize: 18.0),
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
                children: const [
                  SizedBox(
                    width: 12,
                  ),
                  Text(
                    'Words',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
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
                    padding: const EdgeInsets.all(12.0),
                    child: InkWell(
                      onTap: isUnlocked
                          ? () => Navigator.pushNamed(
                              context, wordLessonRoutes[index])
                          : null,
                      child: Opacity(
                        opacity: isUnlocked ? 1.0 : 0.5,
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).primaryColorDark,
                                blurRadius: isUnlocked ? 10.0 : 0,
                              ),
                            ],
                          ),
                          child: Card(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: Text(
                                    isUnlocked ? wordLessonNames[index] : '',
                                    style: const TextStyle(fontSize: 18.0),
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
                children: const [
                  SizedBox(
                    width: 12,
                  ),
                  Text(
                    'Sentences',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
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
                    padding: const EdgeInsets.all(12.0),
                    child: InkWell(
                      onTap: isUnlocked
                          ? () => Navigator.pushNamed(
                              context, sentenceLessonRoutes[index])
                          : null,
                      child: Opacity(
                        opacity: isUnlocked ? 1.0 : 0.5,
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).primaryColorDark,
                                blurRadius: isUnlocked ? 10.0 : 0,
                              ),
                            ],
                          ),
                          child: Card(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: Text(
                                    isUnlocked
                                        ? sentenceLessonNames[index]
                                        : '',
                                    style: const TextStyle(fontSize: 18.0),
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
