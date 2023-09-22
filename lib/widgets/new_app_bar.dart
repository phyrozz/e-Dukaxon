import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_dukaxon/assessment_data.dart';
import 'package:e_dukaxon/auth.dart';
// import 'package:e_dukaxon/pages/child_home.dart';
import 'package:e_dukaxon/pages/loading.dart';
import 'package:e_dukaxon/pages/parent_mode_login.dart';
import 'package:e_dukaxon/pages/settings.dart';
import 'package:e_dukaxon/pages/sign_up.dart';
import 'package:e_dukaxon/route_anims/horizontal_slide.dart';
import 'package:e_dukaxon/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WelcomeCustomAppBar extends StatefulWidget {
  final String text;

  const WelcomeCustomAppBar({super.key, required this.text});

  @override
  State<WelcomeCustomAppBar> createState() => _WelcomeCustomAppBarState();
}

class _WelcomeCustomAppBarState extends State<WelcomeCustomAppBar> {
  bool isLoggedIn = false;
  bool isLoading = true;

  @override
  void initState() {
    getUserAccountData();
    super.initState();
  }

  Future<void> getUserAccountData() async {
    String? id = Auth().getCurrentUserId();
    if (id != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('users').doc(id).get();
      final data = snapshot.data();

      setState(() {
        if (data != null && data.containsKey('email')) {
          isLoggedIn = true;
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

  Widget _menuButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (isParent) {
          _showMenuDialog(context);
        } else {
          Navigator.push(context,
              createRouteWithHorizontalSlideAnimation(const PinAccessPage()));
        }
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
          content: isLoading
              ? const LoadingPage()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                        onPressed: () {
                          if (isParent) {
                            isParent = false;
                            Navigator.pushAndRemoveUntil(
                                context,
                                createRouteWithHorizontalSlideAnimation(
                                    const WidgetTree()),
                                (route) => false);
                          } else {
                            Navigator.pushReplacement(
                                context,
                                createRouteWithHorizontalSlideAnimation(
                                    const PinAccessPage()));
                          }
                        },
                        icon: isParent
                            ? const Icon(Icons.exit_to_app_rounded)
                            : const Icon(FontAwesomeIcons.userTie),
                        label: isParent
                            ? const Text(
                                'Exit Parent Mode',
                                style: TextStyle(fontSize: 16),
                              )
                            : const Text(
                                'Parent Mode',
                                style: TextStyle(fontSize: 16),
                              )),
                    const SizedBox(
                      height: 12,
                    ),
                    isLoggedIn
                        ? Container()
                        : ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            icon: const Icon(
                                FontAwesomeIcons.arrowRightToBracket),
                            label: const Text(
                              'Log in',
                              style: TextStyle(fontSize: 16),
                            )),
                    const SizedBox(
                      height: 12,
                    ),
                    ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const SignUpPage()));
                        },
                        icon: const Icon(FontAwesomeIcons.userPlus),
                        label: const Text(
                          'Create an account',
                          style: TextStyle(fontSize: 16),
                        )),
                    const SizedBox(
                      height: 12,
                    ),
                    ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const SettingsPage()));
                        },
                        icon: const Icon(FontAwesomeIcons.gear),
                        label: const Text(
                          'Settings',
                          style: TextStyle(fontSize: 16),
                        )),
                    // const SizedBox(
                    //   height: 12,
                    // ),
                    // ElevatedButton.icon(
                    //     onPressed: () => signOut(context),
                    //     icon: const Icon(Icons.logout),
                    //     label: const Text('Log out')),
                  ],
                ),
        );
      },
    );
  }

  // Widget _buildMenuItem(BuildContext context,
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
    return SliverAppBar(
      automaticallyImplyLeading: false,
      snap: false,
      pinned: false,
      floating: false,
      centerTitle: true,
      title: Text(
        widget.text,
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
