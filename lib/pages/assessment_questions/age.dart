import 'dart:convert';
import 'dart:io';

import 'package:e_dukaxon/assessment_data.dart';
import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/data/assessment.dart';
import 'package:e_dukaxon/user_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AgeSelectPage extends StatefulWidget {
  const AgeSelectPage({Key? key}) : super(key: key);

  @override
  State<AgeSelectPage> createState() => _AgeSelectPageState();
}

class _AgeSelectPageState extends State<AgeSelectPage> {
  final String? _currentUserId = Auth().getCurrentUserId();
  String _currentAge = '3'; // Default age value
  List<String> ageOptions = [];
  bool isEnglish = true;

  final FixedExtentScrollController scrollController =
      FixedExtentScrollController(initialItem: 0);

  @override
  void initState() {
    super.initState();
    fetchIsParent();
    getLanguage();
  }

  Future<void> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnglish = prefs.getBool('isEnglish') ?? true;

    setState(() {
      this.isEnglish = isEnglish;
    });
  }

  void fetchIsParent() {
    // Access isParent using instance name
    if (!isParent) {
      setState(() {
        _currentAge = '3';
        ageOptions = List.generate(15, (index) => (index + 3).toString());
      });
    } else {
      setState(() {
        _currentAge = '3';
        ageOptions = List.generate(33, (index) => (index + 3).toString())
          ..add(isEnglish ? 'Older than 35' : 'Mas matanda sa 35');
      });
    }
  }

  Future<void> updateIsNewAccount(bool isNewAccount, String age) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? currentUser = auth.currentUser;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({'isNewAccount': isNewAccount, 'age': age});
      print('isNewAccount updated successfully!');
    } catch (error) {
      print('Error updating isNewAccount: $error');
      // Handle the error as needed
    }
  }

  Future<void> storeDyslexiaResult() async {
    // Retrieve the values of each question and store them as a dyslexiaScore variable
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/assessment_data.json');

    final jsonString = await file.readAsString();
    final assessment = Assessment.fromJson(json.decode(jsonString));
    int sum = assessment.questions.fold(0, (prev, element) => prev + element);

    // Update the dyslexiaScore with the sum value
    assessment.dyslexiaScore = sum;

    final updatedJsonString = json.encode(assessment.toJson());
    await file.writeAsString(updatedJsonString);

    // Get the current user ID
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Reference to the document in the "users" collection
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    bool hasDyslexia = assessment.dyslexiaScore >=
        7; // Determine if user has dyslexia based on score threshold

    try {
      // Create or update the document with the "hasDyslexia" field
      await userDocRef.set(
          {'hasDyslexia': hasDyslexia, 'questions': assessment.questions},
          SetOptions(merge: true));
      print('Dyslexia result stored successfully!');
    } catch (e) {
      print('Error storing dyslexia result: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String pageTitle = isParent
        ? (isEnglish
            ? "Please enter your child's age"
            : "Ano ang edad ng inyong anak?")
        : (isEnglish ? "What is your age?" : "Ano ang iyong edad?");

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(),
            Center(
              child: Column(
                children: [
                  Text(
                    pageTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 32.0,
                  ),
                  SizedBox(
                    height: 150.0,
                    width: 180,
                    child: ListWheelScrollView(
                      controller: scrollController,
                      itemExtent: 50.0,
                      children: ageOptions.map((String age) {
                        return ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          tileColor: _currentAge == age
                              ? const Color(0xFF3F2305)
                              : Colors.transparent,
                          title: Text(
                            age,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: _currentAge == age
                                  ? FontWeight.w900
                                  : FontWeight.normal,
                              color: _currentAge == age
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          dense: true,
                        );
                      }).toList(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _currentAge = ageOptions[index];
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: const ButtonStyle(
                    padding: MaterialStatePropertyAll(
                      EdgeInsets.fromLTRB(35, 20, 35, 20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(isEnglish ? 'Back' : 'Bumalik'),
                ),
                ElevatedButton(
                  style: const ButtonStyle(
                    padding: MaterialStatePropertyAll(
                      EdgeInsets.fromLTRB(35, 20, 35, 20),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context, _currentAge);
                    if (await UserFirestore(userId: _currentUserId!)
                        .getIsParent()) {
                      Navigator.pushNamedAndRemoveUntil(context,
                          '/childHomePage', (Route<dynamic> route) => false);
                    } else {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/myPages', (Route<dynamic> route) => false);
                    }
                    storeDyslexiaResult();
                    await updateIsNewAccount(false, _currentAge);
                  },
                  child: Text(isEnglish ? 'Next' : 'Susunod'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
