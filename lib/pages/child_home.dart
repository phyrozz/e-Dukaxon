import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/data/theme_data.dart';
import 'package:e_dukaxon/firestore_data/letter_lessons.dart';
import 'package:e_dukaxon/firestore_data/number_lessons.dart';
import 'package:e_dukaxon/firestore_data/word_lessons.dart';
import 'package:e_dukaxon/pages/assessment_questions/locale_select.dart';
import 'package:e_dukaxon/pages/games.dart';
import 'package:e_dukaxon/pages/lessons/letters/level_one.dart';
import 'package:e_dukaxon/pages/lessons/numbers/level_one.dart';
import 'package:e_dukaxon/pages/lessons/words/level_one.dart';
import 'package:e_dukaxon/pages/loading.dart';
import 'package:e_dukaxon/user_firestore.dart';
import 'package:e_dukaxon/widgets/new_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:popover/popover.dart';

class ChildHomePage extends StatefulWidget {
  final bool isParentMode;

  const ChildHomePage({super.key, required this.isParentMode});

  @override
  State<ChildHomePage> createState() => _ChildHomePageState();
}

class _ChildHomePageState extends State<ChildHomePage> {
  List letterLessonNames = [];
  List letterLessonProgress = [];
  List unlockedLetterLessons = [];
  List numberLessonNames = [];
  List numberLessonProgress = [];
  List unlockedNumberLessons = [];
  List wordLessonNames = [];
  List wordLessonProgress = [];
  List unlockedWordLessons = [];
  bool isEnglish = true;
  bool isLoading = true;
  String currentColorScheme = "Default";
  int dailyStreak = 0;

  Future<void> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final locale = prefs.getBool('isEnglish') ?? true;

