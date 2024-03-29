import 'package:e_dukaxon/pages/loading.dart';
import 'package:flutter/material.dart';
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

      Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false, // Make the loading page non-opaque
          pageBuilder: (context, _, __) {
            return const LoadingPage(); // Replace with your loading page widget
          },
        ),
      );

      // Check if the username already exists in the Firestore
      // There shouldn't be the same username in the database
      QuerySnapshot<Map<String, dynamic>> usernameCheck =
          await FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: username)
              .get();
      QuerySnapshot<Map<String, dynamic>> emailCheck = await FirebaseFirestore
          .instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (usernameCheck.docs.isNotEmpty) {
        if (!context.mounted) return;
        Navigator.pop(context);
        _showErrorDialog(
            context, "Username already exists. Please choose a different one.");
        print('Username already exists. Choose a different one.');
        return;
      }
      if (emailCheck.docs.isNotEmpty) {
        if (!context.mounted) return;
        Navigator.pop(context);
        _showErrorDialog(context,
            "Email address already exists. Please choose a different one.");
        print('Email address already exists. Choose a different one.');
        return;
      }

      // // Show the loading widget
      // showDialog(
      //   context: context,
      //   barrierDismissible: false,
      //   builder: (BuildContext context) {
      //     return const AlertDialog(
      //       content: Padding(
      //         padding: EdgeInsets.all(20.0),
      //         child: Column(
      //           mainAxisSize: MainAxisSize.min,
      //           children: [
      //             CircularProgressIndicator(
      //               color: Colors.white,
      //             ),
      //             SizedBox(height: 16),
      //             Text("Creating your account"),
      //           ],
      //         ),
      //       ),
      //     );
      //   },
      // );

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
      Navigator.of(context).pop();
      Navigator.pushNamed(context, '/');

      // Navigate to the login page
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => const LoginPage(),
      //     ));
    } on FirebaseAuthException catch (e) {
      // Remove the loading widget
      Navigator.of(context).pop();

      setState(() {
        errorMessage = e.message;
      });
      SpeakText().speak("Sign up failed. Please try again.");
      _showErrorDialog(context,
          "Sign up failed. Please try again."); // Show the error dialog
    } on Exception catch (e) {
      // Remove the loading widget
      Navigator.of(context).pop();

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
            GlowingOverscrollIndicator(
              color: Theme.of(context).primaryColorDark,
              axisDirection: AxisDirection.down,
              child: SingleChildScrollView(
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
                          labelText: 'Username',
                        ),
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          prefixIconColor: Colors.black,
                          labelText: 'Email',
                        ),
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16),
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
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16),
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
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16),
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
                            style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.green),
                            ),
                            onPressed: () {
                              signUp(
                                  context,
                                  _emailController.text,
                                  _userNameController.text,
                                  _passwordController.text,
                                  _confirmPasswordController.text);
                            },
                            child: const Text('Sign Up'),
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
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Hmm...',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodySmall,
            ),
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
