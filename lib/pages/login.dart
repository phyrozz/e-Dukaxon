import 'package:flutter/material.dart';
import '../widgets/volume_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/speak_text.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool passwordVisible = false;
  String? errorMessage = '';
  final TextEditingController _controllerEmailorUsername =
      TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    passwordVisible = true;
  }

  Future<void> signInWithEmailAndPassword() async {
    try {
      if (_controllerEmailorUsername.text.isEmpty ||
          _controllerPassword.text.isEmpty) {
        // Display error message for empty fields
        SpeakText().speak(
            "Please fill out your username or email address and password.");
        _showErrorDialog(context,
            "Please fill out your username or email address and password.");
        return;
      }

      // Show the loading widget
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFF3F2305),
                ),
                SizedBox(height: 16),
                Text("Signing in"),
              ],
            ),
          );
        },
      );

      // Check if the input matches a username
      String email = _controllerEmailorUsername.text;
      String password = _controllerPassword.text;

      // Retrieve the user with the provided email
      final QuerySnapshot emailQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      // Retrieve the user with the provided username
      final QuerySnapshot usernameQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: email)
          .limit(1)
          .get();

      if (emailQuery.docs.isNotEmpty) {
        // Email matched, sign in with email and password
        await Auth()
            .signInWithEmailAndPassword(email: email, password: password);
      } else if (usernameQuery.docs.isNotEmpty) {
        // Username matched, sign in with username and password
        await Auth().signInWithEmailAndPassword(
            email: usernameQuery.docs[0]['email'], password: password);
      } else {
        // No matching email or username found
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found with the provided email or username.',
        );
      }

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);

      setState(() {
        errorMessage = e.message;
      });
      SpeakText().speak(
          "Sign in failed. Please check your email or username and password.");
      _showErrorDialog(
        context,
        "Sign in failed. Please check your email or username and password.",
      ); // Show the error dialog
    } on Exception catch (e) {
      // Remove the loading widget
      Navigator.pop(context);

      setState(() {
        errorMessage = e.toString();
      });
      SpeakText()
          .speak("Something went wrong while signing in. Please try again.");
      _showErrorDialog(
        context,
        "Something went wrong while signing in. Please try again.",
      );
    }
  }

  void togglePasswordVisibility() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(
            child: SafeArea(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(),
                    Text(
                      "Let's start learning!",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 48.0,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      'eDukaxon v0.1.5 pre-release. For research uses only.',
                      style: TextStyle(fontSize: 10.0),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 70, 20, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: TextField(
                        controller: _controllerEmailorUsername,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          labelText: 'Email / Username',
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: TextField(
                        controller: _controllerPassword,
                        obscureText: passwordVisible,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: togglePasswordVisibility,
                            color: Colors.black,
                          ),
                          alignLabelWithHint: false,
                          filled: true,
                        ),
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          onPressed: signInWithEmailAndPassword,
                          child: const Text('Log In'),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: const VolumeButton(
        text:
            "Hello! Let's get started by entering your username or email address. then, enter your password. Once you're done, tap the big gray button! If you don't have an account or you want to create another one, tap the text below the big button that says I want to create an account.",
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hmm...'),
          content: Text(errorMessage),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
