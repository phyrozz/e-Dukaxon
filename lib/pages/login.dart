import 'package:flutter/material.dart';
import '../widgets/volume_button.dart';
import 'sign_up.dart';
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
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(
                  color: Colors.white,
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  height: 100,
                ),
                const Text(
                  "Let's start learning!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 36.0,
                  ),
                ),
                const SizedBox(height: 32.0),
                TextField(
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
                const SizedBox(height: 16.0),
                TextField(
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
                const SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: signInWithEmailAndPassword,
                  child: const Padding(
                    padding: EdgeInsets.all(14.0),
                    child: Text('Log In'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            SignUpPage(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          var begin = const Offset(1.0, 0.0);
                          var end = Offset.zero;
                          var curve = Curves.ease;

                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));

                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => const SignUpPage()));
                  },
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(14.0),
                    child: Text('I want to create an account'),
                  ),
                ),
              ],
            ),
          ),
        ),
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
