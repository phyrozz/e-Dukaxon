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

  @override
  void initState() {
    getLanguage().then((_) => getParentModeValue());
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
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEnglish ? 'Lessons' : 'Mga Lesson',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                        fontSize: 24,
                                        fontWeight: FontWeight.normal),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              progressCard(isEnglish ? "Letters" : "Mga Titik",
                                  "letters"),
                              const SizedBox(
                                height: 8,
                              ),
                              progressCard(isEnglish ? "Numbers" : "Mga Numero",
                                  "numbers"),
                              const SizedBox(
                                height: 8,
                              ),
                              // TODO: add these widgets if the lessons on these are done
                              progressCard(
                                  isEnglish ? "Words" : "Mga Salita", "words"),
                              const SizedBox(
                                height: 8,
                              ),
                              // progressCard(
                              //     isEnglish ? "Sentences" : "Mga Pangungusap",
                              //     "sentences"),
                            ],
                          ),
                        ),
                      ),
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
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontSize: 18),
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
                          return CircularProgressIndicator(
                            color: Theme.of(context).primaryColorDark,
                          ); // Show a loading spinner while waiting
                        } else {
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                LinearProgressIndicator(
                                    color: Theme.of(context).primaryColorDark,
                                    backgroundColor: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15)),
                                    minHeight: 15,
                                    value: snapshot.data),
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
}
