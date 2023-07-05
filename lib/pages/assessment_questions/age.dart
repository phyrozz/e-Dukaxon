import 'package:e_dukaxon/assessment_data.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'assessment_result.dart';

class AgeSelectPage extends StatefulWidget {
  const AgeSelectPage({Key? key}) : super(key: key);

  @override
  State<AgeSelectPage> createState() => _AgeSelectPageState();
}

class _AgeSelectPageState extends State<AgeSelectPage> {
  String _currentAge = '3'; // Default age value
  List<String> ageOptions = [];

  final FixedExtentScrollController scrollController =
      FixedExtentScrollController(initialItem: 0);

  @override
  void initState() {
    super.initState();
    fetchIsParent();
  }

  void fetchIsParent() {
    // Access isParent using instance name
    if (isParent) {
      setState(() {
        _currentAge = '3';
        ageOptions = List.generate(15, (index) => (index + 3).toString());
      });
    } else {
      setState(() {
        _currentAge = '3';
        ageOptions = List.generate(33, (index) => (index + 3).toString())
          ..add('Older than 35');
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

  void storeDyslexiaResult(int dyslexiaScore) async {
    // Get the current user ID
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Reference to the document in the "users" collection
    DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

    bool hasDyslexia = dyslexiaScore >= 7; // Determine if user has dyslexia based on score threshold

    try {
      // Create or update the document with the "hasDyslexia" field
      await userDocRef.set({'hasDyslexia': hasDyslexia}, SetOptions(merge: true));
      print('Dyslexia result stored successfully!');
    } catch (e) {
      print('Error storing dyslexia result: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String pageTitle =
        isParent ? "Please enter your child's age" : "What is your age?";

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
                  Container(
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
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  style: const ButtonStyle(
                    padding: MaterialStatePropertyAll(
                      EdgeInsets.fromLTRB(35, 20, 35, 20),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context, _currentAge);
                    Navigator.pushNamed(context, '/myPages');
                    storeDyslexiaResult(dyslexiaScore);
                    print(dyslexiaScore);
                    dyslexiaScore = 0;
                    await updateIsNewAccount(false, _currentAge);
                  },
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
