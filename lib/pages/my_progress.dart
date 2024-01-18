import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/pages/loading.dart';
import 'package:e_dukaxon/widgets/new_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProgressPage extends StatefulWidget {
  const MyProgressPage({super.key});

  @override
  State<MyProgressPage> createState() => _MyProgressPageState();
}

class _MyProgressPageState extends State<MyProgressPage> {
  bool isParentMode = false;
  bool isEnglish = true;
  bool isLoading = true;
  bool isTopLessonsListDescending = true;
  bool isTopPlayedLessonsListDescending = true;
  bool isLessonsProgressGridVisible = true;
  bool isTopLessonsListVisible = false;
  bool isTopPlayedLessonsListVisible = false;
  bool isParent = false;
  int dailyStreak = 0;

  // For the top lessons list
  List<String> topLessonNames = [];
  List<double> topLessonAccuracies = [];

  // For the most played lessons list
  List<String> mostPlayedLessonNames = [];
  List<int> mostPlayedLessonCounts = [];

  @override
  void initState() {
    getLanguage()
        .then((_) => getIsParentValue())
        .then((_) => getParentModeValue())
        .then((_) => getTopLessonsList())
        .then((_) => getTopPlayedLessons());
    super.initState();
  }

  Future<void> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnglish = prefs.getBool('isEnglish') ?? true;

