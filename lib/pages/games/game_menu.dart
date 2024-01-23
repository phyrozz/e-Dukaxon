import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GameMenuPage extends StatefulWidget {
  final String name;
  final String description;
  final String gameIcon;
  final Widget navigateTo;
  final String docName;

  const GameMenuPage({
    Key? key,
    required this.name,
    required this.description,
    required this.gameIcon,
    required this.navigateTo,
    required this.docName,
  }) : super(key: key);

  @override
  State<GameMenuPage> createState() => _GameMenuPageState();
}

class _GameMenuPageState extends State<GameMenuPage> {
  Future<void> addPlayDocument() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;
        final playsCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('games')
            .doc(widget.docName)
            .collection('plays');

        await playsCollection.add({
          'gameStartedAt': FieldValue.serverTimestamp(),
          'score': 0,
        });

        print('Play document added successfully.');
      } else {
        print('User is not signed in.');
      }
    } catch (e) {
      print('Error adding play document: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(100, 0, 100, 30),
              child: Column(
                children: [
                  SizedBox(
                    width: 100,
                    child: Image.asset(
                      widget.gameIcon,
                    ),
                  ),
                  Text(widget.name),
                  Text(
                    widget.description,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                addPlayDocument();
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => widget.navigateTo,
                  ),
                );
              },
              child: const Text("Let's Play!"),
            ),
          ],
        ),
      ),
    );
  }
}
