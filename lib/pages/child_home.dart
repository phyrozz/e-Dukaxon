import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/data/theme_data.dart';
import 'package:e_dukaxon/firestore_data/letter_lessons.dart';
import 'package:e_dukaxon/firestore_data/number_lessons.dart';
import 'package:e_dukaxon/pages/assessment_questions/locale_select.dart';
import 'package:e_dukaxon/pages/lessons/letters/level_one.dart';
import 'package:e_dukaxon/pages/lessons/numbers/level_one.dart';
import 'package:e_dukaxon/pages/loading.dart';
import 'package:e_dukaxon/user_firestore.dart';
import 'package:e_dukaxon/widgets/new_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool isEnglish = true;
  bool isLoading = true;
  String currentColorScheme = "Default";

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
      print('Error updating local letter lessons: $e');
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
      print('Error updating local number lessons: $e');
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
    getLanguage().then((_) {
      letterLessons();
      numberLessons();
      setState(() {
        isLoading = false;
      });
    }).then((_) => getColorScheme());
    super.initState();
    // initializeGameDataOnFirestore();
    // initLetterLessonData();
    // addNewLetterLesson();
    checkNewAccountAndNavigate();
    // Rebuild the screen after 3s which will process the animation
    Future.delayed(const Duration(milliseconds: 300))
        .then((value) => setState(() {
              headerPosition = Alignment.bottomCenter;
              containerPosition = Alignment.bottomCenter;
              containerOpacity = 1.0;
            }));
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
        : Scaffold(
            body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                        setBackgroundByColorScheme(currentColorScheme)),
                    fit: BoxFit.contain,
                    alignment: Alignment.centerRight),
              ),
              child: CustomScrollView(
                slivers: [
                  WelcomeCustomAppBar(
                      text: isEnglish ? "Let's learn!" : "Tayo'y mag-aral!",
                      isParentMode: widget.isParentMode),
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
                              child: Text(
                                isEnglish ? 'Letters' : 'Mga Titik',
                                style: const TextStyle(
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: letterLessonNames.length,
                        itemBuilder: (context, index) {
                          bool isUnlocked = unlockedLetterLessons[index];
                          return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: InkWell(
                              onTap: () async {
                                if (isUnlocked) {
                                  if (letterLessonProgress[index] >= 0) {
                                    await LetterLessonFirestore(
                                            userId: Auth().getCurrentUserId()!)
                                        .resetScore(letterLessonNames[index],
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
                                                ? letterLessonNames[index]
                                                : '',
                                            style: const TextStyle(
                                                fontSize: 32.0,
                                                color: Colors.white),
                                          ),
                                        ),
                                        AnimatedAlign(
                                          alignment: containerPosition,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          curve: Curves.easeInOutCubic,
                                          child: AnimatedOpacity(
                                            opacity: isUnlocked
                                                ? containerOpacity
                                                : 0,
                                            duration: const Duration(
                                                milliseconds: 500),
                                            curve: Curves.easeInOutCubic,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: Container(
                                                  width: 100.0,
                                                  height: 100.0,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        blurRadius: 20,
                                                        color: Theme.of(context)
                                                            .primaryColorLight,
                                                      ),
                                                    ],
                                                    color: Theme.of(context)
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
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOutCubic,
                            child: AnimatedOpacity(
                              opacity: containerOpacity,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              child: Text(
                                isEnglish ? 'Numbers' : 'Mga Numero',
                                style: const TextStyle(
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: numberLessonNames.length,
                        itemBuilder: (context, index) {
                          bool isUnlocked = unlockedNumberLessons[index];
                          return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: InkWell(
                              onTap: () async {
                                if (isUnlocked) {
                                  if (numberLessonProgress[index] >= 0) {
                                    await NumberLessonFirestore(
                                            userId: Auth().getCurrentUserId()!)
                                        .resetScore(numberLessonNames[index],
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
                                                ? numberLessonNames[index]
                                                : '',
                                            style: const TextStyle(
                                                fontSize: 32.0,
                                                color: Colors.white),
                                          ),
                                        ),
                                        AnimatedAlign(
                                          alignment: containerPosition,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          curve: Curves.easeInOutCubic,
                                          child: AnimatedOpacity(
                                            opacity: isUnlocked
                                                ? containerOpacity
                                                : 0,
                                            duration: const Duration(
                                                milliseconds: 500),
                                            curve: Curves.easeInOutCubic,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: Container(
                                                  width: 100.0,
                                                  height: 100.0,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        blurRadius: 20,
                                                        color: Theme.of(context)
                                                            .primaryColorLight,
                                                      ),
                                                    ],
                                                    color: Theme.of(context)
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
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOutCubic,
                            child: AnimatedOpacity(
                              opacity: containerOpacity,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              child: Text(
                                isEnglish ? 'Words' : 'Mga Salita',
                                style: const TextStyle(
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
                                            isUnlocked
                                                ? wordLessonNames[index]
                                                : '',
                                            style: const TextStyle(
                                                fontSize: 18.0,
                                                color: Colors.white),
                                          ),
                                        ),
                                        AnimatedAlign(
                                          alignment: containerPosition,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          curve: Curves.easeInOutCubic,
                                          child: AnimatedOpacity(
                                            opacity: isUnlocked
                                                ? containerOpacity
                                                : 0,
                                            duration: const Duration(
                                                milliseconds: 500),
                                            curve: Curves.easeInOutCubic,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(15.0),
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
                                                  boxShadow: [
                                                    BoxShadow(
                                                      blurRadius: 20,
                                                      color: Theme.of(context)
                                                          .primaryColorLight,
                                                    ),
                                                  ],
                                                  color: Theme.of(context)
                                                      .primaryColorLight,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${75}%',
                                                    // '${progressPercentage.toStringAsFixed(0)}%',
                                                    style: TextStyle(
                                                      fontSize: 22.0,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .labelMedium!
                                                          .color,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                              child: Text(
                                isEnglish ? 'Sentences' : 'Mga Pangungusap',
                                style: const TextStyle(
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
                                                fontSize: 18.0,
                                                color: Colors.white),
                                          ),
                                        ),
                                        AnimatedAlign(
                                          alignment: containerPosition,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          curve: Curves.easeInOutCubic,
                                          child: AnimatedOpacity(
                                            opacity: isUnlocked
                                                ? containerOpacity
                                                : 0,
                                            duration: const Duration(
                                                milliseconds: 500),
                                            curve: Curves.easeInOutCubic,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(15.0),
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
                                                  boxShadow: [
                                                    BoxShadow(
                                                      blurRadius: 20,
                                                      color: Theme.of(context)
                                                          .primaryColorLight,
                                                    ),
                                                  ],
                                                  color: Theme.of(context)
                                                      .primaryColorLight,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${75}%',
                                                    // '${progressPercentage.toStringAsFixed(0)}%',
                                                    style: TextStyle(
                                                      fontSize: 22.0,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .labelMedium!
                                                          .color,
                                                      fontWeight:
                                                          FontWeight.bold,
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
