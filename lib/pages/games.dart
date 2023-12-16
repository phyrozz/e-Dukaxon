import 'package:e_dukaxon/pages/games/letter_guess.dart';
import 'package:e_dukaxon/pages/games/sound_quiz.dart';
import 'package:e_dukaxon/pages/games/story_building.dart';
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
    const Button(
      title: 'Story Building',
      iconImageUrl: 'assets/images/story_building_icon.png',
      routePage: StoryBuildingGame(),
    ),
    // Add more game buttons as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const LoadingPage()
          : Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: const AssetImage("assets/images/my_games_bg.png"),
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).scaffoldBackgroundColor.withOpacity(
                          0.5), // Adjust the opacity value as needed
                      BlendMode.srcOver,
                    ),
                    fit: BoxFit.contain,
                    alignment: Alignment.centerRight),
              ),
              child: CustomScrollView(
                slivers: [
                  WelcomeCustomAppBar(
                      text: isEnglish ? "Games" : "Mga Laro",
                      isParentMode: isParentMode),
                  // SliverList(delegate: SliverChildListDelegate(gameButtons)),
                  SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 250.0,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: 1.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return Button(
                          title: gameButtons[index].title,
                          iconImageUrl: gameButtons[index].iconImageUrl,
                          routePage: gameButtons[index].routePage,
                        );
                      },
                      childCount: gameButtons.length,
                    ),
                  ),
                ],
              ),
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
    Future.delayed(const Duration(milliseconds: 300)).then((value) {
      if (mounted) {
        setState(() {
          headerPosition = Alignment.centerLeft;
          containerPosition = Alignment.centerLeft;
          containerOpacity = 1.0;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
                AnimatedAlign(
                  alignment: containerPosition,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOutCubic,
                  child: AnimatedOpacity(
                    opacity: containerOpacity,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOutCubic,
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width / 10,
                        height: MediaQuery.of(context).size.width / 10,
                        child: Image.asset(widget.iconImageUrl),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.title,
                    style: const TextStyle(fontSize: 14.0, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
