import 'package:e_dukaxon/pages/child_home.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/my_account.dart';
import 'pages/games.dart';
import 'pages/my_progress.dart';

class MyPages extends StatefulWidget {
  final bool isParentMode;

  const MyPages({Key? key, required this.isParentMode}) : super(key: key);

  @override
  State<MyPages> createState() => _MyPagesState();
}

class _MyPagesState extends State<MyPages> with TickerProviderStateMixin {
  // int _currentIndex = 0;
  bool isEnglish = true;
  PageController pageController = PageController();
  SideMenuController sideMenu = SideMenuController();

  late List<SideMenuItem> items = [
    SideMenuItem(
      title: "Home",
      onTap: (index, _) {
        sideMenu.changePage(index);
      },
      icon: const Icon(Icons.home),
    ),
    SideMenuItem(
      title: isEnglish ? "Games" : "Mga Laro",
      onTap: (index, _) {
        sideMenu.changePage(index);
      },
      icon: const Icon(Icons.games),
    ),
    SideMenuItem(
      title: "Progress",
      onTap: (index, _) {
        sideMenu.changePage(index);
      },
      icon: const Icon(Icons.show_chart),
    ),
    SideMenuItem(
      title: isEnglish ? "My Account" : "Aking Account",
      onTap: (index, _) {
        sideMenu.changePage(index);
      },
      icon: const Icon(Icons.account_circle),
    ),
  ];

  late List<Widget> pages = [
    ChildHomePage(
      isParentMode: widget.isParentMode,
    ),
    const GamesPage(),
    const MyProgressPage(),
    const MyAccountPage(),
  ];

  @override
  void initState() {
    setParentModePreferences(true)
        .then((_) => getLanguage())
        .then((_) => sideMenu.addListener((index) {
              pageController.jumpToPage(index);
            }));
    super.initState();
    // Connect SideMenuController and PageController together
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

  Future<void> setParentModePreferences(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isParentMode', value);
  }

  @override
  void dispose() {
    sideMenu.dispose();
    super.dispose();
  }

  // void _onTabSelected(int index) {
  //   setState(() {
  //     _currentIndex = index;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SideMenu(
            style: SideMenuStyle(
              hoverColor: Colors.black,
              selectedColor: Theme.of(context).primaryColor,
              selectedTitleTextStyle:
                  TextStyle(color: Theme.of(context).primaryColorDark),
              selectedIconColor: Theme.of(context).primaryColorDark,
              unselectedIconColor: Colors.white,
              unselectedTitleTextStyle: const TextStyle(color: Colors.white),
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8)),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 79, 117, 134),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: Offset(0, 0),
                    ),
                  ]),
              backgroundColor: Theme.of(context).primaryColorDark,
              openSideMenuWidth: 200,
            ),
            // Page controller to manage a PageView
            controller: sideMenu,
            // Will shows on top of all items, it can be a logo or a Title text
            title: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/app-logo.png',
                    width: 26,
                  ),
                  SizedBox(
                    height: orientation == Orientation.portrait ? 12 : 0,
                    width: orientation == Orientation.landscape ? 12 : 0,
                  ),
                  Text(
                    orientation == Orientation.portrait ? '' : 'eDukaxon',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            // List of SideMenuItem to show them on SideMenu
            items: items,
            footer: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Theme.of(context).primaryColor),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_open_rounded),
                      Text(
                        'Parent mode',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: PageView(
              controller: pageController,
              children: pages,
            ),
          ),
        ],
      ),
    );
  }
}
