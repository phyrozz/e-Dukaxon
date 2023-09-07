import 'package:e_dukaxon/data/letter_lessons.dart';
import 'package:e_dukaxon/user_firestore.dart';
import 'package:flutter/material.dart';
import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/speak_text.dart';

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

  Future<void> signInAnonymously() async {
    try {
      // Show the loading widget
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(
                  color: Color(0xFF3F2305),
                ),
                SizedBox(height: 16),
                Text(
                  "Setting everything up...",
                  style: TextStyle(color: Color(0xFF3F2305)),
                ),
              ],
            ),
          );
        },
      );

      await Auth().signInAnonymously();
      String? userId = Auth().getCurrentUserId();
      // CollectionReference users =
      //     FirebaseFirestore.instance.collection('users');
      // DocumentReference userDocRef = users.doc(userId);

      // // Check if the document already exists
      // DocumentSnapshot userDoc = await userDocRef.get();
      // if (!userDoc.exists) {
      //   // Document doesn't exist, create a new one
      //   UserFirestore(userId).setCreateAccountInitialValues;
      //   UserFirestore(userId).initializeProgress;
      // }
      UserFirestore(userId: userId!).createNewAnonymousAccount();
      initLetterLessonData();
    } on Exception catch (e) {
      // Remove the loading widget
      Navigator.pop(context);

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
                      'eDukaxon v0.1.5 pre-release. For research uses only.',
                      style: TextStyle(fontSize: 8.0),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: ElevatedButton(
                onPressed: signInAnonymously,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  child: Text("Let's Go!"),
                ),
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
          content: Text(
            errorMessage,
            style: const TextStyle(color: Color(0xFF3F2305)),
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
