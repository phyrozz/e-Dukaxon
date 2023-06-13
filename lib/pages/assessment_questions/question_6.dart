import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_dukaxon/assessment_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BangorQuestionSix extends StatefulWidget {
  const BangorQuestionSix({super.key});

  @override
  State<BangorQuestionSix> createState() => _BangorQuestionSixState();
}

class _BangorQuestionSixState extends State<BangorQuestionSix> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(),
            Center(
              child: Column(children: [
                Text(
                  "Do you struggle reading dates and calendars?",
                  style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: 15,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                          padding:
                              MaterialStatePropertyAll(EdgeInsets.all(20))),
                      onPressed: () {
                        question6 = 2;
                        Navigator.pushNamed(
                            context, '/assessment/questionSeven');
                      },
                      child: const Text('Yes'),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                          padding:
                              MaterialStatePropertyAll(EdgeInsets.all(20))),
                      onPressed: () {
                        question6 = 1;
                        Navigator.pushNamed(
                            context, '/assessment/questionSeven');
                      },
                      child: const Text("I don't know"),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                          padding:
                              MaterialStatePropertyAll(EdgeInsets.all(20))),
                      onPressed: () {
                        question6 = 0;
                        Navigator.pushNamed(
                            context, '/assessment/questionSeven');
                      },
                      child: const Text('No'),
                    ),
                  ],
                ),
              ]),
            ),
            ElevatedButton(
              style: ButtonStyle(
                  padding: MaterialStatePropertyAll(
                      EdgeInsets.fromLTRB(35, 20, 35, 20))),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
