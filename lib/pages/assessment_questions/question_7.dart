import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_dukaxon/assessment_data.dart';
import 'package:e_dukaxon/pages/assessment_questions/parent_or_not.dart';
import 'package:e_dukaxon/route_anims/horizontal_slide.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'assessment_result.dart';

class BangorQuestionSeven extends StatefulWidget {
  const BangorQuestionSeven({super.key});

  @override
  State<BangorQuestionSeven> createState() => _BangorQuestionSevenState();
}

class _BangorQuestionSevenState extends State<BangorQuestionSeven> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(),
            Center(
              child: Column(children: [
                const Text(
                  "Alright, last one. Did you find this short quiz difficult to answer?",
                  style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 15,
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: const ButtonStyle(
                          padding:
                              MaterialStatePropertyAll(EdgeInsets.all(20))),
                      onPressed: () {
                        question7 = 2;
                        dyslexiaScore += 2;
                        Navigator.push(
                            context,
                            createRouteWithHorizontalSlideAnimation(
                                const ParentOrNotPage()));
                      },
                      child: const Text('Yes'),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    ElevatedButton(
                      style: const ButtonStyle(
                          padding:
                              MaterialStatePropertyAll(EdgeInsets.all(20))),
                      onPressed: () {
                        question7 = 1;
                        dyslexiaScore += 1;
                        Navigator.push(
                            context,
                            createRouteWithHorizontalSlideAnimation(
                                const ParentOrNotPage()));
                      },
                      child: const Text("I don't know"),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    ElevatedButton(
                      style: const ButtonStyle(
                          padding:
                              MaterialStatePropertyAll(EdgeInsets.all(20))),
                      onPressed: () {
                        question7 = 0;
                        Navigator.push(
                            context,
                            createRouteWithHorizontalSlideAnimation(
                                const ParentOrNotPage()));
                      },
                      child: const Text('No'),
                    ),
                  ],
                ),
              ]),
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
      ),
    );
  }
}
