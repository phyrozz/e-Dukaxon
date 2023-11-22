import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_dukaxon/pages/assessment_questions/age.dart';
import 'package:e_dukaxon/route_anims/horizontal_slide.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParentOrNotPage extends StatefulWidget {
  const ParentOrNotPage({super.key});

  @override
  State<ParentOrNotPage> createState() => _ParentOrNotPageState();
}

class _ParentOrNotPageState extends State<ParentOrNotPage> {
  bool isEnglish = true;

  @override
  void initState() {
    super.initState();
    getLanguage();
  }

  Future<void> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnglish = prefs.getBool('isEnglish') ?? true;

    setState(() {
      this.isEnglish = isEnglish;
    });
  }

  Future<void> setParentModePreferences(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isParentMode', value);
  }

  Future<void> updateIsParent(bool isParent) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? currentUser = auth.currentUser;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({'isParent': isParent});
      print('isParent updated successfully!');
    } catch (error) {
      print('Error updating isNewAccount: $error');
    }
  }

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
                Text(
                  isEnglish
                      ? "Are you a parent?"
                      : "Ikaw ba ay isang magulang?",
                  style: const TextStyle(
                      fontSize: 32.0, fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 15,
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.green),
                          padding: MaterialStatePropertyAll(
                              EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 20))),
                      onPressed: () {
                        Navigator.push(
                            context,
                            createRouteWithHorizontalSlideAnimation(
                                const AgeSelectPage()));

                        updateIsParent(true);
                        setParentModePreferences(true);
                      },
                      child: Text(isEnglish ? 'Yes' : 'Opo'),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    ElevatedButton(
                      style: const ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(Colors.red),
                          padding: MaterialStatePropertyAll(
                              EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 20))),
                      onPressed: () {
                        Navigator.push(
                            context,
                            createRouteWithHorizontalSlideAnimation(
                                const AgeSelectPage()));

                        updateIsParent(false);
                        setParentModePreferences(false);
                      },
                      child: Text(isEnglish ? 'No' : 'Hindi'),
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
                  label: Text(isEnglish ? 'Back' : 'Bumalik'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
