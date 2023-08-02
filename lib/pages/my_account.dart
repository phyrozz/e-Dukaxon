import 'package:e_dukaxon/widgets/app_bar.dart';
import 'package:e_dukaxon/widgets/new_app_bar.dart';
import 'package:flutter/material.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [WelcomeCustomAppBar(text: "My Account")],
      ),
    );
  }
}
