// Page that lets the new user choose what language they should use for the application
// Two languages will be supported currently: English & Filipino

import 'package:e_dukaxon/pages/assessment_questions/question_1.dart';
import 'package:e_dukaxon/route_anims/horizontal_slide.dart';
import 'package:flutter/material.dart';

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
          Text('Choose a language:', style: Theme.of(context).textTheme.displayMedium,),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: Image.asset('assets/images/united-kingdom.png'),
                label: const Text(''),
                onPressed: () {
                  Navigator.push(
                      context,
                      createRouteWithHorizontalSlideAnimation(
                          const BangorQuestionOne()));
                },
              ),
              ElevatedButton.icon(
                icon: Image.asset('assets/images/philippines.png'),
                label: const Text(''),
                onPressed: () {
                  Navigator.push(
                      context,
                      createRouteWithHorizontalSlideAnimation(
                          const BangorQuestionOne()));
                },
              ),
            ],
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  style: const ButtonStyle(
                      padding: MaterialStatePropertyAll(
                          EdgeInsets.fromLTRB(35, 20, 35, 20))),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}