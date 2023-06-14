import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_dukaxon/widgets/app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChildHomePage extends StatefulWidget {
  const ChildHomePage({super.key});

  @override
  State<ChildHomePage> createState() => _ChildHomePageState();
}

class _ChildHomePageState extends State<ChildHomePage> {
  @override
  void initState() {
    super.initState();
    checkNewAccountAndNavigate();
  }

  Future<void> checkNewAccountAndNavigate() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? currentUser = auth.currentUser;

    // Retrieve the user document from Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .get();

    // Check if it's a new account
    if (userDoc.exists && userDoc.data()?['isNewAccount'] == true) {
      // Show the assessment page
      Navigator.pushReplacementNamed(context, '/assessment/init');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(isHomePage: true),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
              pinned: true,
              delegate: SliverHeaderDelegate(
                minHeight: 50.0,
                maxHeight: 150.0,
                child: Container(),
              )),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      ListTile(
                        title: Text('Game #$index'),
                      ),
                    ]),
                  ),
                );
              },
              childCount: 10, // Replace with your actual item count
            ),
          ),
        ],
      ),
    );
  }
}

class SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  SliverHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Calculate the font size based on the shrink offset
    final double fontSize = 24.0 - shrinkOffset / 18;

    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: Text(
        'My Games',
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