    if (mounted) {
      setState(() {
        isEnglish = locale;
      });
    }
  }

  Future<void> getColorScheme() async {
    final prefs = await SharedPreferences.getInstance();
    final colorScheme = prefs.getString('colorScheme') ?? "Default";

    onColorSchemeSelected(colorScheme);

    if (mounted) {
      setState(() {
        currentColorScheme = colorScheme;
      });
    }
  }

  String setBackgroundByColorScheme(String currentColorScheme) {
    final colorSchemeProvider = Provider.of<ColorSchemeProvider>(context);
    currentColorScheme = colorSchemeProvider.selectedColor;

    switch (currentColorScheme) {
      case "Blue":
        return "assets/images/bg_blue.png";
      case "Purple":
        return "assets/images/bg_purple.png";
      case "Cyan":
        return "assets/images/bg_cyan.png";
      case "Black":
        return "assets/images/bg_dark.png";
      case "White":
        return "assets/images/bg_light.png";
      default:
        return "assets/images/bg_brown.png";
    }
  }

  // Always check the lastUpdatedStreak value on Firestore every time this page is loaded to determine if the user's daily streak is still active or not
  Future<void> checkDailyStreak() async {
    final userId = Auth().getCurrentUserId();
    DocumentReference documentRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    DocumentSnapshot snapshot = await documentRef.get();

    try {
      int dailyStreak = snapshot.get("dailyStreak");
      Timestamp lastUpdate = snapshot.get("lastUpdatedStreak");
      Timestamp currentStreakStartedAt = snapshot.get("currentStreakStartedAt");

      // Check if the current daily streak has reached a full day so it can be incremented by 1
      if (isPast24Hours(currentStreakStartedAt.millisecondsSinceEpoch)) {
        await documentRef.update({
          'dailyStreak': dailyStreak++,
        });
      }

      // Check if it's been more than 24 hours
      if (isPast24Hours(lastUpdate.millisecondsSinceEpoch)) {
        // Reset the dailyStreak to 0
        await documentRef.update({
          'dailyStreak': 0,
          'lastUpdatedStreak': FieldValue.serverTimestamp(),
          'currentStreakStartedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      await documentRef.update({
        'dailyStreak': 0,
        'lastUpdatedStreak': FieldValue.serverTimestamp(),
        'currentStreakStartedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Exclusively for the checkDailyStreak function
  bool isPast24Hours(int timestamp) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final last24Hours = now - 24 * 60 * 60 * 1000;
    return timestamp < last24Hours;
  }

  Future<void> getDailyStreak() async {
    final userId = Auth().getCurrentUserId();
    DocumentReference documentRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    DocumentSnapshot snapshot = await documentRef.get();

    try {
      setState(() {
        dailyStreak = snapshot.get("dailyStreak");
      });
    } catch (e) {
      await documentRef.update({
        'dailyStreak': 0,
      });
    }
  }

  // Handle color scheme selection
  void onColorSchemeSelected(String colorScheme) {
    final colorSchemeProvider =
        Provider.of<ColorSchemeProvider>(context, listen: false);
    colorSchemeProvider.selectedColor = colorScheme;

    setState(() {
      currentColorScheme = colorScheme;
    });
  }

  Future<void> letterLessons() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final String? userId = Auth().getCurrentUserId();

      List<String> letterNames = [];
      List<bool> unlockedLessons = [];
      List<int> letterProgress = [];

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('letters')
          .doc(isEnglish ? 'en' : 'ph')
          .collection('lessons')
          .get();

      List<Map<String, dynamic>> lessonDataList = [];

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc
          in querySnapshot.docs) {
        lessonDataList.add(doc.data());
      }

      // Sort the lesson data list based on the "id" field
      lessonDataList.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));

      // Extract the sorted data into your lists
      for (Map<String, dynamic> lessonData in lessonDataList) {
        letterNames.add(lessonData['name'] as String);
        unlockedLessons.add(lessonData['isUnlocked'] as bool);
        letterProgress.add(lessonData['progress'] as int);
      }

      setState(() {
        letterLessonNames = letterNames;
        unlockedLetterLessons = unlockedLessons;
        letterLessonProgress = letterProgress;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> numberLessons() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final String? userId = Auth().getCurrentUserId();

      List<String> numberNames = [];
      List<bool> unlockedLessons = [];
      List<int> numberProgress = [];

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('numbers')
          .doc(isEnglish ? 'en' : 'ph')
          .collection('lessons')
          .get();

      List<Map<String, dynamic>> lessonDataList = [];

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc
          in querySnapshot.docs) {
        lessonDataList.add(doc.data());
      }

      lessonDataList.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));

      for (Map<String, dynamic> lessonData in lessonDataList) {
        numberNames.add(lessonData['name'] as String);
        unlockedLessons.add(lessonData['isUnlocked'] as bool);
        numberProgress.add(lessonData['progress'] as int);
      }

      setState(() {
        numberLessonNames = numberNames;
        unlockedNumberLessons = unlockedLessons;
        numberLessonProgress = numberProgress;
      });
    } catch (e) {
      print('Error: $e');
    }
  }
  // try {
  //   final directory = await getApplicationDocumentsDirectory();
  //   final file = File('${directory.path}/letter_lessons.json');
  //   final jsonString = await file.readAsString();
  //   final List<dynamic> jsonData = json.decode(jsonString);

  //   List<String> letterNames = [];
  //   List<bool> unlockedLessons = [];
  //   List<int> letterProgress = [];

  //   List<LetterLesson> letterLessons = jsonData.map((lesson) {
  //     return LetterLesson.fromJson(lesson);
  //   }).toList();

  //   for (var lesson in letterLessons) {
  //     letterNames.add(lesson.name);
  //     unlockedLessons.add(lesson.isUnlocked);
  //     letterProgress.add(lesson.progress);
  //   }

  //   setState(() {
  //     letterLessonNames = letterNames;
  //     unlockedLetterLessons = unlockedLessons;
  //     letterLessonProgress = letterProgress;
  //   });
  // } catch (e) {
  //   print('Error reading JSON file: $e');
  // }
  // }

  Future<void> wordLessons() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final String? userId = Auth().getCurrentUserId();

      List<String> wordNames = [];
      List<bool> unlockedLessons = [];
      List<int> wordProgress = [];

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('words')
          .doc(isEnglish ? 'en' : 'ph')
          .collection('lessons')
          .get();

      List<Map<String, dynamic>> lessonDataList = [];

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc
          in querySnapshot.docs) {
        lessonDataList.add(doc.data());
      }

      // Sort the lesson data list based on the "id" field
      lessonDataList.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));

      // Extract the sorted data into your lists
      for (Map<String, dynamic> lessonData in lessonDataList) {
        wordNames.add(lessonData['name'] as String);
        unlockedLessons.add(lessonData['isUnlocked'] as bool);
        wordProgress.add(lessonData['progress'] as int);
      }

      setState(() {
        wordLessonNames = wordNames;
        unlockedWordLessons = unlockedLessons;
        wordLessonProgress = wordProgress;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

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

  List<bool> unlockedSentenceLessons = [false, false, false, false];

  Alignment headerPosition = Alignment.topLeft;
  Alignment containerPosition = Alignment.bottomLeft;
  double containerOpacity = 0.0;

  late Future<void> letterLessonsFuture;
  late Future<void> numberLessonsFuture;
  late Future<void> wordLessonsFuture;

  @override
  void initState() {
    getLanguage()
        .then((_) {
          letterLessonsFuture = letterLessons();
          numberLessonsFuture = numberLessons();
          wordLessonsFuture = wordLessons();
          setState(() {
            isLoading = false;
          });
        })
        .then((_) => getColorScheme())
        .then((_) => checkDailyStreak());
    super.initState();
    // initializeGameDataOnFirestore();
    // initLetterLessonData();
    // addNewLetterLesson();
    checkNewAccountAndNavigate();
    // Rebuild the screen after 3s which will process the animation
    Future.delayed(const Duration(milliseconds: 300)).then((value) {
      if (mounted) {
        setState(() {
          headerPosition = Alignment.bottomCenter;
          containerPosition = Alignment.bottomCenter;
          containerOpacity = 1.0;
        });
      }
    });
  }

  Future<void> checkNewAccountAndNavigate() async {
    String? userId = Auth().getCurrentUserId();

    // Retrieve the user document from Firestore
    // final userDoc =
    // await FirebaseFirestore.instance.collection('users').doc(userId).get();

    // Check if it's a new account
    if (userId != null) {
      if (await UserFirestore(userId: userId).getIsNewAccount()) {
        // Show the assessment page
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const LocaleSelectPage()));
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const LoadingPage()
        : FutureBuilder(
            future: Future.wait([letterLessonsFuture, numberLessonsFuture]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingPage();
              } else {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Scaffold(
                    body: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              setBackgroundByColorScheme(currentColorScheme)),
                          fit: BoxFit.contain,
                          alignment: Alignment.centerRight,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context)
                                .scaffoldBackgroundColor
                                .withOpacity(
                                    0.5), // Adjust the opacity value as needed
                            BlendMode.srcOver,
                          ),
                        ),
                      ),
                      child: GlowingOverscrollIndicator(
                        color: Theme.of(context).primaryColorDark,
                        axisDirection: AxisDirection.down,
                        child: CustomScrollView(
                          slivers: [
                            WelcomeCustomAppBar(
                                text: isEnglish
                                    ? "Let's learn!"
                                    : "Tayo'y mag-aral!",
                                isParentMode: widget.isParentMode),
                            SliverPadding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              sliver: SliverToBoxAdapter(
                                child: SizedBox(
                                  height: 50.0,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      AnimatedAlign(
                                        alignment: headerPosition,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeInOutCubic,
                                        child: AnimatedOpacity(
                                          opacity: containerOpacity,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          curve: Curves.easeInOut,
                                          child: Text(
                                            isEnglish ? 'Letters' : 'Mga Titik',
                                            style: const TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      StreakIndicator(dailyStreak: dailyStreak),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: 200.0,
                                child: GridView.builder(
                                  clipBehavior: Clip.none,
                                  scrollDirection: Axis.horizontal,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                    childAspectRatio: 1.0,
                                  ),
                                  itemCount: letterLessonNames.length,
                                  itemBuilder: (context, index) {
                                    bool isUnlocked =
                                        unlockedLetterLessons[index];
                                    return Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: InkWell(
                                        onTap: () async {
                                          if (isUnlocked) {
                                            if (letterLessonProgress[index] >=
                                                0) {
                                              await LetterLessonFirestore(
                                                      userId: Auth()
                                                          .getCurrentUserId()!)
                                                  .resetScore(
                                                      letterLessonNames[index],
                                                      isEnglish ? "en" : "ph");
                                              // resetScore(letterLessonNames[index]);
                                              if (!context.mounted) return;
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          LettersLevelOne(
                                                              lessonName:
                                                                  letterLessonNames[
                                                                      index])));
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
                                              : containerOpacity / 1.5,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          curve: Curves.easeInOutCubic,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Theme.of(context)
                                                      .focusColor,
                                                  offset: const Offset(6, 9),
                                                  blurRadius: 28,
                                                  spreadRadius: -10,
                                                ),
                                              ],
                                            ),
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                              child: Stack(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Text(
                                                      isUnlocked
                                                          ? letterLessonNames[
                                                              index]
                                                          : '',
                                                      style: const TextStyle(
                                                          fontSize: 32.0,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                  AnimatedAlign(
                                                    alignment:
                                                        containerPosition,
                                                    duration: const Duration(
                                                        milliseconds: 500),
                                                    curve:
                                                        Curves.easeInOutCubic,
                                                    child: AnimatedOpacity(
                                                      opacity: isUnlocked
                                                          ? containerOpacity
                                                          : 0,
                                                      duration: const Duration(
                                                          milliseconds: 500),
                                                      curve:
                                                          Curves.easeInOutCubic,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(15.0),
                                                        child: Container(
                                                            width: 100.0,
                                                            height: 100.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  blurRadius:
                                                                      20,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColorLight,
                                                                ),
                                                              ],
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorLight,
                                                            ),
                                                            child: CircularProgressBar(
                                                                progress:
                                                                    letterLessonProgress[
                                                                        index])),
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
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeInOutCubic,
                                      child: AnimatedOpacity(
                                        opacity: containerOpacity,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                        child: Text(
                                          isEnglish ? 'Numbers' : 'Mga Numero',
                                          style: const TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold),
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
                                  clipBehavior: Clip.none,
                                  scrollDirection: Axis.horizontal,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                    childAspectRatio: 1.0,
                                  ),
                                  itemCount: numberLessonNames.length,
                                  itemBuilder: (context, index) {
                                    bool isUnlocked =
                                        unlockedNumberLessons[index];
                                    return Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: InkWell(
                                        onTap: () async {
                                          if (isUnlocked) {
                                            if (numberLessonProgress[index] >=
                                                0) {
                                              await NumberLessonFirestore(
                                                      userId: Auth()
                                                          .getCurrentUserId()!)
                                                  .resetScore(
                                                      numberLessonNames[index],
                                                      isEnglish ? "en" : "ph");
                                              // resetScore(letterLessonNames[index]);
                                              if (!context.mounted) return;
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          NumbersLevelOne(
                                                              lessonName:
                                                                  numberLessonNames[
                                                                      index])));
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
                                              : containerOpacity / 1.5,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          curve: Curves.easeInOutCubic,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Theme.of(context)
                                                      .focusColor,
                                                  offset: const Offset(6, 9),
                                                  blurRadius: 28,
                                                  spreadRadius: -10,
                                                ),
                                              ],
                                            ),
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                              child: Stack(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Text(
                                                      isUnlocked
                                                          ? numberLessonNames[
                                                              index]
                                                          : '',
                                                      style: const TextStyle(
                                                          fontSize: 32.0,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                  AnimatedAlign(
                                                    alignment:
                                                        containerPosition,
                                                    duration: const Duration(
                                                        milliseconds: 500),
                                                    curve:
                                                        Curves.easeInOutCubic,
                                                    child: AnimatedOpacity(
                                                      opacity: isUnlocked
                                                          ? containerOpacity
                                                          : 0,
                                                      duration: const Duration(
                                                          milliseconds: 500),
                                                      curve:
                                                          Curves.easeInOutCubic,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(15.0),
                                                        child: Container(
                                                            width: 100.0,
                                                            height: 100.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  blurRadius:
                                                                      20,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColorLight,
                                                                ),
                                                              ],
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorLight,
                                                            ),
                                                            child: CircularProgressBar(
                                                                progress:
                                                                    numberLessonProgress[
                                                                        index])),
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
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeInOutCubic,
                                      child: AnimatedOpacity(
                                        opacity: containerOpacity,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                        child: Text(
                                          isEnglish ? 'Words' : 'Mga Salita',
                                          style: const TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold),
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
                                  clipBehavior: Clip.none,
                                  scrollDirection: Axis.horizontal,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                    childAspectRatio: 1.0,
                                  ),
                                  itemCount: wordLessonNames.length,
                                  itemBuilder: (context, index) {
                                    bool isUnlocked =
                                        unlockedWordLessons[index];
                                    return Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: InkWell(
                                        onTap: () async {
                                          if (isUnlocked) {
                                            if (wordLessonProgress[index] >=
                                                0) {
                                              await WordLessonFirestore(
                                                      userId: Auth()
                                                          .getCurrentUserId()!)
                                                  .resetScore(
                                                      wordLessonNames[index],
                                                      isEnglish ? "en" : "ph");
                                              // resetScore(letterLessonNames[index]);
                                              if (!context.mounted) return;
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          WordsLevelOne(
                                                              lessonName:
                                                                  wordLessonNames[
                                                                      index])));
                                            }
                                          }
                                        },
                                        child: AnimatedOpacity(
                                          opacity: isUnlocked
                                              ? containerOpacity
                                              : containerOpacity / 1.5,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          curve: Curves.easeInOutCubic,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Theme.of(context)
                                                      .focusColor,
                                                  offset: const Offset(6, 9),
                                                  blurRadius: 28,
                                                  spreadRadius: -10,
                                                ),
                                              ],
                                            ),
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                              child: Stack(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Text(
                                                      isUnlocked
                                                          ? wordLessonNames[
                                                              index]
                                                          : '',
                                                      style: const TextStyle(
                                                          fontSize: 20.0,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                  AnimatedAlign(
                                                    alignment:
                                                        containerPosition,
                                                    duration: const Duration(
                                                        milliseconds: 500),
                                                    curve:
                                                        Curves.easeInOutCubic,
                                                    child: AnimatedOpacity(
                                                      opacity: isUnlocked
                                                          ? containerOpacity
                                                          : 0,
                                                      duration: const Duration(
                                                          milliseconds: 500),
                                                      curve:
                                                          Curves.easeInOutCubic,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(15.0),
                                                        child: Container(
                                                            width: 100.0,
                                                            height: 100.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  blurRadius:
                                                                      20,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColorLight,
                                                                ),
                                                              ],
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorLight,
                                                            ),
                                                            child: CircularProgressBar(
                                                                progress:
                                                                    wordLessonProgress[
                                                                        index])),
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
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeInOutCubic,
                                      child: AnimatedOpacity(
                                        opacity: containerOpacity,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                        child: Text(
                                          isEnglish
                                              ? 'Sentences'
                                              : 'Mga Pangungusap',
                                          style: const TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold),
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
                                  clipBehavior: Clip.none,
                                  scrollDirection: Axis.horizontal,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                    childAspectRatio: 1.0,
                                  ),
                                  itemCount: sentenceLessonRoutes.length,
                                  itemBuilder: (context, index) {
                                    bool isUnlocked =
                                        unlockedSentenceLessons[index];
                                    return Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: InkWell(
                                        onTap: isUnlocked
                                            ? () => Navigator.pushNamed(context,
                                                sentenceLessonRoutes[index])
                                            : null,
                                        child: AnimatedOpacity(
                                          opacity: isUnlocked
                                              ? containerOpacity
                                              : containerOpacity / 1.5,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          curve: Curves.easeInOutCubic,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Theme.of(context)
                                                      .focusColor,
                                                  offset: const Offset(6, 9),
                                                  blurRadius: 28,
                                                  spreadRadius: -10,
                                                ),
                                              ],
                                            ),
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                              child: Stack(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Text(
                                                      isUnlocked
                                                          ? sentenceLessonNames[
                                                              index]
                                                          : '',
                                                      style: const TextStyle(
                                                          fontSize: 18.0,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                  AnimatedAlign(
                                                    alignment:
                                                        containerPosition,
                                                    duration: const Duration(
                                                        milliseconds: 500),
                                                    curve:
                                                        Curves.easeInOutCubic,
                                                    child: AnimatedOpacity(
                                                      opacity: isUnlocked
                                                          ? containerOpacity
                                                          : 0,
                                                      duration: const Duration(
                                                          milliseconds: 500),
                                                      curve:
                                                          Curves.easeInOutCubic,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(15.0),
                                                        child: Container(
                                                          width: 100.0,
                                                          height: 100.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                              color: const Color
                                                                  .fromARGB(255,
                                                                  121, 74, 25),
                                                              width: 10.0,
                                                            ),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                blurRadius: 20,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColorLight,
                                                              ),
                                                            ],
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColorLight,
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              '${75}%',
                                                              // '${progressPercentage.toStringAsFixed(0)}%',
                                                              style: TextStyle(
                                                                fontSize: 22.0,
                                                                color: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .labelMedium!
                                                                    .color,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
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
                      ),
                    ),
                    floatingActionButton: widget.isParentMode
                        ? null
                        : FloatingActionButton.extended(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    const GamesPage(),
                              ),
                            ),
                            label: const Text("Games"),
                            icon: const Icon(Icons.play_arrow_rounded),
                            elevation: 20,
                          ),
                  );
                }
              }
            },
          );
  }
}

class StreakIndicator extends StatelessWidget {
  const StreakIndicator({
    super.key,
    required this.dailyStreak,
  });

  final int dailyStreak;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showPopover(
        context: context,
        barrierColor: Colors.transparent,
        bodyBuilder: (context) => Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            dailyStreak == 0
                ? "Start playing lessons to get your streaks going!"
                : "Don't lose your streak! Keep playing!",
            style: const TextStyle(fontSize: 16),
          ),
        ),
        direction: PopoverDirection.left,
        backgroundColor: Theme.of(context).primaryColorLight,
        transition: PopoverTransition.other,
        transitionDuration: const Duration(milliseconds: 100),
      ),
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Image.asset(
                dailyStreak == 0
                    ? "assets/images/streak_inactive.png"
                    : "assets/images/streak_active.png",
              ),
            ),
            Text("$dailyStreak"),
          ],
        ),
      ),
    );
  }
}

class CircularProgressBar extends StatelessWidget {
  final int progress;

  const CircularProgressBar({Key? key, required this.progress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CircularProgressBarPainter(progress, context),
      child: Center(
        child: Text(
          '$progress%',
          style: TextStyle(
            fontSize: 22.0,
            color: Theme.of(context).textTheme.labelMedium!.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class CircularProgressBarPainter extends CustomPainter {
  final int progress;
  final BuildContext context;

  CircularProgressBarPainter(this.progress, this.context);

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 10.0;
    final Paint borderPaint = Paint()
      ..color = Theme.of(context).focusColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final Paint progressPaint = Paint()
      ..color = Theme.of(context).primaryColorLight
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
