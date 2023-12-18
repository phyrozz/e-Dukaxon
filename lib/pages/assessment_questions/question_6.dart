import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/pages/assessment_questions/question_7.dart';
import 'package:e_dukaxon/route_anims/horizontal_slide.dart';
import 'package:e_dukaxon/user_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BangorQuestionSix extends StatefulWidget {
  const BangorQuestionSix({super.key});

  @override
  State<BangorQuestionSix> createState() => _BangorQuestionSixState();
}

class _BangorQuestionSixState extends State<BangorQuestionSix> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const LinearProgressIndicator(
              value: 6 / 7,
            ),
            Text(
              isEnglish ? 'Question #6' : 'Tanong #6',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Center(
              child: Column(children: [
                Text(
                  isEnglish
                      ? "Do you struggle reading dates and calendars?"
                      : "Nahihirapan ka bang magbasa ng mga petsa sa kalendaryo?",
                  style: const TextStyle(
                      fontSize: 32.0, fontWeight: FontWeight.w600),
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
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.green),
                          padding:
                              MaterialStatePropertyAll(EdgeInsets.all(20))),
                      onPressed: () async {
                        String? userId = Auth().getCurrentUserId();

                        await UserFirestore(userId: userId!)
                            .updateQuestionScore(5, 2);
                        Navigator.push(
                            context,
                            createRouteWithHorizontalSlideAnimation(
                                const BangorQuestionSeven()));
                      },
                      child: Text(isEnglish ? 'Yes' : 'Opo'),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    ElevatedButton(
                      style: const ButtonStyle(
                          padding:
                              MaterialStatePropertyAll(EdgeInsets.all(20))),
                      onPressed: () async {
                        String? userId = Auth().getCurrentUserId();

                        await UserFirestore(userId: userId!)
                            .updateQuestionScore(5, 1);
                        Navigator.push(
                            context,
                            createRouteWithHorizontalSlideAnimation(
                                const BangorQuestionSeven()));
                      },
                      child:
                          Text(isEnglish ? "I don't know" : "Hindi ko po alam"),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    ElevatedButton(
                      style: const ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(Colors.red),
                          padding:
                              MaterialStatePropertyAll(EdgeInsets.all(20))),
                      onPressed: () async {
                        String? userId = Auth().getCurrentUserId();

                        await UserFirestore(userId: userId!)
                            .updateQuestionScore(5, 0);
                        Navigator.push(
                            context,
                            createRouteWithHorizontalSlideAnimation(
                                const BangorQuestionSeven()));
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