    if (mounted) {
      setState(() {
        this.isEnglish = isEnglish;
      });
    }
  }

  Future<void> getParentModeValue() async {
    final prefs = await SharedPreferences.getInstance();
    final prefValue = prefs.getBool('isParentMode');

    if (mounted) {
      setState(() {
        isParentMode = prefValue!;
        isLoading = false;
      });
    }
  }

  Future<void> getIsParentValue() async {
    final userId = Auth().getCurrentUserId();
    DocumentReference documentRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    DocumentSnapshot snapshot = await documentRef.get();

    try {
      bool isParentValue = snapshot.get("isParent");

      setState(() {
        isParent = isParentValue;
      });
    } catch (e) {
      await documentRef.update({
        'isParent': false,
      });
    }
  }

  Future<int> getProgressValue(bool isEnglish, String lessonType) async {
    String userId = Auth().getCurrentUserId()!;
    String languageCode = isEnglish ? 'en' : 'ph';

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection(lessonType)
              .doc(languageCode)
              .collection('lessons')
              .get();

      int totalProgress = 0;

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc
          in querySnapshot.docs) {
        int progressValue = doc['progress'] ?? 0;
        totalProgress += progressValue;
      }

      return totalProgress;
    } catch (e) {
      print('Error getting progress value: $e');
      return 0; // Default value in case of an error
    }
  }

  Future<int> getTotalProgressValue(bool isEnglish, String lessonType) async {
    String userId = Auth().getCurrentUserId()!;
    String languageCode = isEnglish ? 'en' : 'ph';

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection(lessonType)
              .doc(languageCode)
              .collection('lessons')
              .get();

      int numberOfDocuments = querySnapshot.size;
      int totalProgressValue = numberOfDocuments * 100;

      return totalProgressValue;
    } catch (e) {
      print('Error getting total progress value: $e');
      return 0; // Default value in case of an error
    }
  }

  Future<void> getTopLessonsList() async {
    List<String> lessonNames = [];
    List<double> lessonAccuracies = [];

    try {
      CollectionReference letterLessonsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(Auth().getCurrentUserId())
          .collection("letters")
          .doc(isEnglish ? "en" : "ph")
          .collection("lessons");
      CollectionReference numberLessonsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(Auth().getCurrentUserId())
          .collection("numbers")
          .doc(isEnglish ? "en" : "ph")
          .collection("lessons");
      CollectionReference wordLessonsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(Auth().getCurrentUserId())
          .collection("words")
          .doc(isEnglish ? "en" : "ph")
          .collection("lessons");
      // Add more lessons

      QuerySnapshot letterQuerySnapshot = await letterLessonsCollection.get();
      QuerySnapshot numberQuerySnapshot = await numberLessonsCollection.get();
      QuerySnapshot wordQuerySnapshot = await wordLessonsCollection.get();
      // Add more lessons

      if (letterQuerySnapshot.docs.isNotEmpty &&
          numberQuerySnapshot.docs.isNotEmpty &&
          wordQuerySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot documentSnapshot
            in letterQuerySnapshot.docs) {
          int accumulatedScore = documentSnapshot['accumulatedScore'] ?? 0;
          int lessonTaken = documentSnapshot['lessonTaken'] ?? 0;
          int lessonTotalScore = documentSnapshot['total'] ?? 0;

          if (lessonTaken != 0) {
            double lessonPercentage =
                (accumulatedScore / (lessonTaken * lessonTotalScore)) * 100;

            lessonAccuracies.add(lessonPercentage);
          } else {
            lessonAccuracies.add(0);
          }
          lessonNames.add(documentSnapshot['name'] ?? '');
        }
        for (QueryDocumentSnapshot documentSnapshot
            in numberQuerySnapshot.docs) {
          int accumulatedScore = documentSnapshot['accumulatedScore'] ?? 0;
          int lessonTaken = documentSnapshot['lessonTaken'] ?? 0;
          int lessonTotalScore = documentSnapshot['total'] ?? 0;

          if (lessonTaken != 0) {
            double lessonPercentage =
                (accumulatedScore / (lessonTaken * lessonTotalScore)) * 100;

            lessonAccuracies.add(lessonPercentage);
          } else {
            lessonAccuracies.add(0);
          }
          lessonNames.add(documentSnapshot['name'] ?? '');
        }
        for (QueryDocumentSnapshot documentSnapshot in wordQuerySnapshot.docs) {
          int accumulatedScore = documentSnapshot['accumulatedScore'] ?? 0;
          int lessonTaken = documentSnapshot['lessonTaken'] ?? 0;
          int lessonTotalScore = documentSnapshot['total'] ?? 0;

          if (lessonTaken != 0) {
            double lessonPercentage =
                (accumulatedScore / (lessonTaken * lessonTotalScore)) * 100;

            lessonAccuracies.add(lessonPercentage);
          } else {
            lessonAccuracies.add(0);
          }
          lessonNames.add(documentSnapshot['name'] ?? '');
        }
        // Add more for loops on new lessons

        // Map the two lists
        List<MapEntry<String, double>> lessonPairs = List.generate(
          lessonNames.length,
          (index) => MapEntry(lessonNames[index], lessonAccuracies[index]),
        );

        // Sort the list of pairs by accuracy in descending order
        lessonPairs.sort((a, b) => b.value.compareTo(a.value));

        // Extract the sorted lesson names
        List<String> sortedLessonNames =
            lessonPairs.map((entry) => entry.key).toList();
        List<double> sortedAccuracies =
            lessonPairs.map((entry) => entry.value).toList();

        setState(() {
          topLessonNames = sortedLessonNames;
          topLessonAccuracies = sortedAccuracies;
        });
      } else {
        print('No documents found in the lessons collection');
      }
    } catch (e) {
      print("Error retrieving top lessons from Firestore: $e");
    }
  }

  Future<void> getTopPlayedLessons() async {
    List<String> lessonNames = [];
    List<int> lessonCounts = [];

    try {
      CollectionReference letterLessonsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(Auth().getCurrentUserId())
          .collection("letters")
          .doc(isEnglish ? "en" : "ph")
          .collection("lessons");
      CollectionReference numberLessonsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(Auth().getCurrentUserId())
          .collection("numbers")
          .doc(isEnglish ? "en" : "ph")
          .collection("lessons");
      CollectionReference wordLessonsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(Auth().getCurrentUserId())
          .collection("words")
          .doc(isEnglish ? "en" : "ph")
          .collection("lessons");
      // Add more lessons

      QuerySnapshot letterQuerySnapshot = await letterLessonsCollection.get();
      QuerySnapshot numberQuerySnapshot = await numberLessonsCollection.get();
      QuerySnapshot wordQuerySnapshot = await wordLessonsCollection.get();
      // Add more lessons

      if (letterQuerySnapshot.docs.isNotEmpty &&
          numberQuerySnapshot.docs.isNotEmpty &&
          wordQuerySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot documentSnapshot
            in letterQuerySnapshot.docs) {
          int lessonCount = documentSnapshot['lessonTaken'] ?? 0;

          lessonCounts.add(lessonCount);
          lessonNames.add(documentSnapshot['name'] ?? '');
        }
        for (QueryDocumentSnapshot documentSnapshot
            in numberQuerySnapshot.docs) {
          int lessonCount = documentSnapshot['lessonTaken'] ?? 0;

          lessonCounts.add(lessonCount);
          lessonNames.add(documentSnapshot['name'] ?? '');
        }
        for (QueryDocumentSnapshot documentSnapshot in wordQuerySnapshot.docs) {
          int lessonCount = documentSnapshot['lessonTaken'] ?? 0;

          lessonCounts.add(lessonCount);
          lessonNames.add(documentSnapshot['name'] ?? '');
        }
        // Add more lessons

        // Map the two lists
        List<MapEntry<String, int>> lessonPairs = List.generate(
          lessonNames.length,
          (index) => MapEntry(lessonNames[index], lessonCounts[index]),
        );

        // Sort the list of pairs by accuracy in descending order
        lessonPairs.sort((a, b) => b.value.compareTo(a.value));

        // Extract the sorted lesson names
        List<String> sortedLessonNames =
            lessonPairs.map((entry) => entry.key).toList();
        List<int> sortedCounts =
            lessonPairs.map((entry) => entry.value).toList();

        setState(() {
          mostPlayedLessonNames = sortedLessonNames;
          mostPlayedLessonCounts = sortedCounts;
        });
      } else {
        print('No documents found in the lessons collection');
      }
    } catch (e) {
      print("Error retrieving top lessons from Firestore: $e");
    }
  }

  // Due to the fact that the headers are clickable and has state management within the delegate class, a function from this class must be passed into it to retrieve the state to
  // toggle the cards' visibility.
  void toggleLessonProgressGridVisibility() {
    setState(() {
      if (!isLessonsProgressGridVisible) {
        isLessonsProgressGridVisible = true;
      } else {
        isLessonsProgressGridVisible = false;
      }
    });
  }

  void toggleTopLessonsListVisibility() {
    setState(() {
      if (!isTopLessonsListVisible) {
        isTopLessonsListVisible = true;
      } else {
        isTopLessonsListVisible = false;
      }
    });
  }

  void toggleTopPlayedLessonsListVisibility() {
    setState(() {
      if (!isTopPlayedLessonsListVisible) {
        isTopPlayedLessonsListVisible = true;
      } else {
        isTopPlayedLessonsListVisible = false;
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const LoadingPage()
          : Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image:
                          const AssetImage("assets/images/my_progress_bg.png"),
                      fit: BoxFit.contain,
                      alignment: Alignment.centerRight,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context)
                            .scaffoldBackgroundColor
                            .withOpacity(0.5),
                        BlendMode.srcOver,
                      ),
                    ),
                  ),
                ),
                GlowingOverscrollIndicator(
                  color: Theme.of(context).primaryColorDark,
                  axisDirection: AxisDirection.down,
                  child: CustomScrollView(
                    slivers: [
                      WelcomeCustomAppBar(
                        text: isEnglish ? "Progress" : "Aking Progress",
                        isParentMode: isParentMode,
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(8.0),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: ShapeDecoration(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12))),
                                  color: Theme.of(context).primaryColorLight,
                                  shadows: [
                                    BoxShadow(
                                      color: Theme.of(context).focusColor,
                                      offset: const Offset(6, 9),
                                      blurRadius: 28,
                                      spreadRadius: -10,
                                    ),
                                  ],
                                ),
                                height: 110,
                                width: 420,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            12, 8, 0, 8),
                                        child: Image.asset(dailyStreak == 0
                                            ? "assets/images/streak_inactive.png"
                                            : "assets/images/streak_active.png"),
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            isParent
                                                ? (isEnglish
                                                    ? "My Child's Daily Streak"
                                                    : "Daily Streak ng Aking Anak")
                                                : (isEnglish
                                                    ? "My Daily Streak"
                                                    : "Aking Daily Streak"),
                                            style:
                                                const TextStyle(fontSize: 18),
                                          ),
                                          Text(
                                            isEnglish
                                                ? "$dailyStreak days"
                                                : "$dailyStreak araw",
                                            style:
                                                const TextStyle(fontSize: 36),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(8.0),
                        sliver: SliverPersistentHeader(
                            pinned: false,
                            delegate: CustomHeaderDelegate(
                                state: toggleLessonProgressGridVisibility,
                                headerText:
                                    isEnglish ? "Lessons" : "Mga Lesson",
                                toggleState: isLessonsProgressGridVisible)),
                      ),
                      isLessonsProgressGridVisible
                          ? SliverPadding(
                              padding: const EdgeInsets.all(8),
                              sliver: SliverGrid.count(
                                crossAxisCount: 4,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                children: [
                                  progressCard(
                                      isEnglish ? "Letters" : "Mga Titik",
                                      "letters"),
                                  progressCard(
                                      isEnglish ? "Numbers" : "Mga Numero",
                                      "numbers"),
                                  // TODO: add these widgets if the lessons on these are done
                                  progressCard(
                                      isEnglish ? "Words" : "Mga Salita",
                                      "words"),
                                ],
                              ),
                            )
                          : const SliverToBoxAdapter(),
                      SliverPadding(
                        padding: const EdgeInsets.all(8.0),
                        sliver: SliverPersistentHeader(
                            pinned: false,
                            delegate: CustomHeaderDelegate(
                                state: toggleTopLessonsListVisibility,
                                headerText: isEnglish
                                    ? "Top Lessons"
                                    : "Mga Nangungunang Aralin",
                                toggleState: isTopLessonsListVisible)),
                      ),
                      isTopLessonsListVisible
                          ? SliverToBoxAdapter(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                      onPressed: () {
                                        if (isTopLessonsListDescending) {
                                          setState(() {
                                            isTopLessonsListDescending = false;
                                          });
                                        } else {
                                          setState(() {
                                            isTopLessonsListDescending = true;
                                          });
                                        }

                                        Iterable<String> sortTopLessonNames =
                                            topLessonNames.reversed;
                                        Iterable<double>
                                            sortTopLessonAccuracies =
                                            topLessonAccuracies.reversed;

                                        setState(() {
                                          topLessonNames =
                                              sortTopLessonNames.toList();
                                          topLessonAccuracies =
                                              sortTopLessonAccuracies.toList();
                                        });
                                      },
                                      icon: Icon(isTopLessonsListDescending
                                          ? Icons.arrow_downward_rounded
                                          : Icons.arrow_upward_rounded),
                                      label: Text(isTopLessonsListDescending
                                          ? "Descending"
                                          : "Ascending")),
                                ],
                              ),
                            )
                          : const SliverToBoxAdapter(),
                      topLessonNames.isEmpty
                          ? const SliverToBoxAdapter()
                          : isTopLessonsListVisible
                              ? SliverPadding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  sliver: SliverList.builder(
                                      itemCount: 10,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return topLessonsCard(
                                            topLessonNames[index],
                                            index + 1,
                                            topLessonAccuracies[index]);
                                      }),
                                )
                              : const SliverToBoxAdapter(),
                      SliverPadding(
                        padding: const EdgeInsets.all(8.0),
                        sliver: SliverPersistentHeader(
                            pinned: false,
                            delegate: CustomHeaderDelegate(
                                state: toggleTopPlayedLessonsListVisibility,
                                headerText: isEnglish
                                    ? "Most Played Lessons"
                                    : "Pinaka Nilalaro na mga Aralin",
                                toggleState: isTopPlayedLessonsListVisible)),
                      ),
                      isTopPlayedLessonsListVisible
                          ? SliverToBoxAdapter(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                      onPressed: () {
                                        if (isTopPlayedLessonsListDescending) {
                                          setState(() {
                                            isTopPlayedLessonsListDescending =
                                                false;
                                          });
                                        } else {
                                          setState(() {
                                            isTopPlayedLessonsListDescending =
                                                true;
                                          });
                                        }

                                        Iterable<String> sortTopLessonNames =
                                            mostPlayedLessonNames.reversed;
                                        Iterable<int> sortTopLessonCounts =
                                            mostPlayedLessonCounts.reversed;

                                        setState(() {
                                          mostPlayedLessonNames =
                                              sortTopLessonNames.toList();
                                          mostPlayedLessonCounts =
                                              sortTopLessonCounts.toList();
                                        });
                                      },
                                      icon: Icon(
                                          isTopPlayedLessonsListDescending
                                              ? Icons.arrow_downward_rounded
                                              : Icons.arrow_upward_rounded),
                                      label: Text(
                                          isTopPlayedLessonsListDescending
                                              ? "Descending"
                                              : "Ascending")),
                                ],
                              ),
                            )
                          : const SliverToBoxAdapter(),
                      mostPlayedLessonNames.isEmpty
                          ? const SliverToBoxAdapter()
                          : isTopPlayedLessonsListVisible
                              ? SliverPadding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  sliver: SliverList.builder(
                                      itemCount: 10,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return topPlayedLessonsCard(
                                            mostPlayedLessonNames[index],
                                            index + 1,
                                            mostPlayedLessonCounts[index]);
                                      }),
                                )
                              : const SliverToBoxAdapter(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget progressCard(String title, String type) {
    try {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              color: Theme.of(context).primaryColorLight,
              shadows: [
                BoxShadow(
                  color: Theme.of(context).focusColor,
                  offset: const Offset(6, 9),
                  blurRadius: 28,
                  spreadRadius: -10,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontSize: 18),
                    textAlign: TextAlign.left,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: FutureBuilder<double>(
                      future: () async {
                        var progressValue =
                            await getProgressValue(isEnglish, type);
                        var totalProgressValue =
                            await getTotalProgressValue(isEnglish, type);
                        return progressValue / totalProgressValue;
                      }(),
                      builder: (BuildContext context,
                          AsyncSnapshot<double> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: Container(
                              width: 25,
                              height: 25,
                              child: CircularProgressIndicator(
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                          ); // Show a loading spinner while waiting
                        } else {
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 12),
                                Container(
                                  width: 60,
                                  height: 60,
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context).primaryColorDark,
                                    backgroundColor: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    strokeWidth: 16,
                                    strokeCap: StrokeCap.round,
                                    value: snapshot.data,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '${(snapshot.data! * 100).toStringAsFixed(2)}% complete',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(fontSize: 16),
                                ),
                              ],
                            ); // Here, snapshot.data is a double
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } catch (e) {
      print("Error: $e");
      return Container();
    }
  }

  Widget topLessonsCard(String lessonName, int rank, double accuracy) {
    try {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              color: Theme.of(context).primaryColorLight,
              shadows: [
                BoxShadow(
                  color: Theme.of(context).focusColor,
                  offset: const Offset(6, 9),
                  blurRadius: 28,
                  spreadRadius: -10,
                )
              ]),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerLeft,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 8, 20),
                  child: Text(lessonName),
                ),
                Positioned(
                    right: 0,
                    bottom: 0,
                    child: Text(
                      "Accuracy: $accuracy%",
                      style: const TextStyle(fontSize: 16),
                    )),
                Positioned(
                  top: -20,
                  left: -15,
                  child: rank <= 3
                      ? Container(
                          decoration: ShapeDecoration(
                              shape: const CircleBorder(),
                              color: Theme.of(context).primaryColorDark),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              "$rank",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        )
                      : Container(),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      print("Error loading top lesson cards: $e");
      return Container();
    }
  }

  Widget topPlayedLessonsCard(String lessonName, int rank, int count) {
    try {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              color: Theme.of(context).primaryColorLight,
              shadows: [
                BoxShadow(
                  color: Theme.of(context).focusColor,
                  offset: const Offset(6, 9),
                  blurRadius: 28,
                  spreadRadius: -10,
                )
              ]),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerLeft,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 8, 20),
                  child: Text(lessonName),
                ),
                Positioned(
                    right: 0,
                    bottom: 0,
                    child: Text(
                      "Times played: $count",
                      style: const TextStyle(fontSize: 16),
                    )),
                Positioned(
                  top: -20,
                  left: -15,
                  child: rank <= 3
                      ? Container(
                          decoration: ShapeDecoration(
                              shape: const CircleBorder(),
                              color: Theme.of(context).primaryColorDark),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              "$rank",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        )
                      : Container(),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      print("Error loading most played lesson cards: $e");
      return Container();
    }
  }
}

class CustomHeaderDelegate extends SliverPersistentHeaderDelegate {
  CustomHeaderDelegate(
      {required this.headerText,
      required this.toggleState,
      required this.state});

  final Function state;
  final String headerText;
  bool toggleState;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Container(
        decoration: ShapeDecoration(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12))),
            color: Theme.of(context).primaryColorDark,
            shadows: [
              BoxShadow(
                color: Theme.of(context).focusColor,
                offset: const Offset(6, 9),
                blurRadius: 28,
                spreadRadius: -10,
              ),
            ]),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              state();
              setState(() {
                if (!toggleState) {
                  toggleState = true;
                } else {
                  toggleState = false;
                }
              });
            },
            child: Container(
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      headerText,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontSize: 20),
                    ),
                  ),
                  Positioned(
                      top: 10,
                      right: 10,
                      child: Icon(
                        toggleState
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        color: Theme.of(context).primaryColor,
                        size: 32,
                      )),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
