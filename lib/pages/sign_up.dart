import 'package:flutter/material.dart';
import '../widgets/volume_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/speak_text.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool passwordVisible = false;
  String? errorMessage = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    passwordVisible = true;
  }

  Future<void> signUp(BuildContext context, String email, String username,
      String password, String confirmPassword) async {
    try {
      if (password != confirmPassword) {
        SpeakText().speak("Passwords do not match. Please try again.");
        _showErrorDialog(context, "Passwords do not match. Please try again.");
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
                  color: Colors.white,
                ),
                SizedBox(height: 16),
                Text("Creating your account"),
              ],
            ),
          );
        },
      );

      AuthCredential credential =
          EmailAuthProvider.credential(email: email, password: password);

      try {
        UserCredential userCredential = await FirebaseAuth.instance.currentUser!
            .linkWithCredential(credential);

        User? user = userCredential.user;
        if (user != null) {
          print("Anonymous account successfully upgraded: ${user.uid}");
        } else {
          print("Linking failed. No user found.");
        }
      } catch (e) {
        print("Error upgrading anonymous account: $e");
      }

      String userId = Auth().currentUser!.uid;
      print(userId);

      await addUsernameToFirestore(userId, username, email);

      // Remove the loading widget
      Navigator.pop(context);
      Navigator.pushNamed(context, '/');

      // Navigate to the login page
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => const LoginPage(),
      //     ));
    } on FirebaseAuthException catch (e) {
      // Remove the loading widget
      Navigator.pop(context);

      setState(() {
        errorMessage = e.message;
      });
      SpeakText().speak("Sign up failed. Please try again.");
      _showErrorDialog(context,
          "Sign up failed. Please try again."); // Show the error dialog
    } on Exception catch (e) {
      // Remove the loading widget
      Navigator.pop(context);

      setState(() {
        errorMessage = e.toString();
      });
      SpeakText()
          .speak("An error occurred while signing up. Please try again.");
      _showErrorDialog(
          context, "An error occurred while signing up. Please try again.");
    }
  }

  Future<void> addUsernameToFirestore(
      String userId, String username, String email) async {
    // Get a reference to the users collection
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    try {
      // Create a document for the user using their user ID
      DocumentReference userDocRef = users.doc(userId);

      // Set the username and email field of the document with merge option set to true
      await userDocRef.set(
        {
          'username': username,
          'email': email,
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error adding username to Firestore: $e');
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
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 0),
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Create an account",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 36.0,
                      ),
                    ),
                    Text(
                      "By creating an account, your games and progress will be saved.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 60.0),
                    TextField(
                      controller: _userNameController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        prefixIconColor: Colors.black,
                        labelText: 'User Name',
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        prefixIconColor: Colors.black,
                        labelText: 'Email',
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: _passwordController,
                      obscureText: passwordVisible,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        prefixIconColor: Colors.black,
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
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: passwordVisible,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        prefixIconColor: Colors.black,
                        labelText: 'Enter password again',
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 15.0),
                    ButtonBar(
                      alignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          label: const Text("Back"),
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        ElevatedButton(
                          child: const Text('Sign Up'),
                          onPressed: () {
                            signUp(
                                context,
                                _emailController.text,
                                _userNameController.text,
                                _passwordController.text,
                                _confirmPasswordController.text);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 80,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: const VolumeButton(
        text:
            "Let's create an account! To get started, type in whatever username you wish to name yourself for the app. Just make sure not to inlude spaces and special characters. Next, enter your email address. If you don't have one, ask your parents to enter one for you. Then, enter your password. Make sure you to keep note of it so you wouldn't forget. Then, enter your password again to confirm that the password you typed is correct. Once you're done, hit the button that says: Create account, and you're ready to log in to the app.",
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
