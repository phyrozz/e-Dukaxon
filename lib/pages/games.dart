import 'package:e_dukaxon/pages/games/letter_guess.dart';
import 'package:e_dukaxon/pages/games/sound_quiz.dart';
import 'package:e_dukaxon/pages/games/trace_letter.dart';
import 'package:e_dukaxon/pages/loading.dart';
import 'package:e_dukaxon/widgets/new_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  bool isEnglish = true;
  bool isParentMode = false;
  bool isLoading = true;

  @override
  void initState() {
    getLanguage().then((_) => getParentModeValue());
    super.initState();
  }

  Future<void> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnglish = prefs.getBool('isEnglish') ?? true; // Default to English.

    if (mounted) {
      setState(() {
        this.isEnglish = isEnglish;
      });
    }
  }

  Future<void> getParentModeValue() async {
    final prefs = await SharedPreferences.getInstance();
    final prefValue = prefs.getBool('isParentMode');

    if (mounted) {
      setState(() {
        isParentMode = prefValue!;
        isLoading = false;
      });
    }
  }

  final List<Button> gameButtons = [
    const Button(
      title: 'Sound Quiz',
      iconImageUrl: 'assets/images/sound_quiz_icon.png',
      routePage: SoundQuizPage(),
    ),
    const Button(
      title: 'Letter Tracing',
      iconImageUrl: 'assets/images/letter_tracing_icon.png',
      routePage: LetterTracingPage(),
    ),
    const Button(
      title: 'Guess the Letter',
      iconImageUrl: 'assets/images/letter_guess_icon.png',
      routePage: LetterGuessPage(),
    ),
    // Add more game buttons as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const LoadingPage()
          : CustomScrollView(
              slivers: [
                WelcomeCustomAppBar(
                    text: isEnglish ? "Games" : "Mga Laro",
                    isParentMode: isParentMode),
                SliverList(delegate: SliverChildListDelegate(gameButtons)),
              ],
            ),
    );
  }
}

class Button extends StatefulWidget {
  final String title;
  final String iconImageUrl;
  final Widget routePage;

  const Button({
    super.key,
    required this.title,
    required this.iconImageUrl,
    required this.routePage,
  });

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  double containerOpacity = 0.0;
  Alignment headerPosition = Alignment.topLeft;
  Alignment containerPosition = Alignment.topLeft;

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 300))
        .then((value) => setState(() {
              headerPosition = Alignment.centerLeft;
              containerPosition = Alignment.centerLeft;
              containerOpacity = 1.0;
            }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => widget.routePage)),
        child: AnimatedOpacity(
          opacity: containerOpacity,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Row(
                children: [
                  AnimatedAlign(
                    alignment: containerPosition,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOutCubic,
                    child: AnimatedOpacity(
                      opacity: containerOpacity,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOutCubic,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Container(
                          width: 60.0,
                          height: 60.0,
                          child: Image.asset(widget.iconImageUrl),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      widget.title,
                      style:
                          const TextStyle(fontSize: 18.0, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
