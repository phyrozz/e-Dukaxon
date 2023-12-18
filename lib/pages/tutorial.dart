import 'package:flutter/material.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  late int selectedPage;
  late PageController tutorialPages;
  String? errorMessage = '';
  bool isEnglish = true;

  @override
  void initState() {
    getLanguage();
    selectedPage = 0;
    tutorialPages = PageController(initialPage: selectedPage);
    super.initState();
  }

  Future<void> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnglish = prefs.getBool('isEnglish') ?? true;

    setState(() {
      this.isEnglish = isEnglish;
    });
  }

  @override
  void dispose() {
    tutorialPages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: PageView(
            controller: tutorialPages,
            onPageChanged: (page) {
              setState(() {
                selectedPage = page;
              });
            },
            children: [
              pageItem(
                  isEnglish
                      ? "Get started learning by tapping on your very first lesson!"
                      : "Magsimula sa pag-aaral sa pamamagitan ng pagpindot sa iyong unang aralin!",
                  "assets/images/tutorial_1.png"),
              pageItem(
                  isEnglish
                      ? "Read the lesson and answer the questions carefully."
                      : "Basahin ang aralin at sagutin ang mga tanong nang maingat.",
                  "assets/images/tutorial_2.png"),
              pageItem(
                  isEnglish
                      ? "The better your score is, the easier you can progress with the lesson."
                      : "Kapag mas mataas ang iyong marka, mas madali mong maipagpapatuloy ang aralin.",
                  "assets/images/tutorial_3.png"),
              pageItem(
                  isEnglish
                      ? "New lessons will unlock after you have progressed enough on previous ones."
                      : "Magu-unlock ang mga bagong aralin pagkatapos mong magtagumpay sa mga naunang aralin.",
                  "assets/images/tutorial_4.png"),
              pageItem(
                  isEnglish
                      ? "You can also access more features in the app by taping here."
                      : "Maaari mo ring ma-access ang iba't ibang mga feature sa app sa pamamagitan ng pagpindot nito.",
                  "assets/images/tutorial_5.png"),
              pageItem(
                  isEnglish
                      ? "Parent mode must only be accessed by your parent. Here, you can see your child's progress, try out different games, and manage your account."
                      : "Ang parent mode ay dapat lamang i-access ng iyong magulang. Dito, maaari nilang makita ang progreso ng iyong anak, subukan ang iba't ibang laro, at pamahalaan ang kanilang account.",
                  "assets/images/tutorial_6.png"),
              pageItem(
                  isEnglish
                      ? "You can access this tutorial any time by tapping this button here. Have fun!"
                      : "Maaari mong ma-access ang tutorial na ito anumang oras sa pamamagitan ng pagpindot dito. Enjoy!",
                  "assets/images/tutorial_7.png"),
            ],
          )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: PageViewDotIndicator(
              currentItem: selectedPage,
              count: 7,
              unselectedColor: Theme.of(context).primaryColorLight,
              selectedColor: Theme.of(context).primaryColorDark,
              duration: const Duration(milliseconds: 200),
              boxShape: BoxShape.circle,
              onItemClicked: (index) {
                tutorialPages.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
          const SizedBox(
            height: 16,
          ),
        ],
      ),
      floatingActionButton: Visibility(
        visible: selectedPage == 6,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pop(context);
          },
          label: Text(isEnglish ? 'Let\'s go!' : 'Tara na!'),
          icon: const Icon(Icons.check),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }

  Widget pageItem(String text, String imageUri) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 30, 12),
                child: Center(
                  child: FutureBuilder<void>(
                    // Use FutureBuilder to determine if the image is loaded or not
                    future: precacheImage(
                      AssetImage(imageUri),
                      context,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        // Image has loaded, show the Image widget
                        return Image.asset(
                          imageUri,
                          width: MediaQuery.of(context).size.width / 2,
                        );
                      } else {
                        // Image is still loading, show a circular progress indicator
                        return CircularProgressIndicator(
                          color: Theme.of(context).primaryColorDark,
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  height: 1.3,
                ),
              ),
            ],
          ),
          const SizedBox(),
        ],
      ),
    );
  }
}
