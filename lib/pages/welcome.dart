import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_dukaxon/data/letter_lessons.dart';
import 'package:e_dukaxon/pages/loading.dart';
import 'package:e_dukaxon/user_firestore.dart';
import 'package:flutter/material.dart';
import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/speak_text.dart';
// import 'package:flutter/services.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  String? errorMessage = '';

  @override
  void initState() {
    super.initState();
  }

  void addLesson(String lesson, Map<String, dynamic> data) {
    FirebaseFirestore.instance
        .collection('letters')
        .doc('en')
        .collection('lessons')
        .doc(lesson)
        .set(data)
        .then((value) {
      print('Lesson added to Firestore');
    }).catchError((error) {
      print('Error adding lesson to Firestore: $error');
    });
  }

  Future<void> signInAnonymously() async {
    try {
      Navigator.of(context).push(
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
      initLetterLessonData();
    } on Exception catch (e) {
      // Remove the loading widget
      Navigator.of(context).pop();

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
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 12, 30, 12),
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
                    const Text(
                      'eDukaxon v0.2.2 pre-release. For research uses only.',
                      style: TextStyle(fontSize: 8.0),
                    ),
                  ],
                ),
              ),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      child: Text("Let's Go!"),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      child: Text(
                        "Log in",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
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
