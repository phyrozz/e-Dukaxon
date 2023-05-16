import 'package:flutter/material.dart';
import '../widgets/volume_button.dart';
import 'sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/speak_text.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      if (_controllerEmail.text.isEmpty || _controllerPassword.text.isEmpty) {
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

      // Call the Auth class method to sign in user with email and password
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);

      setState(() {
        errorMessage = e.message;
      });
      SpeakText()
          .speak("Sign in failed. Please check your email and password.");
      _showErrorDialog(context,
          "Sign in failed. Please check your email and password."); // Show the error dialog
    } on Exception catch (e) {
      // Remove the loading widget
      Navigator.pop(context);

      setState(() {
        errorMessage = e.toString();
      });
      SpeakText()
          .speak("Something went wrong while signing in. Please try again.");
      _showErrorDialog(
          context, "Something went wrong while signing in. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
              controller: _controllerEmail,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person),
                labelText: 'Email / Username',
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _controllerPassword,
              obscureText: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.lock),
                labelText: 'Password',
              ),
              style: TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              child: const Padding(
                padding: EdgeInsets.all(14.0),
                child: Text('Log In'),
              ),
              onPressed: signInWithEmailAndPassword,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignUpPage()));
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
