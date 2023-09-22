import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_dukaxon/assessment_data.dart';
import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/pages/loading.dart';
import 'package:e_dukaxon/pages/sign_up.dart';
import 'package:e_dukaxon/widgets/new_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  String userId = "";
  String email = "";
  String userName = "";
  String age = "";
  bool isLoading = true;
  bool isParentMode = false;

  Future<void> getParentModeValue() async {
    final prefs = await SharedPreferences.getInstance();
    final prefValue = prefs.getBool('isParentMode');

    if (mounted) {
      setState(() {
        isParentMode = prefValue!;
      });
    }
  }

  Future<void> getUserAccountData() async {
    String? id = Auth().getCurrentUserId();
    if (id != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('users').doc(id).get();
      final data = snapshot.data();

      setState(() {
        userId = id;
        if (data != null && data.containsKey("email")) {
          email = data["email"];
          userName = data["username"];
          age = data["age"];
        } else {
          email = "";
          userName = "";
          age = "";
        }
        isLoading = false;
      });
    } else {
      print("User ID is null or empty.");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    getParentModeValue().then((value) => getUserAccountData());
    super.initState();
  }

  Future<void> signOut(BuildContext context) async {
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
              Text("Logging out"),
            ],
          ),
        );
      },
    );

    await Auth().signOut();
    Navigator.pop(context);
    isOnParentMode = false;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      body: isLoading
          ? const LoadingPage()
          : email == ""
              ? CustomScrollView(
                  slivers: [
                    WelcomeCustomAppBar(
                        text: "My Account", isParentMode: isParentMode),
                    SliverFillRemaining(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Create an account now to save your progress',
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ButtonBar(
                              alignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                    onPressed: () => signOut(context),
                                    icon: const Icon(Icons.logout),
                                    label: const Text('Delete progress')),
                                SizedBox(
                                  width: orientation == Orientation.portrait
                                      ? 12
                                      : 0,
                                  height: orientation == Orientation.landscape
                                      ? 12
                                      : 0,
                                ),
                                ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const SignUpPage()));
                                    },
                                    icon: const Icon(
                                        FontAwesomeIcons.arrowRightToBracket),
                                    label: const Text('Sign up')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : CustomScrollView(
                  slivers: [
                    WelcomeCustomAppBar(
                        text: "My Account", isParentMode: isParentMode),
                    SliverList(
                        delegate: SliverChildListDelegate.fixed([
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ListTile(
                              title: const Text(
                                'Email:',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              subtitle: Text(
                                email,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            ListTile(
                              title: const Text(
                                'Username:',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              subtitle: Text(
                                userName,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            ListTile(
                              title: const Text(
                                "Age/Child's age:",
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              subtitle: Text(
                                age,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ButtonBar(
                        alignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                              onPressed: () => signOut(context),
                              icon: const Icon(Icons.logout),
                              label: const Text(
                                'Log out',
                              )),
                        ],
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                    ])),
                  ],
                ),
    );
  }
}
