import 'package:e_dukaxon/pages/loading.dart';
import 'package:flutter/material.dart';

class SoundQuizPage extends StatefulWidget {
  const SoundQuizPage({super.key});

  @override
  State<SoundQuizPage> createState() => _SoundQuizPageState();
}

class _SoundQuizPageState extends State<SoundQuizPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LoadingPage(),
    );
  }
}
