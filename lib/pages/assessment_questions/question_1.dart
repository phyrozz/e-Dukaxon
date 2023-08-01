import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_dukaxon/assessment_data.dart';
import 'package:e_dukaxon/data/assessment.dart';
import 'package:e_dukaxon/pages/assessment_questions/question_2.dart';
import 'package:e_dukaxon/route_anims/horizontal_slide.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class BangorQuestionOne extends StatefulWidget {
  const BangorQuestionOne({super.key});

  @override
  State<BangorQuestionOne> createState() => _BangorQuestionOneState();
}

class _BangorQuestionOneState extends State<BangorQuestionOne> {
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
                  "Do you find it difficult to determine left and right directions?",
                  style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
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
                      onPressed: () async {
                        updateDyslexiaScore(1, 2);
                        Navigator.push(
                            context,
                            createRouteWithHorizontalSlideAnimation(
                                const BangorQuestionTwo()));
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
                      onPressed: () async {
                        updateDyslexiaScore(1, 1);
                        Navigator.push(
                            context,
                            createRouteWithHorizontalSlideAnimation(
                                const BangorQuestionTwo()));
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
                      onPressed: () async {
                        updateDyslexiaScore(1, 0);
                        question1 = 0;
                        Navigator.push(
                            context,
                            createRouteWithHorizontalSlideAnimation(
                                const BangorQuestionTwo()));
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
