import 'package:e_dukaxon/widgets/app_bar.dart';
import 'package:e_dukaxon/widgets/new_app_bar.dart';
import 'package:flutter/material.dart';

class MyProgressPage extends StatefulWidget {
  const MyProgressPage({super.key});

  @override
  State<MyProgressPage> createState() => _MyProgressPageState();
}

class _MyProgressPageState extends State<MyProgressPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [WelcomeCustomAppBar(text: "Progress")],
      ),
    );
  }
}
