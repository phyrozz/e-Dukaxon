import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/my_pages.dart';
import 'package:e_dukaxon/pages/loading.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/child_home.dart';

class HomePageTree extends StatefulWidget {
  const HomePageTree({super.key});

  @override
  State<HomePageTree> createState() => _HomePageTreeState();
}

class _HomePageTreeState extends State<HomePageTree> {
  bool isParentMode = false;
  bool isLoading = true;

  Future<void> getParentModeValue() async {
    final prefs = await SharedPreferences.getInstance();
    final prefValue = prefs.getBool('isParentMode') ?? false;

    setState(() {
      isParentMode = prefValue;
      isLoading = false;
    });
  }

  @override
  void initState() {
    getParentModeValue();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const LoadingPage()
        : StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(Auth().getCurrentUserId())
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Loading state
                return const LoadingPage();
                // return const Scaffold(
                //   body: Center(
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.center,
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         CircularProgressIndicator(),
                //         SizedBox(
                //           height: 24,
                //         ),
                //         Text(
                //           'Loading...',
                //           style: TextStyle(fontSize: 24),
                //         ),
                //       ],
                //     ),
                //   ),
                // );
              } else if (snapshot.hasError) {
                // Error state
                return const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                        child: Text(
                      'Error fetching data. Please try again later.',
                      textAlign: TextAlign.center,
                    )),
                  ],
                );
              } else {
                // Data available
                // return const ChildHomePage();
                // final isParent = snapshot.data?.get('isParent') ?? false;
                if (!isParentMode) {
                  return ChildHomePage(isParentMode: isParentMode);
                } else {
                  return MyPages(isParentMode: isParentMode);
                }
              }
            },
          );
  }
}
