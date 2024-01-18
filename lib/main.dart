import 'package:e_dukaxon/pages/loading.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'widget_tree.dart';
import 'package:flutter/services.dart';
import 'package:e_dukaxon/data/theme_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Store the ElevenLabs API key for AI text to speech
String EL_API_KEY = dotenv.env['EL_API_KEY'] as String;

void main() async {
  await dotenv.load(fileName: ".env");

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
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        // Check the selected color scheme from SharedPreferences
        future: getColorScheme(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            final ThemeData theme = selectTheme(snapshot.data);

            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'eDukaxon',
              theme: theme,
              home: const WidgetTree(),
            );
          } else if (snapshot.hasError) {
            return const MaterialApp(
              home: Scaffold(
                body: LoadingPage(),
              ),
            );
          } else {
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
          textTheme: AppThemes.purpleTheme.textTheme.copyWith(
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
          textTheme: AppThemes.cyanTheme.textTheme.copyWith(
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
          textTheme: AppThemes.blackTheme.textTheme.copyWith(
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
          textTheme: AppThemes.whiteTheme.textTheme.copyWith(
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
          textTheme: AppThemes.defaultTheme.textTheme.copyWith(
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
    return prefs.getString('colorScheme') ?? 'Default';
  }
}
