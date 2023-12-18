import 'package:collapsible_sidebar/collapsible_sidebar.dart';
import 'package:e_dukaxon/pages/child_home.dart';
import 'package:e_dukaxon/pages/games.dart';
import 'package:e_dukaxon/pages/my_account.dart';
import 'package:e_dukaxon/pages/my_progress.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPages extends StatefulWidget {
  final bool isParentMode;

  const MyPages({Key? key, required this.isParentMode}) : super(key: key);

  @override
  State<MyPages> createState() => _MyPagesState();
}

class _MyPagesState extends State<MyPages> {
  late List<CollapsibleItem> items;
  late String currentPage;
  late PageController pageController;

  bool isEnglish = true;
  bool isDarkMode = false;

  Future<void> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnglish = prefs.getBool('isEnglish') ?? true;

    setState(() {
      this.isEnglish = isEnglish;
    });
  }

  Future<void> getColorScheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString('colorScheme');

    if (mounted) {
      setState(() {
        if (value == "Black") {
          isDarkMode = true;
        } else {
          isDarkMode = false;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getLanguage().then((_) => getColorScheme());
    pageController = PageController();
    items = _generateItems();
    currentPage = items.isNotEmpty ? items[0].text : '';
    pageController.addListener(_onPageChanged);
  }

  List<CollapsibleItem> _generateItems() {
    return [
      CollapsibleItem(
        text: 'Home',
        icon: Icons.home,
        onPressed: () => _updateCurrentPage('Home', 0),
        isSelected: true,
      ),
      CollapsibleItem(
        text: isEnglish ? 'Games' : 'Mga Laro',
        icon: Icons.games,
        onPressed: () => _updateCurrentPage('Games', 1),
      ),
      CollapsibleItem(
        text: isEnglish ? 'My Progress' : 'Aking Progress',
        icon: Icons.show_chart,
        onPressed: () => _updateCurrentPage('My Progress', 2),
      ),
      CollapsibleItem(
        text: isEnglish ? 'My Account' : 'Aking Account',
        icon: Icons.account_circle,
        onPressed: () => _updateCurrentPage('My Account', 3),
      ),
    ];
  }

  void _updateCurrentPage(String pageName, int pageIndex) {
    setState(() {
      currentPage = pageName;
      pageController.jumpToPage(pageIndex);
    });
  }

  void _onPageChanged() {
    int pageIndex = pageController.page?.round() ?? 0;
    if (pageIndex >= 0 && pageIndex < items.length) {
      setState(() {
        items.forEach((item) => item.isSelected = false);
        items[pageIndex].isSelected = true;
        currentPage = items[pageIndex].text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration:
            BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 90),
              child: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ChildHomePage(
                    isParentMode: widget.isParentMode,
                  ),
                  const GamesPage(),
                  const MyProgressPage(),
                  const MyAccountPage(),
                ],
              ),
            ),
            CollapsibleSidebar(
              items: items,
              title: 'Parent Mode',
              avatarImg: const AssetImage("assets/images/my_account_bg.png"),
              backgroundColor: Theme.of(context).primaryColorDark,
              unselectedIconColor: isDarkMode
                  ? Theme.of(context).secondaryHeaderColor
                  : Theme.of(context).primaryColor,
              selectedIconColor: isDarkMode
                  ? Theme.of(context).secondaryHeaderColor
                  : Theme.of(context).primaryColorLight,
              avatarBackgroundColor: Colors.transparent,
              unselectedTextColor: isDarkMode
                  ? Theme.of(context).secondaryHeaderColor
                  : Theme.of(context).primaryColor,
              selectedIconBox: Theme.of(context).focusColor,
              selectedTextColor: isDarkMode
                  ? Theme.of(context).secondaryHeaderColor
                  : Theme.of(context).primaryColorLight,
              titleStyle:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              sidebarBoxShadow: [
                BoxShadow(
                  color: Theme.of(context).focusColor,
                  blurRadius: 20,
                  spreadRadius: 0.01,
                  offset: const Offset(3, 3),
                ),
              ],
              collapseOnBodyTap: true,
              body: Container(),
            ),
          ],
        ),
      ),
    );
  }
}
