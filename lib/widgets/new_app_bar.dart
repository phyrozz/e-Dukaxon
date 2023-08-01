import 'package:e_dukaxon/assessment_data.dart';
import 'package:e_dukaxon/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WelcomeCustomAppBar extends StatelessWidget {
  const WelcomeCustomAppBar({super.key});

  Widget _menuButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        _showMenuDialog(context);
      },
      icon: const Icon(
        Icons.person,
        size: 30,
      ),
    );
  }

  Future<void> _showMenuDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/parentModeLogin'),
                  icon: const Icon(FontAwesomeIcons.userTie),
                  label: const Text('Parent Mode')),
              const SizedBox(
                height: 12,
              ),
              ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(FontAwesomeIcons.userPlus),
                  label: const Text('Create an account')),
              const SizedBox(
                height: 12,
              ),
              ElevatedButton.icon(
                  onPressed: () => signOut(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Log out')),
            ],
          ),
        );
      },
    );
  }

  // Widget _buildMenuItem(BuildContext context,
  //     {required String value, required String label}) {
  //   return InkWell(
  //     onTap: () {
  //       _handleMenuOption(context, value);
  //       Navigator.pop(context); // Close the dialog when an option is tapped
  //     },
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
  //       child: Text(
  //         label,
  //         style: const TextStyle(fontSize: 16.0, color: Colors.white),
  //       ),
  //     ),
  //   );
  // }

  // void _handleMenuOption(BuildContext context, String value) {
  //   switch (value) {
  //     case 'parentMode':
  //       Navigator
  //       if (isOnParentMode) {
  //         isOnParentMode = false;
  //         Navigator.pushNamedAndRemoveUntil(
  //             context, '/childHomePage', (route) => false);
  //       } else {
  //         Navigator.pushNamed(context, '/parentModeLogin');
  //       }
  //       break;
  //     case 'logOut':
  //       signOut(context);
  //       break;
  //     case 'createAccount':
  //       // Implement the functionality for creating an account here
  //       // ...
  //       break;
  //     case 'signIn':
  //       // Implement the functionality for signing in here
  //       // ...
  //       break;
  //     // Add more cases for other menu options as needed
  //     default:
  //       break;
  //   }
  // }

  // Widget _menuButton(BuildContext context) {
  //   return PopupMenuButton(
  //     iconSize: 100,
  //     icon: const IconTheme(
  //       data: IconThemeData(color: Color(0xFF3F2305)),
  //       child: Icon(Icons.person),
  //     ),
  //     itemBuilder: (BuildContext context) => [
  //       PopupMenuItem(
  //         value: 'parentMode',
  //         child: isOnParentMode
  //             ? const Text('Exit Parent Mode')
  //             : const Text('Parent Mode'),
  //       ),
  //       const PopupMenuItem(
  //         value: 'createAccount',
  //         child: Text('Create an Account'),
  //       ),
  //       const PopupMenuItem(
  //         value: 'signIn',
  //         child: Text('Sign In'),
  //       ),
  //       // Uncomment if something goes wrong with the signInAnonymously feature
  //       // const PopupMenuItem(
  //       //   value: 'logOut',
  //       //   child: Text('Log Out'),
  //       // ),
  //     ],
  //     onSelected: (value) {
  //       if (value == 'parentMode') {
  //         if (isOnParentMode) {
  //           isOnParentMode = false;
  //           Navigator.pushNamedAndRemoveUntil(
  //               context, '/childHomePage', (route) => false);
  //         } else {
  //           Navigator.pushNamed(context, '/parentModeLogin');
  //         }
  //       } else if (value == 'logOut') {
  //         signOut(context);
  //       } else if (value == 'createAccount') {
  //         // Add a functionality that lets the user create an account and sign in when they choose to
  //       } else if (value == 'signIn') {
  //         // Add a functionality that lets the user sign in when they choose to
  //       }
  //     },
  //   );
  // }

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

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      snap: false,
      pinned: false,
      floating: false,
      centerTitle: true,
      title: Text(
        "Let's play!",
        style: Theme.of(context).textTheme.titleLarge,
      ),
      toolbarHeight: 80,
      backgroundColor: Colors.transparent,
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

// class CustomHeaderDelegate extends SliverPersistentHeaderDelegate {
//   @override
//   Widget build(
//       BuildContext context, double shrinkOffset, bool overlapsContent) {
//     final progress = shrinkOffset / maxExtent;
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         AnimatedContainer(
//           duration: const Duration(milliseconds: 100),
//           padding: EdgeInsets.lerp(
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//             const EdgeInsets.only(bottom: 16),
//             progress,
//           ),
//           alignment: Alignment.bottomCenter,
//           child: Text(
//             "Let's play!",
//             style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   double get maxExtent => 100;

//   @override
//   double get minExtent => 0;

//   @override
//   bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
//       true;
// }
