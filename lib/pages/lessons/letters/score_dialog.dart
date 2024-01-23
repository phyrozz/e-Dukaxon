import 'package:flutter/material.dart';

class ScoreDialogPopUp extends StatefulWidget {
  final int score;
  final int scoreAdd;
  final int streakMultiplier;
  final int newScore;

  const ScoreDialogPopUp({
    Key? key,
    required this.score,
    required this.scoreAdd,
    required this.streakMultiplier,
    required this.newScore,
  }) : super(key: key);

  @override
  State<ScoreDialogPopUp> createState() => _ScoreDialogPopUpState();
}

class _ScoreDialogPopUpState extends State<ScoreDialogPopUp>
    with TickerProviderStateMixin {
  late AnimationController scoreController;
  late Animation<double> scoreAnimation;

  late AnimationController scoreAddController;
  late Animation<double> scoreAddAnimation;

  late AnimationController multiplierController;
  late Animation<double> multiplierAnimation;

  late AnimationController newScoreController;
  late Animation<double> newScoreAnimation;

  @override
  void initState() {
    super.initState();

    // Score Animation
    scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    scoreAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(scoreController);

    scoreController.forward();

    // ScoreAdd Animation
    scoreAddController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    scoreAddAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(scoreAddController);

    // Multiplier Animation
    multiplierController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    multiplierAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(multiplierController);

    // New score Animation
    newScoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    newScoreAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(newScoreController);

    Future.delayed(const Duration(milliseconds: 1000), () {
      scoreAddController.forward();
    });

    Future.delayed(const Duration(milliseconds: 2000), () {
      multiplierController.forward();
    });

    Future.delayed(const Duration(milliseconds: 3000), () {
      newScoreController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Display initial score
                AnimatedOpacity(
                  opacity: scoreAnimation.value,
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    "${widget.score}",
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                // Display addition with plus symbol
                AnimatedOpacity(
                  opacity: scoreAddAnimation.value,
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    "+${widget.scoreAdd}",
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                // Display multiplier with x symbol
                AnimatedOpacity(
                  opacity: multiplierAnimation.value,
                  duration: const Duration(milliseconds: 500),
                  child: Positioned(
                    top: 30,
                    child: Text(
                      "x${widget.streakMultiplier == 0 ? 1 : widget.streakMultiplier}",
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                // Display new score
                AnimatedOpacity(
                  opacity: newScoreAnimation.value,
                  duration: const Duration(milliseconds: 500),
                  child: Positioned(
                    top: 30,
                    child: Text(
                      "x${widget.newScore}",
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    scoreController.dispose();
    scoreAddController.dispose();
    multiplierController.dispose();
    newScoreController.dispose();
    super.dispose();
  }
}
