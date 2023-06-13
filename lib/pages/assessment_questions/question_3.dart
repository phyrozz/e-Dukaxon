import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_dukaxon/assessment_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BangorQuestionThree extends StatefulWidget {
  const BangorQuestionThree({super.key});

  @override
  State<BangorQuestionThree> createState() => _BangorQuestionThreeState();
}

class _BangorQuestionThreeState extends State<BangorQuestionThree> {
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
                  "Have you experienced mixing up numbers?",
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
                        question3 = 2;
                        Navigator.pushNamed(
                            context, '/assessment/questionFour');
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
                        question3 = 1;
                        Navigator.pushNamed(
                            context, '/assessment/questionFour');
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
                        question3 = 0;
                        Navigator.pushNamed(
                            context, '/assessment/questionFour');
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
