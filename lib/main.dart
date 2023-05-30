import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'widget_tree.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true, // Enable local cache
    // Other settings if needed
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          prefixIconColor: Colors.black,
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          labelStyle: const TextStyle(color: Colors.black),
          filled: true,
          fillColor: Colors.grey[300],
          hintStyle: TextStyle(color: Colors.grey[400]),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.black,
        ),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.grey[800],
        ),
      ),
      home: const WidgetTree(),
    );
  }
}
