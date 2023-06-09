import 'package:e_dukaxon/pages/assessment_questions/question_1.dart';
import 'package:e_dukaxon/pages/route_anims/horizontal_slide.dart';
import 'package:flutter/material.dart';

class InitAssessmentPage extends StatelessWidget {
  const InitAssessmentPage({super.key});

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
