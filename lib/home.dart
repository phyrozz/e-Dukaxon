import 'package:e_dukaxon/highlightReading.dart';
import 'package:flutter/material.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("eDukaxon"),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[900],
        actions: [
          Theme(
            data: ThemeData(
              canvasColor: Colors.grey[900],
            ),
            child: PopupMenuButton(
              icon: const IconTheme(
                data: IconThemeData(color: Colors.white),
                child: Icon(Icons.person),
              ),
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'Log Out',
                  child: Text('Log Out'),
                ),
              ],
              onSelected: (value) {
                if (value == 'Log Out') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              },
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HighlightReading(
                            text:
                                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam malesuada posuere mauris, ac lobortis orci posuere nec. Aenean vel commodo nisl, non placerat turpis. Vestibulum tincidunt, augue in efficitur placerat, diam nunc tempus odio, id hendrerit nulla nibh at felis. Suspendisse volutpat, eros ac gravida imperdiet, enim massa bibendum orci, ac eleifend erat erat et nibh. Etiam sed purus et urna viverra consectetur. Nullam malesuada mollis efficitur. Praesent tempus, orci quis fringilla luctus, est est imperdiet est, sit amet sodales lacus nulla ut ante. Aenean vitae eros ex. Donec et rhoncus turpis, in dapibus augue. Aliquam ullamcorper ut massa vitae tempor. Suspendisse in justo commodo, tincidunt purus et, viverra neque. Maecenas ut semper massa, feugiat gravida est. Vestibulum tincidunt suscipit dui eget tempus.',
                          )),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(14.0),
                child: Text('Highlight Reading'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
