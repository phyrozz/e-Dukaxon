import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_dukaxon/assessment_data.dart';
import 'package:e_dukaxon/pages/assessment_questions/age.dart';
import 'package:e_dukaxon/pages/route_anims/horizontal_slide.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ParentOrNotPage extends StatefulWidget {
  const ParentOrNotPage({super.key});

  @override
  State<ParentOrNotPage> createState() => _ParentOrNotPageState();
}

class _ParentOrNotPageState extends State<ParentOrNotPage> {
  // Future<void> updateIsParent(bool isParent) async {
  //   try {
  //     FirebaseAuth auth = FirebaseAuth.instance;
  //     User? currentUser = auth.currentUser;

  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(currentUser!.uid)
  //         .update({'isParent': isParent});
  //     print('isNewAccount updated successfully!');
  //   } catch (error) {
  //     print('Error updating isNewAccount: $error');
  //     // Handle the error as needed
  //   }
  // }

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
                  "Are you a parent?",
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
                          padding: MaterialStatePropertyAll(
                              EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 20))),
                      onPressed: () async {
                        Navigator.push(
                            context,
                            createRouteWithHorizontalSlideAnimation(
                                const AgeSelectPage()));

                        // await updateIsParent(false);
                        isParent = false;
                      },
                      child: const Text('No'),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    ElevatedButton(
                      style: const ButtonStyle(
                          padding: MaterialStatePropertyAll(
                              EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 20))),
                      onPressed: () async {
                        Navigator.push(
                            context,
                            createRouteWithHorizontalSlideAnimation(
                                const AgeSelectPage()));

                        // await updateIsParent(true);
                        isParent = true;
                      },
                      child: const Text('Yes'),
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
