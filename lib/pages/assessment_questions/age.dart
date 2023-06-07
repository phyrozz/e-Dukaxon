import 'package:e_dukaxon/assessment_data.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AgeSelectPage extends StatefulWidget {
  const AgeSelectPage({Key? key}) : super(key: key);

  @override
  State<AgeSelectPage> createState() => _AgeSelectPageState();
}

class _AgeSelectPageState extends State<AgeSelectPage> {
  String _currentAge = '3'; // Default age value
  List<String> ageOptions = [];

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
          ageOptions = List.generate(14, (index) => (index + 3).toString());
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

  @override
Widget build(BuildContext context) {
  String pageTitle = isParent ? "Please enter your child's age" : "What is your age?";

  return Scaffold(
    body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(),
                Center(
                  child: Column(
                    children: [
                      Text(
                        pageTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 32.0,
                      ),
                      DropdownButtonFormField<String>(
                        style: TextStyle(color: Colors.black, fontFamily: 'OpenDyslexic'),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(const Radius.circular(20)),
                          ),
                        ),
                        value: _currentAge,
                        items: ageOptions.map((String age) {
                          return DropdownMenuItem<String>(
                            value: age,
                            child: Text(age),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            _currentAge = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                          padding: MaterialStatePropertyAll(
                              EdgeInsets.fromLTRB(35, 20, 35, 20))),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Back'),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                          padding: MaterialStatePropertyAll(
                              EdgeInsets.fromLTRB(35, 20, 35, 20))),
                      onPressed: () async {
                        Navigator.pop(context, _currentAge);
                        Navigator.pushNamed(context, '/myPages');

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
