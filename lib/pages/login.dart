import 'package:e_dukaxon/homepage_tree.dart';
import 'package:e_dukaxon/pages/loading.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_dukaxon/auth.dart';

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
        _showErrorDialog(context,
            "Please fill out your username or email address and password.");
        return;
      }

      // Show the loading widget
      // Navigator.pushReplacement(context,
      //   PageRouteBuilder(
      //     opaque: false,
      //     pageBuilder: (context, _, __) {
      //       return const LoadingPage();
      //     },
      //   ),
      // );
      Navigator.push(
          context,
          MaterialPageRoute<void>(
              builder: (BuildContext context) => const LoadingPage()));

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
        print("success!");
      } else if (usernameQuery.docs.isNotEmpty) {
        // Username matched, sign in with username and password
        await Auth().signInWithEmailAndPassword(
            email: usernameQuery.docs[0]['email'], password: password);
        print("success!");
      } else {
        // No matching email or username found
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found with the provided email or username.',
        );
      }
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute<void>(
              builder: (BuildContext context) => const HomePageTree()),
          (route) => false);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);

      setState(() {
        errorMessage = e.message;
      });
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
  void dispose() {
    super.dispose();
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
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(),
                    Text(
                      "Welcome back!",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 42.0,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      "Please log in to get started.",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 18.0,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
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
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16),
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
                            color: Theme.of(context).primaryColorDark,
                          ),
                          alignLabelWithHint: false,
                          filled: true,
                        ),
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16),
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
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Hmm...',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          content: Text(
            errorMessage,
            style: Theme.of(context).textTheme.bodySmall,
          ),
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
