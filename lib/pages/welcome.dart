// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:e_dukaxon/data/letter_lessons.dart';
import 'package:e_dukaxon/pages/loading.dart';
import 'package:e_dukaxon/pages/login.dart';
import 'package:e_dukaxon/route_anims/vertical_slide.dart';
import 'package:e_dukaxon/user_firestore.dart';
import 'package:flutter/material.dart';
import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/speak_text.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/services.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late int selectedPage;
  late PageController welcomePages;
  String? errorMessage = '';

  @override
  void initState() {
    selectedPage = 0;
    welcomePages = PageController(initialPage: selectedPage);
    super.initState();
  }

  // void addLesson(String lesson, Map<String, dynamic> data) {
  //   FirebaseFirestore.instance
  //       .collection('letters')
  //       .doc('en')
  //       .collection('lessons')
  //       .doc(lesson)
  //       .set(data)
  //       .then((value) {
  //     print('Lesson added to Firestore');
  //   }).catchError((error) {
  //     print('Error adding lesson to Firestore: $error');
  //   });
  // }

  Future<void> signInAnonymously() async {
    try {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          opaque: false, // Make the loading page non-opaque
          pageBuilder: (context, _, __) {
            return const LoadingPage(); // Replace with your loading page widget
          },
        ),
      );

      await Auth().signInAnonymously();
      String? userId = Auth().getCurrentUserId();

      UserFirestore(userId: userId!).createNewAnonymousAccount();
      UserFirestore(userId: userId).initializeLessons("letters", "en");
      UserFirestore(userId: userId).initializeLessons("letters", "ph");
      UserFirestore(userId: userId).initializeLessons("numbers", "en");
      UserFirestore(userId: userId).initializeLessons("numbers", "ph");

      // Initialize preference values
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isParentMode', false);

      // initLetterLessonData();
    } on Exception catch (e) {
      // Remove the loading widget
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const WelcomePage(),
        ),
      );

      setState(() {
        errorMessage = e.toString();
      });
      SpeakText().speak("Failed to load the app. Please try again.");
      _showErrorDialog(
        context,
        "Failed to load the app. Please try again.",
      );
    }
  }

  @override
  void dispose() {
    welcomePages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: welcomePages,
                    onPageChanged: (page) {
                      setState(() {
                        selectedPage = page;
                      });
                    },
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 12, 30, 12),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/app-logo.png',
                                      width: 150,
                                    ),
                                  ),
                                ),
                                const Text(
                                  "Let's start learning!",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 28.0,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                const Text(
                                  "eDukaxon provides an amazing learning platform for dyslexics of all ages. Get started by tapping the button on the right!",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 12.0,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 12, 30, 12),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/welcome2.png',
                                      width: 150,
                                    ),
                                  ),
                                ),
                                const Text(
                                  "Learn everywhere you go.",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 24.0,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                const Text(
                                  "It's already an app that's right on your phone, so you can learn and play wherever you are!",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 12.0,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 12, 30, 12),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/welcome3.png',
                                      width: 150,
                                    ),
                                  ),
                                ),
                                const Text(
                                  "For dyslexics and for everyone.",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 24.0,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                const Text(
                                  "eDukaxon isn't just made for those who need to improve their reading skills, it's also for everyone who loves to learn.",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 12.0,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: PageViewDotIndicator(
                    currentItem: selectedPage,
                    count: 3,
                    unselectedColor: Theme.of(context).primaryColorLight,
                    selectedColor: Theme.of(context).primaryColorDark,
                    duration: const Duration(milliseconds: 200),
                    boxShape: BoxShape.circle,
                    onItemClicked: (index) {
                      welcomePages.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: signInAnonymously,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Text("Let's Go!"),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                            context,
                            createRouteWithVerticalSlideAnimation(
                                const LoginPage())),
                        style: const ButtonStyle(
                          padding: MaterialStatePropertyAll(EdgeInsets.zero),
                        ),
                        child: const Text(
                          "Log in",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Hmm...',
            style: TextStyle(color: Color(0xFF3F2305)),
          ),
          content: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              errorMessage,
              style: const TextStyle(color: Color(0xFF3F2305)),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
