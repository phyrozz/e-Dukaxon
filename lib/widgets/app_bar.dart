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
    Navigator.pushNamed(context, '/');
  }

  Widget _signOutButton(BuildContext context) {
    return PopupMenuButton(
      icon: const IconTheme(
        data: IconThemeData(color: Colors.white),
        child: Icon(Icons.person),
      ),
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem(
          value: 'Log Out',
          child: Text('Log Out'),
        ),
      ],
      onSelected: (value) {
        if (value == 'Log Out') {
          signOut(context);
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
                  return CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  return Text('Welcome, ${snapshot.data}!');
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return const Text('No username found');
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
          child: _signOutButton(context),
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
