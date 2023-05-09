import 'package:flutter/material.dart';
import 'login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.grey[800],
        backgroundColor: Colors.grey[800],
        scaffoldBackgroundColor: Colors.grey[800],
        textTheme: const TextTheme(
          displayLarge:
              TextStyle(color: Colors.white, fontFamily: 'OpenDyslexic'),
          displaySmall:
              TextStyle(color: Colors.white, fontFamily: 'OpenDyslexic'),
          displayMedium:
              TextStyle(color: Colors.white, fontFamily: 'OpenDyslexic'),
          labelLarge:
              TextStyle(color: Colors.white, fontFamily: 'OpenDyslexic'),
          labelMedium:
              TextStyle(color: Colors.white, fontFamily: 'OpenDyslexic'),
          labelSmall:
              TextStyle(color: Colors.white, fontFamily: 'OpenDyslexic'),
          bodySmall: TextStyle(color: Colors.white, fontFamily: 'OpenDyslexic'),
          bodyLarge: TextStyle(color: Colors.white, fontFamily: 'OpenDyslexic'),
          bodyMedium:
              TextStyle(color: Colors.white, fontFamily: 'OpenDyslexic'),
          titleLarge:
              TextStyle(color: Colors.white, fontFamily: 'OpenDyslexic'),
          titleMedium:
              TextStyle(color: Colors.white, fontFamily: 'OpenDyslexic'),
          titleSmall:
              TextStyle(color: Colors.white, fontFamily: 'OpenDyslexic'),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.grey[600], // sets the background color
            onPrimary: Colors.white, // sets the text color
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[300],
          hintStyle: TextStyle(color: Colors.grey[400]),
        ),
      ),
      home: const LoginPage(),
    );
  }
}
