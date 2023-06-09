import 'package:e_dukaxon/auth.dart';
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
import 'package:e_dukaxon/pages/games/trace_letter.dart';
import 'package:e_dukaxon/pages/highlight_reading.dart';
import 'package:e_dukaxon/pages/home.dart';
import 'package:e_dukaxon/pages/login.dart';
import 'package:e_dukaxon/pages/parent_mode_login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flame/flame.dart';
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
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
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
        primaryColor: const Color(0xFFF2EAD3),
        primaryColorDark: const Color(0xFF3F2305),
        // backgroundColor: Colors.grey[900],
        scaffoldBackgroundColor: const Color(0xFFF2EAD3),
        textTheme: const TextTheme(
          displayLarge:
              TextStyle(color: Colors.black, fontFamily: 'OpenDyslexic'),
          displaySmall:
              TextStyle(color: Colors.black, fontFamily: 'OpenDyslexic'),
          displayMedium:
              TextStyle(color: Colors.black, fontFamily: 'OpenDyslexic'),
          labelLarge: TextStyle(
              color: Colors.black, fontFamily: 'OpenDyslexic', fontSize: 16),
          labelMedium:
              TextStyle(color: Colors.black, fontFamily: 'OpenDyslexic'),
          labelSmall:
              TextStyle(color: Colors.black, fontFamily: 'OpenDyslexic'),
          bodySmall: TextStyle(color: Colors.black, fontFamily: 'OpenDyslexic'),
          bodyLarge: TextStyle(color: Colors.black, fontFamily: 'OpenDyslexic'),
          bodyMedium:
              TextStyle(color: Colors.black, fontFamily: 'OpenDyslexic'),
          titleLarge:
              TextStyle(color: Colors.black, fontFamily: 'OpenDyslexic'),
          titleMedium:
              TextStyle(color: Colors.black, fontFamily: 'OpenDyslexic'),
          titleSmall:
              TextStyle(color: Colors.black, fontFamily: 'OpenDyslexic'),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xFF3F2305),
            onPrimary: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          prefixIconColor: Color(0xFF3F2305),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF3F2305)),
          ),
          labelStyle: TextStyle(color: Color(0xFF3F2305)),
          filled: true,
          fillColor: Color(0xFFF5F5F5),
          hintStyle: TextStyle(color: Color(0xFF3F2305)),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.black,
        ),
        dialogTheme: const DialogTheme(
          backgroundColor: Color(0xFFDFD7BF),
        ),
        progressIndicatorTheme:
            const ProgressIndicatorThemeData(color: Color(0xFF3F2305)),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF3F2305)),
        bottomAppBarTheme: const BottomAppBarTheme(color: Color(0xFF3F2305)),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF3F2305)),
        cardColor: const Color(0xFF3F2305),
        listTileTheme: const ListTileThemeData(
          textColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WidgetTree(),
        '/login': (context) => const LoginPage(),
        '/myPages': (context) => const MyPages(),
        '/childHomePage': (context) => const ChildHomePage(),
        '/highlightReading': (context) => const HighlightReading(text: "test"),
        '/assessment/init': (context) => const InitAssessmentPage(),
        '/assessment/questionOne': (context) => const BangorQuestionOne(),
        '/assessment/questionTwo': (context) => const BangorQuestionTwo(),
        '/assessment/questionThree': (context) => const BangorQuestionThree(),
        '/assessment/questionFour': (context) => const BangorQuestionFour(),
        '/assessment/questionFive': (context) => const BangorQuestionFive(),
        '/assessment/questionSix': (context) => const BangorQuestionSix(),
        '/assessment/questionSeven': (context) => const BangorQuestionSeven(),
        '/assessment/parentOrNot': (context) => const ParentOrNotPage(),
        '/assessment/ageSelect': (context) => const AgeSelectPage(),
        '/parentModeLogin': (context) => const PinAccessPage(),
        '/games/traceLetter': (context) => const LetterTracingPage(),
      },
    );
  }
}
