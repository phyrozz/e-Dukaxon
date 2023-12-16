// import 'package:e_dukaxon/pages/assessment_questions/age.dart';
// import 'package:e_dukaxon/pages/assessment_questions/locale_select.dart';
// import 'package:e_dukaxon/pages/assessment_questions/parent_or_not.dart';
// import 'package:e_dukaxon/pages/assessment_questions/question_1.dart';
// import 'package:e_dukaxon/pages/assessment_questions/question_2.dart';
// import 'package:e_dukaxon/pages/assessment_questions/question_3.dart';
// import 'package:e_dukaxon/pages/assessment_questions/question_4.dart';
// import 'package:e_dukaxon/pages/assessment_questions/question_5.dart';
// import 'package:e_dukaxon/pages/assessment_questions/question_6.dart';
// import 'package:e_dukaxon/pages/assessment_questions/question_7.dart';
// import 'package:e_dukaxon/pages/games/trace_letter.dart';
// import 'package:e_dukaxon/pages/highlight_reading.dart';
import 'package:e_dukaxon/pages/loading.dart';
// import 'package:e_dukaxon/pages/login.dart';
// import 'package:e_dukaxon/pages/parent_mode_login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'widget_tree.dart';
import 'package:flutter/services.dart';
import 'package:e_dukaxon/data/theme_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true, // Enable local cache
    // Other settings if needed
  );

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((value) => runApp(
            MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (context) => ColorSchemeProvider(),
                ),
                ChangeNotifierProvider(
                  create: (context) => TextSizeProvider(),
                ),
              ],
              child: const MyApp(),
            ),
          ));
  // runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        // Check the selected color scheme from SharedPreferences
        future: getColorScheme(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            // print('Snapshot data: ${snapshot.data}');
            // Set the color scheme based on the selected color
            final ThemeData theme = selectTheme(snapshot.data);

            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'eDukaxon',
              theme: theme,
              home: const WidgetTree(),
              // initialRoute: '/',
              // routes: {
              //   '/': (context) => const WidgetTree(),
              //   '/login': (context) => const LoginPage(),
              //   // '/myPages': (context) => const MyPages(),
              //   // '/childHomePage': (context) => const ChildHomePage(),
              //   '/highlightReading': (context) =>
              //       const HighlightReading(text: "test"),
              //   '/assessment/init': (context) => const LocaleSelectPage(),
              //   '/assessment/questionOne': (context) =>
              //       const BangorQuestionOne(),
              //   '/assessment/questionTwo': (context) =>
              //       const BangorQuestionTwo(),
              //   '/assessment/questionThree': (context) =>
              //       const BangorQuestionThree(),
              //   '/assessment/questionFour': (context) =>
              //       const BangorQuestionFour(),
              //   '/assessment/questionFive': (context) =>
              //       const BangorQuestionFive(),
              //   '/assessment/questionSix': (context) =>
              //       const BangorQuestionSix(),
              //   '/assessment/questionSeven': (context) =>
              //       const BangorQuestionSeven(),
              //   '/assessment/parentOrNot': (context) => const ParentOrNotPage(),
              //   '/assessment/ageSelect': (context) => const AgeSelectPage(),
              //   '/parentModeLogin': (context) => const PinAccessPage(),
              //   '/games/traceLetter': (context) => const LetterTracingPage(),
              // },
            );
          } else if (snapshot.hasError) {
            // print('An error has occured while loading the app.');
            return const MaterialApp(
              home: Scaffold(
                body: LoadingPage(),
              ),
            );
          } else {
            // print('Loading...');
            return const MaterialApp(
              home: Scaffold(
                body: LoadingPage(),
              ),
            );
          }
        });
  }

  ThemeData selectTheme(String? selectedColor) {
    final colorSchemeProvider = Provider.of<ColorSchemeProvider>(context);
    final textSizeProvider = Provider.of<TextSizeProvider>(context);
    selectedColor = colorSchemeProvider.selectedColor;

    double textSize = textSizeProvider.textSize;

    // TODO: This might look ugly but it works... for now. Will find a more code-efficient way to deal
    // with this text size provider mess
    switch (selectedColor) {
      case 'Blue':
        return AppThemes.blueTheme.copyWith(
          textTheme: AppThemes.blueTheme.textTheme.copyWith(
            displayLarge: const TextStyle(
                color: Colors.black, fontFamily: 'OpenDyslexic'),
            displaySmall: const TextStyle(
                color: Colors.black, fontFamily: 'OpenDyslexic'),
            displayMedium: const TextStyle(
                color: Colors.black, fontFamily: 'OpenDyslexic'),
            labelLarge: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 2),
            labelMedium: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 2),
            labelSmall: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 2),
            bodySmall: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize),
            bodyLarge: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 6),
            bodyMedium: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 8),
            titleLarge: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 18,
                fontWeight: FontWeight.bold),
            titleMedium: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 6,
                fontWeight: FontWeight.bold),
            titleSmall: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 2,
                fontWeight: FontWeight.bold),
          ),
        );
      case 'Purple':
        return AppThemes.purpleTheme.copyWith(
          textTheme: AppThemes.blueTheme.textTheme.copyWith(
            displayLarge: const TextStyle(
                color: Colors.black, fontFamily: 'OpenDyslexic'),
            displaySmall: const TextStyle(
                color: Colors.black, fontFamily: 'OpenDyslexic'),
            displayMedium: const TextStyle(
                color: Colors.black, fontFamily: 'OpenDyslexic'),
            labelLarge: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 2),
            labelMedium: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 2),
            labelSmall: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 2),
            bodySmall: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize),
            bodyLarge: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 6),
            bodyMedium: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 8),
            titleLarge: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 18,
                fontWeight: FontWeight.bold),
            titleMedium: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 6,
                fontWeight: FontWeight.bold),
            titleSmall: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 2,
                fontWeight: FontWeight.bold),
          ),
        );
      case 'Cyan':
        return AppThemes.cyanTheme.copyWith(
          textTheme: AppThemes.blueTheme.textTheme.copyWith(
            displayLarge: const TextStyle(
                color: Colors.black, fontFamily: 'OpenDyslexic'),
            displaySmall: const TextStyle(
                color: Colors.black, fontFamily: 'OpenDyslexic'),
            displayMedium: const TextStyle(
                color: Colors.black, fontFamily: 'OpenDyslexic'),
            labelLarge: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 2),
            labelMedium: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 2),
            labelSmall: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 2),
            bodySmall: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize),
            bodyLarge: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 6),
            bodyMedium: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 8),
            titleLarge: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 18,
                fontWeight: FontWeight.bold),
            titleMedium: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 6,
                fontWeight: FontWeight.bold),
            titleSmall: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 2,
                fontWeight: FontWeight.bold),
          ),
        );
      case 'Black':
        return AppThemes.blackTheme.copyWith(
          textTheme: AppThemes.blueTheme.textTheme.copyWith(
            displayLarge:
                TextStyle(color: Colors.white, fontFamily: 'OpenDyslexic'),
            displaySmall:
                TextStyle(color: Colors.white, fontFamily: 'OpenDyslexic'),
            displayMedium:
                TextStyle(color: Colors.white, fontFamily: 'OpenDyslexic'),
            labelLarge: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 2),
            labelMedium: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 2),
            labelSmall: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 2),
            bodySmall: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize),
            bodyLarge: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 6),
            bodyMedium: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 8),
            titleLarge: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 18,
                fontWeight: FontWeight.bold),
            titleMedium: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 6,
                fontWeight: FontWeight.bold),
            titleSmall: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 2,
                fontWeight: FontWeight.bold),
          ),
        );
      case 'White':
        return AppThemes.whiteTheme.copyWith(
          textTheme: AppThemes.blueTheme.textTheme.copyWith(
            displayLarge:
                TextStyle(color: Colors.black, fontFamily: 'OpenDyslexic'),
            displaySmall:
                TextStyle(color: Colors.black, fontFamily: 'OpenDyslexic'),
            displayMedium:
                TextStyle(color: Colors.black, fontFamily: 'OpenDyslexic'),
            labelLarge: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 2),
            labelMedium: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 2),
            labelSmall: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 2),
            bodySmall: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize),
            bodyLarge: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 6),
            bodyMedium: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 8),
            titleLarge: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 18,
                fontWeight: FontWeight.bold),
            titleMedium: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 6,
                fontWeight: FontWeight.bold),
            titleSmall: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 2,
                fontWeight: FontWeight.bold),
          ),
        );
      default:
        return AppThemes.defaultTheme.copyWith(
          textTheme: AppThemes.blueTheme.textTheme.copyWith(
            displayLarge: const TextStyle(
                color: Colors.black, fontFamily: 'OpenDyslexic'),
            displaySmall: const TextStyle(
                color: Colors.black, fontFamily: 'OpenDyslexic'),
            displayMedium: const TextStyle(
                color: Colors.black, fontFamily: 'OpenDyslexic'),
            labelLarge: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 2),
            labelMedium: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 2),
            labelSmall: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 2),
            bodySmall: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize),
            bodyLarge: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 6),
            bodyMedium: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 8),
            titleLarge: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 18,
                fontWeight: FontWeight.bold),
            titleMedium: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 6,
                fontWeight: FontWeight.bold),
            titleSmall: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenDyslexic',
                fontSize: textSize + 2,
                fontWeight: FontWeight.bold),
          ),
        );
    }
  }

  // Load the selected color scheme from SharedPreferences
  Future<String> getColorScheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // print('colorScheme\'s value: ${prefs.getString('colorScheme')}');
    return prefs.getString('colorScheme') ?? 'Default';
  }
}
