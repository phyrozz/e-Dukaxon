import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_dukaxon/auth.dart';
// import 'package:e_dukaxon/my_pages.dart';
import 'package:e_dukaxon/pages/loading.dart';
import 'package:flutter/material.dart';
import 'pages/child_home.dart';

class HomePageTree extends StatefulWidget {
  const HomePageTree({super.key});

  @override
  State<HomePageTree> createState() => _HomePageTreeState();
}

class _HomePageTreeState extends State<HomePageTree> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
      child: StreamBuilder<DocumentSnapshot>(
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
            return const Center(child: Text('Error fetching data'));
          } else {
            // Data available
            return const ChildHomePage();
            // final isParent = snapshot.data?.get('isParent') ?? false;
            // if (isParent) {
            //   return const ChildHomePage();
            // } else {
            //   return const MyPages();
            // }
          }
        },
      ),
    );
  }
}
