import 'dart:convert';
import 'dart:io';

import 'package:e_dukaxon/data/assessment.dart';
import 'package:e_dukaxon/pages/assessment_questions/question_1.dart';
import 'package:e_dukaxon/route_anims/horizontal_slide.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class InitAssessmentPage extends StatefulWidget {
  const InitAssessmentPage({super.key});

  @override
  State<InitAssessmentPage> createState() => _InitAssessmentPageState();
}

class _InitAssessmentPageState extends State<InitAssessmentPage> {
  @override
  void initState() {
    super.initState();
    initializeAssessmentData();
  }

  Future<void> initializeAssessmentData() async {
    Assessment initialAssessment = Assessment([0, 0, 0, 0, 0, 0, 0], false, 0);
    Map<String, dynamic> jsonMap = initialAssessment.toJson();

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/assessment_data.json');
    final initialJsonString = json.encode(jsonMap);
    await file.writeAsString(initialJsonString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(),
            Center(
              child: Column(
                children: const [
                  Text(
                    "Hello!",
                    style:
                        TextStyle(fontSize: 48.0, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Before we get started, let's answer a few questions.",
                    style: TextStyle(fontSize: 20.0),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                style: const ButtonStyle(
                    padding: MaterialStatePropertyAll(
                        EdgeInsets.fromLTRB(35, 20, 35, 20))),
                onPressed: () {
                  Navigator.push(
                      context,
                      createRouteWithHorizontalSlideAnimation(
                          const BangorQuestionOne()));
                },
                child: const Text("Let's Go!"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
