import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_dukaxon/assessment_data.dart';
import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/pages/loading.dart';
import 'package:e_dukaxon/pages/sign_up.dart';
import 'package:e_dukaxon/pages/welcome.dart';
import 'package:e_dukaxon/widgets/new_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String name = "";
  String age = "";
  bool isParent = true;
  bool isLoading = true;
  bool isParentMode = false;
  bool isOnEditMode = false;

  final TextEditingController editUserName = TextEditingController();
  final TextEditingController editAge = TextEditingController();
  final TextEditingController editName = TextEditingController();
  var editAccountOwner = [
    "Parent",
    "Adult",
  ];
  bool validateUserName = false;

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
          isParent = data["isParent"];
          name = data["name"];
        } else {
          email = "";
          userName = "";
          age = "";
          name = "";
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

  Future<void> showDeleteProgressConfirmation(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Delete ${email == "" ? 'Progress' : 'Account'}",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
          content: Text(
            "Are you sure you want to delete your ${email == "" ? 'progress' : 'account'}? This action is irreversible.",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: ButtonStyle(
                overlayColor:
                    MaterialStatePropertyAll(Theme.of(context).focusColor),
                foregroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.white;
                  }
                  return Theme.of(context).primaryColorDark;
                }),
              ),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteProgress();
              },
              style: ButtonStyle(
                overlayColor: const MaterialStatePropertyAll(Colors.red),
                foregroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.white;
                  }
                  return Colors.red;
                }),
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> showLogoutConfirmation(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Log Out",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
          content: Text(
            "Are you sure you want to log out?",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                logOut(context);
              },
              child: const Text("Log Out"),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteProgress() async {
    try {
      // Show a loading dialog
      Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false, // Make the loading page non-opaque
          pageBuilder: (context, _, __) {
            return const LoadingPage(); // Replace with your loading page widget
          },
        ),
      );

      // Get the user's ID
      String? userId = Auth().getCurrentUserId();

      if (userId != null) {
        // Delete the user's document in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .delete();

        // Delete the user from Firebase Authentication
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await currentUser.delete();
        }

        // Log out of the session after deleting the user
        await Auth().signOut();
        // Close the loading dialog
        if (!context.mounted) return;
        Navigator.pop(context);

        // Navigate back to the home screen or any other screen
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute<void>(
                builder: (BuildContext context) => const WelcomePage()),
            (route) => false);
      } else {
        // Handle the case where user ID is null
        print("User ID is null or empty.");
        Navigator.pop(context);
      }
    } catch (e) {
      // Handle errors, e.g., show an error dialog
      print("Error deleting progress: $e");
      Navigator.pop(context); // Close the loading dialog
    }
  }

  // Not to be confused with this signOut function
  // Only returns a dialog message that validates the user if they really want to sign out
  Future<void> logOut(BuildContext context) async {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false, // Make the loading page non-opaque
        pageBuilder: (context, _, __) {
          return const LoadingPage(); // Replace with your loading page widget
        },
      ),
    );

    await Auth().signOut();
    if (!context.mounted) return;
    Navigator.pop(context);
    isOnParentMode = false;
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => const WelcomePage()),
        (route) => false);
  }

  Future<void> showEditProfileDialog(
      BuildContext context, String title, String content, String name) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
          content: editDialogContent(context, content, name),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                switch (name) {
                  case "userName":
                    // If updating the username, check if it already exists
                    QuerySnapshot<Map<String, dynamic>> usernameCheck =
                        await FirebaseFirestore.instance
                            .collection('users')
                            .where('username', isEqualTo: editUserName.text)
                            .get();

                    if (usernameCheck.docs.isNotEmpty) {
                      // Username already exists, handle accordingly
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                              'Username already exists. Please choose a different one.'),
                        ),
                      );
                      print(
                          'Username already exists. Please choose a different one.');
                      break;
                    }

                    setState(() {
                      userName = editUserName.text;
                    });
                    updateProfile(userId, 'username', editUserName.text);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    break;
                  case "age":
                    setState(() {
                      age = editAge.text;
                    });
                    updateProfile(userId, 'age', editAge.text);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    break;
                  case "name":
                    setState(() {
                      name = editName.text;
                    });
                    updateProfile(userId, 'name', editName.text);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    break;
                  case "accountOwner":
                    updateProfile(userId, 'isParent', isParent);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    break;
                  default:
                    break;
                }
              },
              child: const Text("Done"),
            ),
          ],
        );
      },
    );
  }

  Widget editDialogContent(BuildContext context, String content, String name) {
    switch (name) {
      case "userName":
        return TextField(
          controller: editUserName,
          decoration: InputDecoration(
            hintText: content,
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            errorText: validateUserName
                ? "Username already exists. Please choose a different one."
                : null,
          ),
          style: const TextStyle(color: Colors.black, fontSize: 16),
        );
      case "age":
        return TextField(
          controller: editAge,
          decoration: InputDecoration(
            hintText: content,
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          style: const TextStyle(color: Colors.black, fontSize: 16),
        );
      case "name":
        return TextField(
          controller: editName,
          decoration: InputDecoration(
            hintText: content,
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          style: const TextStyle(color: Colors.black, fontSize: 16),
        );
      case "accountOwner":
        return DropdownButton(
          value: isParent ? "Parent" : "Adult",
          icon: const Icon(Icons.keyboard_arrow_down),
          items: editAccountOwner.map((String items) {
            return DropdownMenuItem(value: items, child: Text(items));
          }).toList(),
          style: TextStyle(
            color: Theme.of(context).focusColor,
            fontFamily: 'OpenDyslexic',
            fontSize: 18,
          ),
          onChanged: (String? newValue) {
            setState(() {
              if (isParent) {
                isParent = false;
              } else {
                isParent = true;
              }
            });
          },
        );
      default:
        return const SizedBox();
    }
  }

  Future<void> updateProfile(
      String userId, String field, dynamic newData) async {
    try {
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      await userDocRef.update({
        field: newData,
      });
      print('Data updated successfully.');
    } catch (e) {
      print('Error updating data: $e');
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
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Logging out"),
            ],
          ),
        );
      },
    );

    await Auth().signOut();
    if (!context.mounted) return;
    Navigator.pop(context);
    isOnParentMode = false;
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => const WelcomePage()),
        (route) => false);
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
                                    onPressed: () =>
                                        showDeleteProgressConfirmation(context),
                                    icon: const Icon(
                                        Icons.delete_forever_rounded),
                                    style: const ButtonStyle(
                                        backgroundColor:
                                            MaterialStatePropertyAll(
                                                Colors.red)),
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
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      if (isOnEditMode) {
                                        isOnEditMode = false;
                                      } else {
                                        isOnEditMode = true;
                                      }
                                    });
                                  },
                                  icon: Icon(isOnEditMode
                                      ? Icons.check_rounded
                                      : Icons.edit),
                                  label: Text(isOnEditMode ? 'Done' : 'Edit')),
                              const SizedBox(
                                width: 18,
                              ),
                              Text(
                                isOnEditMode ? 'Choose a card to edit' : '',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () => isOnEditMode
                                        ? showEditProfileDialog(
                                            context,
                                            "Edit Profile",
                                            userName,
                                            "userName")
                                        : null,
                                    child: ListTile(
                                      leading: Container(
                                        width: 50,
                                        height: 50,
                                        child: const CircleAvatar(
                                          child: Icon(
                                            Icons.account_box_outlined,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        "User name",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                      subtitle: Text(
                                        userName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ),
                                  ),
                                  isOnEditMode
                                      ? const SizedBox()
                                      : ListTile(
                                          leading: Container(
                                            width: 50,
                                            height: 50,
                                            child: const CircleAvatar(
                                              child: Icon(
                                                Icons.email_outlined,
                                                size: 30,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            "Email",
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                                          subtitle: Text(
                                            email,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ),
                                  InkWell(
                                    onTap: () => isOnEditMode
                                        ? showEditProfileDialog(
                                            context, "Edit Profile", age, "age")
                                        : null,
                                    child: ListTile(
                                      leading: Container(
                                        width: 50,
                                        height: 50,
                                        child: const CircleAvatar(
                                          child: Icon(
                                            Icons.cake_outlined,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        isParent ? "Child's age" : "Age",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                      subtitle: Text(
                                        age,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () => isOnEditMode
                                        ? showEditProfileDialog(context,
                                            "Edit Profile", name, "name")
                                        : null,
                                    child: ListTile(
                                      leading: Container(
                                        width: 50,
                                        height: 50,
                                        child: const CircleAvatar(
                                          child: Icon(
                                            Icons.person_outline_outlined,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        "Name",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                      subtitle: Text(
                                        name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ),
                                  ),
                                  isOnEditMode
                                      ? const SizedBox()
                                      : ListTile(
                                          leading: Container(
                                            width: 50,
                                            height: 50,
                                            child: const CircleAvatar(
                                              child: Icon(
                                                Icons.emoji_events_outlined,
                                                size: 30,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            "Achievements",
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                                          subtitle: Text(
                                            'N/A',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ),
                                  InkWell(
                                    onTap: () => isOnEditMode
                                        ? showEditProfileDialog(
                                            context,
                                            "Edit Profile",
                                            isParent ? "Parent" : "Adult",
                                            "accountOwner")
                                        : null,
                                    child: ListTile(
                                      leading: Container(
                                        width: 50,
                                        height: 50,
                                        child: const CircleAvatar(
                                          child: Icon(
                                            Icons.supervisor_account_outlined,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        "Account Owner",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                      subtitle: Text(
                                        isParent ? 'Parent' : 'Adult',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        ButtonBar(
                          alignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                                onPressed: () =>
                                    showLogoutConfirmation(context),
                                icon: const Icon(Icons.logout),
                                label: const Text(
                                  'Log out',
                                )),
                            ElevatedButton.icon(
                                onPressed: () =>
                                    showDeleteProgressConfirmation(context),
                                icon: const Icon(Icons.delete_forever_rounded),
                                style: const ButtonStyle(
                                    backgroundColor:
                                        MaterialStatePropertyAll(Colors.red)),
                                label: const Text(
                                  'Delete Account',
                                )),
                          ],
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                      ]),
                    ),
                  ],
                ),
    );
  }
}
