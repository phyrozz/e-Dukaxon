import 'package:e_dukaxon/assessment_data.dart';
import 'package:e_dukaxon/pages/child_home.dart';
import 'package:e_dukaxon/pages/home.dart';
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
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ChildHomePage(),
    GamesPage(),
    MyProgressPage(),
    MyAccountPage(),
  ];

  @override
  void initState() {
    super.initState();
    isParent = true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle the play button action here
        },
        child: Icon(
          Icons.play_arrow,
          size: 36.0,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 50.0,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                _onTabSelected(0);
              },
              icon: Icon(Icons.home),
              color: _currentIndex == 0 ? Colors.white : Colors.grey,
            ),
            IconButton(
              onPressed: () {
                _onTabSelected(1);
              },
              icon: Icon(Icons.games),
              color: _currentIndex == 1 ? Colors.white : Colors.grey,
            ),
            SizedBox(width: 48.0), // Empty space for the FloatingActionButton
            IconButton(
              onPressed: () {
                _onTabSelected(2);
              },
              icon: Icon(Icons.show_chart),
              color: _currentIndex == 2 ? Colors.white : Colors.grey,
            ),
            IconButton(
              onPressed: () {
                _onTabSelected(3);
              },
              icon: Icon(Icons.account_circle),
              color: _currentIndex == 3 ? Colors.white : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
