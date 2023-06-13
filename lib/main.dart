import 'package:e_dukaxon/my_pages.dart';
import 'package:e_dukaxon/pages/assessment_questions/age.dart';
import 'package:e_dukaxon/pages/assessment_questions/init.dart';
import 'package:e_dukaxon/pages/assessment_questions/parent_or_not.dart';
import 'package:e_dukaxon/pages/assessment_questions/question_1.dart';
import 'package:e_dukaxon/pages/assessment_questions/question_2.dart';
import 'package:e_dukaxon/pages/assessment_questions/question_3.dart';
import 'package:e_dukaxon/pages/assessment_questions/question_4.dart';
import 'package:e_dukaxon/pages/assessment_questions/question_5.dart';
import 'package:e_dukaxon/pages/assessment_questions/question_6.dart';
import 'package:e_dukaxon/pages/assessment_questions/question_7.dart';
import 'package:e_dukaxon/pages/child_home.dart';
import 'package:e_dukaxon/pages/highlight_reading.dart';
import 'package:e_dukaxon/pages/home.dart';
import 'package:e_dukaxon/pages/login.dart';
import 'package:e_dukaxon/pages/parent_mode_login.dart';
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
      title: 'eDukaxon',
      theme: ThemeData(
        primaryColor: Colors.grey[900],
        // backgroundColor: Colors.grey[900],
        scaffoldBackgroundColor: Colors.black,
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
            primary: Colors.grey[800], // sets the background color
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
          backgroundColor: Colors.grey[900],
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(color: Colors.white),
        appBarTheme: AppBarTheme(backgroundColor: Colors.black),
        bottomAppBarTheme: BottomAppBarTheme(color: Colors.grey[900]),
        floatingActionButtonTheme:
            FloatingActionButtonThemeData(backgroundColor: Colors.grey[900]),
        cardColor: Colors.grey[800],
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WidgetTree(),
        '/login': (context) => LoginPage(),
        '/myPages': (context) => MyPages(),
        '/childHomePage': (context) => ChildHomePage(),
        '/highlightReading': (context) => HighlightReading(text: "test"),
        '/assessment/init': (context) => InitAssessmentPage(),
        '/assessment/questionOne': (context) => BangorQuestionOne(),
        '/assessment/questionTwo': (context) => BangorQuestionTwo(),
        '/assessment/questionThree': (context) => BangorQuestionThree(),
        '/assessment/questionFour': (context) => BangorQuestionFour(),
        '/assessment/questionFive': (context) => BangorQuestionFive(),
        '/assessment/questionSix': (context) => BangorQuestionSix(),
        '/assessment/questionSeven': (context) => BangorQuestionSeven(),
        '/assessment/parentOrNot': (context) => ParentOrNotPage(),
        '/assessment/ageSelect': (context) => AgeSelectPage(),
        '/parentModeLogin': (context) => PinAccessPage(),
      },
    );
  }
}
