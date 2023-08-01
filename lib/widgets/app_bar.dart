import 'package:e_dukaxon/assessment_data.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/fetch_username.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  final bool isHomePage;
  final String? text;

  @override
  final Size preferredSize;
  final User? user = Auth().currentUser;

  CustomAppBar({
    Key? key,
    required this.isHomePage,
    this.text,
  })  : preferredSize = const Size.fromHeight(60.0),
        super(key: key);

  Future<void> signOut(BuildContext context) async {
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

  Widget _menuButton(BuildContext context) {
    return PopupMenuButton(
      icon: const IconTheme(
        data: IconThemeData(color: Colors.white),
        child: Icon(Icons.person),
      ),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: 'parentMode',
          child: isOnParentMode
              ? const Text('Exit Parent Mode')
              : const Text('Parent Mode'),
        ),
        const PopupMenuItem(
          value: 'createAccount',
          child: Text('Create an Account'),
        ),
        const PopupMenuItem(
          value: 'signIn',
          child: Text('Sign In'),
        ),
        // Uncomment if something goes wrong with the signInAnonymously feature
        // const PopupMenuItem(
        //   value: 'logOut',
        //   child: Text('Log Out'),
        // ),
      ],
      onSelected: (value) {
        if (value == 'parentMode') {
          if (isOnParentMode) {
            isOnParentMode = false;
            Navigator.pushNamedAndRemoveUntil(
                context, '/childHomePage', (route) => false);
          } else {
            Navigator.pushNamed(context, '/parentModeLogin');
          }
        } else if (value == 'logOut') {
          signOut(context);
        } else if (value == 'createAccount') {
          // Add a functionality that lets the user create an account and sign in when they choose to
        } else if (value == 'signIn') {
          // Add a functionality that lets the user sign in when they choose to
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      key: key,
      title: isHomePage
          ? FutureBuilder<String?>(
              future: getUsername(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  return Text(
                    'Welcome, ${snapshot.data}!',
                    style: Theme.of(context).textTheme.titleMedium,
                  );
                } else if (snapshot.hasError) {
                  return Text(
                    'Welcome!',
                    style: Theme.of(context).textTheme.titleMedium,
                  );
                } else {
                  return Text(
                    'No username found',
                    style: Theme.of(context).textTheme.titleMedium,
                  );
                }
              },
            )
          : Text(text!),
      automaticallyImplyLeading: false,
      actions: [
        Theme(
          data: ThemeData(
            canvasColor: Colors.grey[900],
          ),
          child: _menuButton(context),
        ),
      ],
    );
  }
}

// class CustomAppBar extends AppBar {
//   CustomAppBar({Key? key})
//       : super(
//           key: key,
//           title: const Text("eDukaxon"),
//           automaticallyImplyLeading: false,
//           backgroundColor: Colors.grey[900],
//         );

//   final User? user = Auth().currentUser;

//   Future<void> signOut(BuildContext context) async {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: const [
//               CircularProgressIndicator(
//                 color: Colors.white,
//               ),
//               SizedBox(height: 16),
//               Text("Logging out"),
//             ],
//           ),
//         );
//       },
//     );

//     await Auth().signOut();

//     Navigator.pop(context);
//   }

//   Widget _signOutButton(BuildContext context) {
//     return PopupMenuButton(
//       icon: const IconTheme(
//         data: IconThemeData(color: Colors.white),
//         child: Icon(Icons.person),
//       ),
//       itemBuilder: (BuildContext context) => [
//         const PopupMenuItem(
//           value: 'Log Out',
//           child: Text('Log Out'),
//         ),
//       ],
//       onSelected: (value) {
//         if (value == 'Log Out') {
//           signOut(context);
//         }
//       },
//     );
//   }

//   Widget build(BuildContext context) {
//     return AppBar(
//       key: key,
//       title: const Text("eDukaxon"),
//       automaticallyImplyLeading: false,
//       backgroundColor: Colors.grey[900],
//       actions: [
//         Theme(
//           data: ThemeData(
//             canvasColor: Colors.grey[900],
//           ),
//           child: _signOutButton(context),
//         ),
//       ],
//     );
//   }
// }
