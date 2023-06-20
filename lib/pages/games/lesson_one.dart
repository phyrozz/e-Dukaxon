import 'package:e_dukaxon/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class LessonOne extends StatelessWidget {
  const LessonOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(isHomePage: false),
    );
  }
}