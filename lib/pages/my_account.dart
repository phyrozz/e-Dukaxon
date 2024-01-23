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
  String age = "3";
  bool isParent = true;
  bool isLoading = true;
  bool isParentMode = false;
  bool isOnEditMode = false;
  bool isEnglish = true;

  final TextEditingController editUserName = TextEditingController();
  final TextEditingController editName = TextEditingController();
  var editAccountOwner = [
    "Parent",
    "Adult",
  ];
  List<String> ageOptions = [];
  bool validateUserName = false;

  Future<void> getParentModeValue() async {
    final prefs = await SharedPreferences.getInstance();
    final prefValue = prefs.getBool('isParentMode');

    if (mounted) {
      setState(() {
        isParentMode = prefValue!;
        isLoading = false;
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

  Future<void> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnglish = prefs.getBool('isEnglish') ?? true;

    setState(() {
      this.isEnglish = isEnglish;
    });
  }

  void fetchAgeOptions() {
    if (!isParent) {
      setState(() {
        ageOptions = List.generate(15, (index) => (index + 3).toString());
      });
    } else {
      setState(() {
        ageOptions = List.generate(33, (index) => (index + 3).toString())
          ..add(isEnglish ? 'Older than 35' : '35 pataas');
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
              onPressed: () async {
                switch (name) {
                  case "userName":
                    // If updating the username, check if it already exists
                    QuerySnapshot<Map<String, dynamic>> usernameCheck =
                        await FirebaseFirestore.instance
                            .collection('users')
                            .where('username', isEqualTo: editUserName.text)
                            .get();

                    if (editUserName.text.length > 80) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          elevation: 20,
                          backgroundColor: Colors.red,
                          content: Text(
                            'Username is too long. Please enter a shorter one.',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                      );
                      break;
                    }
                    if (!editUserName.text
                        .contains(RegExp(r'^[a-zA-Z0-9]+$'))) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          elevation: 20,
                          backgroundColor: Colors.red,
                          content: Text(
                            'Username must not contain special characters.',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                      );
                      break;
                    }
                    if (usernameCheck.docs.isNotEmpty) {
                      // Username already exists
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          elevation: 20,
                          backgroundColor: Colors.red,
                          content: Text(
                            'Username already exists. Please choose a different one.',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                      );
                      break;
                    }

                    setState(() {
                      userName = editUserName.text;
                    });
                    updateProfile(userId, 'username', editUserName.text);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        elevation: 20,
                        backgroundColor: Colors.lightGreen.shade200,
                        content: const Text(
                          'Username has been updated successfully!',
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ),
                    );
                    break;
                  case "age":
                    updateProfile(userId, 'age', age);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    break;
                  case "name":
                    if (editName.text.length > 256) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          elevation: 20,
                          backgroundColor: Colors.red,
                          content: Text(
                            'Name is too long. Please try a shorter one.',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                      );
                      break;
                    }
                    if (!editName.text
                        .split(" ")
                        .join("")
                        .contains(RegExp(r'^[a-zA-Z0-9]+$'))) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          elevation: 20,
                          backgroundColor: Colors.red,
                          content: Text(
                            'Name must not contain special characters.',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                      );
                      break;
                    }

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
        return DropdownButton(
          value: age,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: ageOptions.map((String items) {
            return DropdownMenuItem(value: items, child: Text(items));
          }).toList(),
          style: TextStyle(
            color: Theme.of(context).focusColor,
            fontFamily: 'OpenDyslexic',
            fontSize: 18,
          ),
          elevation: 16,
          underline: Container(
            height: 2,
            color: Theme.of(context).primaryColorDark,
          ),
          onChanged: (String? newValue) {
            setState(() {
              age = newValue!;
            });
          },
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
          underline: Container(
            height: 2,
            color: Theme.of(context).primaryColorDark,
          ),
          elevation: 16,
          onChanged: (String? selectedValue) {
            setState(() {
              if (selectedValue == "Parent") {
                fetchAgeOptions();
                age = '3';
                isParent = true;
              } else {
                fetchAgeOptions();
                age = '3';
                isParent = false;
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
    getLanguage()
        .then((value) => getUserAccountData())
        .then((value) => fetchAgeOptions())
        .then((value) => getParentModeValue());
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
              ? Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image:
                          const AssetImage("assets/images/my_account_bg.png"),
                      fit: BoxFit.contain,
                      alignment: Alignment.centerRight,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context)
                            .scaffoldBackgroundColor
                            .withOpacity(0.5),
                        BlendMode.srcOver,
                      ),
                    ),
                  ),
                  child: GlowingOverscrollIndicator(
                    color: Theme.of(context).primaryColorDark,
                    axisDirection: AxisDirection.down,
                    child: CustomScrollView(
                      slivers: [
                        WelcomeCustomAppBar(
                            text: isEnglish ? "My Account" : "Aking Account",
                            isParentMode: isParentMode),
                        SliverFillRemaining(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  isEnglish
                                      ? 'Create an account now to save your progress'
                                      : 'Gumawa na ng account para hindi mawala ang iyong progress',
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                ButtonBar(
                                  alignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton.icon(
                                        onPressed: () =>
                                            showDeleteProgressConfirmation(
                                                context),
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
                                      height:
                                          orientation == Orientation.landscape
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
                                        icon: const Icon(FontAwesomeIcons
                                            .arrowRightToBracket),
                                        label: const Text('Sign up')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    WelcomeCustomAppBar(
                        text: isEnglish ? "My Account" : "Aking Account",
                        isParentMode: isParentMode),
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
                                  label: Text(
                                    isOnEditMode
                                        ? (isEnglish ? 'Done' : 'Tapos')
                                        : (isEnglish ? 'Edit' : 'I-edit'),
                                    style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            Theme.of(context).primaryColorDark),
                                  )),
                              const SizedBox(
                                width: 18,
                              ),
                              Text(
                                isOnEditMode
                                    ? (isEnglish
                                        ? 'Choose a card to edit'
                                        : 'Pumili ng card na ieedit')
                                    : '',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: InkWell(
                                      onTap: () => isOnEditMode
                                          ? showEditProfileDialog(
                                              context,
                                              "Edit Profile",
                                              userName,
                                              "userName")
                                          : null,
                                      child: Material(
                                        clipBehavior: Clip.antiAlias,
                                        elevation: 20.0,
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(12))),
                                        shadowColor:
                                            Theme.of(context).focusColor,
                                        child: ListTile(
                                          tileColor: Theme.of(context)
                                              .primaryColorLight,
                                          leading: Container(
                                            width: 50,
                                            height: 50,
                                            child: CircleAvatar(
                                              backgroundColor: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              child: const Icon(
                                                Icons.account_box_outlined,
                                                size: 30,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            "User name",
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall!
                                                .copyWith(fontSize: 18),
                                          ),
                                          subtitle: Text(
                                            userName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .copyWith(fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  isOnEditMode
                                      ? const SizedBox()
                                      : Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Material(
                                            clipBehavior: Clip.antiAlias,
                                            elevation: 20.0,
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(12))),
                                            shadowColor:
                                                Theme.of(context).focusColor,
                                            child: ListTile(
                                              shape:
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  12))),
                                              tileColor: Theme.of(context)
                                                  .primaryColorLight,
                                              leading: Container(
                                                width: 50,
                                                height: 50,
                                                child: CircleAvatar(
                                                  backgroundColor: Theme.of(
                                                          context)
                                                      .scaffoldBackgroundColor,
                                                  child: const Icon(
                                                    Icons.email_outlined,
                                                    size: 30,
                                                  ),
                                                ),
                                              ),
                                              title: Text(
                                                "Email",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall!
                                                    .copyWith(fontSize: 18),
                                              ),
                                              subtitle: Text(
                                                email,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(fontSize: 16),
                                              ),
                                            ),
                                          ),
                                        ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: InkWell(
                                      onTap: () => isOnEditMode
                                          ? showEditProfileDialog(context,
                                              "Edit Profile", age, "age")
                                          : null,
                                      child: Material(
                                        clipBehavior: Clip.antiAlias,
                                        elevation: 20.0,
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(12))),
                                        shadowColor:
                                            Theme.of(context).focusColor,
                                        child: ListTile(
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(12))),
                                          tileColor: Theme.of(context)
                                              .primaryColorLight,
                                          leading: Container(
                                            width: 50,
                                            height: 50,
                                            child: CircleAvatar(
                                              backgroundColor: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              child: const Icon(
                                                Icons.cake_outlined,
                                                size: 30,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            isParent
                                                ? (isEnglish
                                                    ? "Child's age"
                                                    : "Edad ng bata")
                                                : (isEnglish ? "Age" : "Edad"),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall!
                                                .copyWith(fontSize: 18),
                                          ),
                                          subtitle: Text(
                                            age,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .copyWith(fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: InkWell(
                                      onTap: () => isOnEditMode
                                          ? showEditProfileDialog(context,
                                              "Edit Profile", name, "name")
                                          : null,
                                      child: Material(
                                        clipBehavior: Clip.antiAlias,
                                        elevation: 20.0,
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(12))),
                                        shadowColor:
                                            Theme.of(context).focusColor,
                                        child: ListTile(
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(12))),
                                          tileColor: Theme.of(context)
                                              .primaryColorLight,
                                          leading: Container(
                                            width: 50,
                                            height: 50,
                                            child: CircleAvatar(
                                              backgroundColor: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              child: const Icon(
                                                Icons.person_outline_outlined,
                                                size: 30,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            isEnglish ? "Name" : "Pangalan",
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall!
                                                .copyWith(fontSize: 18),
                                          ),
                                          subtitle: Text(
                                            name == "" ? "-" : name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .copyWith(fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  isOnEditMode
                                      ? const SizedBox()
                                      : Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Material(
                                            clipBehavior: Clip.antiAlias,
                                            elevation: 20.0,
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(12))),
                                            shadowColor:
                                                Theme.of(context).focusColor,
                                            child: ListTile(
                                              shape:
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  12))),
                                              tileColor: Theme.of(context)
                                                  .primaryColorLight,
                                              leading: Container(
                                                width: 50,
                                                height: 50,
                                                child: CircleAvatar(
                                                  backgroundColor: Theme.of(
                                                          context)
                                                      .scaffoldBackgroundColor,
                                                  child: const Icon(
                                                    Icons.emoji_events_outlined,
                                                    size: 30,
                                                  ),
                                                ),
                                              ),
                                              title: Text(
                                                isEnglish
                                                    ? "Achievements"
                                                    : "Mga Tagumpay",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall!
                                                    .copyWith(fontSize: 18),
                                              ),
                                              subtitle: Text(
                                                '-',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(fontSize: 16),
                                              ),
                                            ),
                                          ),
                                        ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: InkWell(
                                      onTap: () => isOnEditMode
                                          ? showEditProfileDialog(
                                              context,
                                              "Edit Profile",
                                              isParent ? "Parent" : "Adult",
                                              "accountOwner")
                                          : null,
                                      child: Material(
                                        clipBehavior: Clip.antiAlias,
                                        elevation: 20.0,
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(12))),
                                        shadowColor:
                                            Theme.of(context).focusColor,
                                        child: Material(
                                          clipBehavior: Clip.antiAlias,
                                          elevation: 20.0,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(12))),
                                          shadowColor:
                                              Theme.of(context).focusColor,
                                          child: ListTile(
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(12))),
                                            tileColor: Theme.of(context)
                                                .primaryColorLight,
                                            leading: Container(
                                              width: 50,
                                              height: 50,
                                              child: CircleAvatar(
                                                backgroundColor: Theme.of(
                                                        context)
                                                    .scaffoldBackgroundColor,
                                                child: const Icon(
                                                  Icons
                                                      .supervisor_account_outlined,
                                                  size: 30,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              isEnglish
                                                  ? "Account Owner"
                                                  : "May-ari ng Account",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall!
                                                  .copyWith(fontSize: 18),
                                            ),
                                            subtitle: Text(
                                              isParent
                                                  ? isEnglish
                                                      ? 'Parent'
                                                      : 'Magulang'
                                                  : isEnglish
                                                      ? 'Adult'
                                                      : 'Hustong Gulang',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(fontSize: 16),
                                            ),
                                          ),
                                        ),
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
