import 'package:e_dukaxon/pages/highlight_reading.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/widgets/app_bar.dart';
import 'assessment_questions/age.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AgeSelectPage(),
        ),
      );
    }
  }

  Future<String> generateText(String prompt) async {
    final endpoint =
        'https://api.openai.com/v1/engines/davinci-codex/completions';
    final promptJson =
        jsonEncode({'prompt': prompt, 'temperature': 0.7, 'max_tokens': 60});

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer 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',
      },
      body: promptJson,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final choices = responseData['choices'];
      if (choices.isNotEmpty) {
        return choices.first['text'];
      } else {
        throw Exception('Empty response from OpenAI API');
      }
    } else {
      throw Exception('Failed to generate text: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar("eDukaxon"),
      body: Container(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () async {
                // final text = await generateText("Generate a random paragraph.");
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        AgeSelectPage(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      var begin = const Offset(1.0, 0.0);
                      var end = Offset.zero;
                      var curve = Curves.ease;

                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(14.0),
                child: Text('Highlight Reading'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
