import 'package:e_dukaxon/assessment_data.dart';
import 'package:e_dukaxon/pages/child_home.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'pages/my_account.dart';
import 'pages/games.dart';
import 'pages/my_progress.dart';

class MyPages extends StatefulWidget {
  const MyPages({super.key});

  @override
  State<MyPages> createState() => _MyPagesState();
}

class _MyPagesState extends State<MyPages> with TickerProviderStateMixin {
  // int _currentIndex = 0;
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
      title: "Games",
      onTap: (index, _) {
        sideMenu.changePage(index);
      },
      icon: const Icon(Icons.games),
    ),
    SideMenuItem(
      title: "Stats",
      onTap: (index, _) {
        sideMenu.changePage(index);
      },
      icon: const Icon(Icons.show_chart),
    ),
    SideMenuItem(
      title: "My Account",
      onTap: (index, _) {
        sideMenu.changePage(index);
      },
      icon: const Icon(Icons.account_circle),
    ),
  ];

  final List<Widget> pages = [
    const ChildHomePage(),
    const GamesPage(),
    const MyProgressPage(),
    const MyAccountPage(),
  ];

  @override
  void initState() {
    super.initState();
    // Connect SideMenuController and PageController together
    sideMenu.addListener((index) {
      pageController.jumpToPage(index);
    });
    isParent = true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  // void _onTabSelected(int index) {
  //   setState(() {
  //     _currentIndex = index;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SideMenu(
            style: SideMenuStyle(
              displayMode: SideMenuDisplayMode.auto,
              hoverColor: Colors.black,
              selectedColor: Theme.of(context).primaryColor,
              selectedTitleTextStyle:
                  TextStyle(color: Theme.of(context).primaryColorDark),
              selectedIconColor: Theme.of(context).primaryColorDark,
              unselectedIconColor: Colors.white,
              unselectedTitleTextStyle: const TextStyle(color: Colors.white),
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
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
                    width: 32,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  const Text(
                    'eDukaxon',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            // Notify when display mode changed
            onDisplayModeChanged: (mode) {
              print(mode);
            },
            // List of SideMenuItem to show them on SideMenu
            items: items,
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

    // @override
    // Widget build(BuildContext context) {
    //   return Scaffold(
    //     body: _pages[_currentIndex],
    //     // floatingActionButton: FloatingActionButton(
    //     //   onPressed: () {

    //     //   },
    //     //   child: const Icon(
    //     //     Icons.play_arrow,
    //     //     size: 36.0,
    //     //   ),
    //     // ),
    //     // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    //     bottomNavigationBar: BottomAppBar(
    //       height: 50.0,
    //       shape: const CircularNotchedRectangle(),
    //       child: Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceAround,
    //         children: [
    //           IconButton(
    //             onPressed: () {
    //               _onTabSelected(0);
    //             },
    //             icon: const Icon(Icons.home),
    //             color: _currentIndex == 0 ? Colors.white : Colors.grey,
    //           ),
    //           IconButton(
    //             onPressed: () {
    //               _onTabSelected(1);
    //             },
    //             icon: const Icon(Icons.games),
    //             color: _currentIndex == 1 ? Colors.white : Colors.grey,
    //           ),
    //           // const SizedBox(
    //           //     width: 48.0), // Empty space for the FloatingActionButton
    //           IconButton(
    //             onPressed: () {
    //               _onTabSelected(2);
    //             },
    //             icon: const Icon(Icons.show_chart),
    //             color: _currentIndex == 2 ? Colors.white : Colors.grey,
    //           ),
    //           IconButton(
    //             onPressed: () {
    //               _onTabSelected(3);
    //             },
    //             icon: const Icon(Icons.account_circle),
    //             color: _currentIndex == 3 ? Colors.white : Colors.grey,
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // }
  }
}
