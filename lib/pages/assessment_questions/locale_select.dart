// Page that lets the new user choose what language they should use for the application
// Two languages will be supported currently: English & Filipino

import 'package:e_dukaxon/pages/assessment_questions/init.dart';
import 'package:e_dukaxon/pages/assessment_questions/question_1.dart';
import 'package:e_dukaxon/route_anims/horizontal_slide.dart';
import 'package:flutter/material.dart';
import 'package:e_dukaxon/locale.dart';

class LocaleSelectPage extends StatelessWidget {
  const LocaleSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(),
          Text(
            'Choose a language',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: SizedBox(
                  height: 75.0,
                  width: 75.0,
                  child: Image.asset(
                    'assets/images/united-kingdom.png',
                  ),
                ),
                label: const Text(''),
                onPressed: () {
                  setLanguage(true);
                  Navigator.push(
                      context,
                      createRouteWithHorizontalSlideAnimation(
                          const InitAssessmentPage()));
                },
              ),
              ElevatedButton.icon(
                icon: SizedBox(
                    height: 75.0,
                    width: 75.0,
                    child: Image.asset('assets/images/philippines.png')),
                label: const Text(''),
                onPressed: () {
                  setLanguage(false);
                  Navigator.push(
                      context,
                      createRouteWithHorizontalSlideAnimation(
                          const InitAssessmentPage()));
                },
              ),
            ],
          ),
          const SizedBox(),
        ],
      ),
    );
  }
}
