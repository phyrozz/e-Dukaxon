import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_dukaxon/assessment_data.dart';
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
        padding: EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(),
            Center(
              child: Column(
                children: [
                  Text(
                    "Are you a parent?",
                    style:
                        TextStyle(fontSize: 32.0, fontWeight: FontWeight.w600),
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
                              padding: MaterialStatePropertyAll(
                                  EdgeInsets.all(20))),
                          onPressed: () async {
                            Navigator.pushNamed(context, '/assessment/ageSelect');
                  
                            // await updateIsParent(false);
                            isParent = false;
                          },
                          child: const Text(
                              'No. I will use this whole app by myself.'),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                              padding: MaterialStatePropertyAll(
                                  EdgeInsets.all(20))),
                          onPressed: () async {
                            Navigator.pushNamed(context, '/assessment/ageSelect');
                  
                            // await updateIsParent(true);
                            isParent = true;
                          },
                          child: const Text('Yes'),
                        ),
                      ],
                    ),
                    ]
              ),
            ),
            SizedBox(),
          ],
        ),
      ),
    );
  }
}
