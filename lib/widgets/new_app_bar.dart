import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/pages/loading.dart';
import 'package:e_dukaxon/pages/login.dart';
import 'package:e_dukaxon/pages/parent_mode_login.dart';
import 'package:e_dukaxon/pages/settings.dart';
import 'package:e_dukaxon/pages/sign_up.dart';
import 'package:e_dukaxon/pages/tutorial.dart';
import 'package:e_dukaxon/route_anims/horizontal_slide.dart';
import 'package:e_dukaxon/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeCustomAppBar extends StatefulWidget {
  final String text;
  final bool isParentMode;

  const WelcomeCustomAppBar(
      {super.key, required this.text, required this.isParentMode});

  @override
  State<WelcomeCustomAppBar> createState() => _WelcomeCustomAppBarState();
}

class _WelcomeCustomAppBarState extends State<WelcomeCustomAppBar> {
  bool isLoggedIn = false;
  bool isLoading = true;
  bool isParentMode = true;
  bool isDarkMode = false;

  @override
  void initState() {
    getUserAccountData()
        .then((_) => getParentModePreferences())
        .then((_) => getColorScheme());
    super.initState();
  }

  Future<void> setParentModePreferences(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isParentMode', value);
  }

  Future<void> getParentModePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? value = prefs.getBool('isParentMode');

    if (value != null) {
      setState(() {
        if (value) {
          isParentMode = true;
        } else {
          isParentMode = false;
        }
      });
    }
  }

  Future<void> getColorScheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString('colorScheme');

    if (mounted) {
      setState(() {
        if (value == "Black") {
          isDarkMode = true;
        } else {
          isDarkMode = false;
        }
      });
    }
  }

  Future<void> getUserAccountData() async {
    String? id = Auth().getCurrentUserId();
    if (id != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('users').doc(id).get();
      final data = snapshot.data();

      if (mounted) {
        setState(() {
          if (data != null && data.containsKey('email')) {
            isLoggedIn = true;
          }
          isLoading = false;
        });
      }
    } else {
      print("User ID is null or empty.");
      isLoading = false;
    }
  }

  Widget helpButton(BuildContext context) {
    return IconButton(
        onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const TutorialPage(),
              ),
            ),
        icon: Icon(
          Icons.help_rounded,
          size: 40,
          color: isDarkMode
              ? Theme.of(context).secondaryHeaderColor
              : Theme.of(context).focusColor,
        ));
  }

  Widget menuButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: IconButton(
        onPressed: () {
          if (widget.isParentMode) {
            showMenuDialog(context);
          } else {
            Navigator.push(context,
                createRouteWithHorizontalSlideAnimation(const PinAccessPage()));
          }
        },
        icon: Icon(
          isParentMode ? Icons.settings : Icons.admin_panel_settings_rounded,
          size: 40,
          color: isDarkMode
              ? Theme.of(context).secondaryHeaderColor
              : Theme.of(context).focusColor,
        ),
      ),
    );
  }

  Future<void> showMenuDialog(BuildContext context) async {
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
                        onPressed: () async {
                          if (widget.isParentMode) {
                            setParentModePreferences(false).then((value) =>
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    createRouteWithHorizontalSlideAnimation(
                                        const WidgetTree()),
                                    (route) => false));
                          } else {
                            Navigator.pushReplacement(
                                context,
                                createRouteWithHorizontalSlideAnimation(
                                    const PinAccessPage()));
                          }
                        },
                        icon: widget.isParentMode
                            ? const Icon(Icons.exit_to_app_rounded)
                            : const Icon(FontAwesomeIcons.userTie),
                        label: widget.isParentMode
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
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      const LoginPage(),
                                ),
                              );
                            },
                            icon: const Icon(
                                FontAwesomeIcons.arrowRightToBracket),
                            label: const Text(
                              'Log in',
                              style: TextStyle(fontSize: 16),
                            )),
                    isLoggedIn
                        ? Container()
                        : const SizedBox(
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
          child: helpButton(context),
        ),
        Theme(
          data: ThemeData(
            canvasColor: Colors.grey[900],
          ),
          child: menuButton(context),
        ),
      ],
    );
  }
}
