import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemes {
  static ThemeData get defaultTheme {
    return ThemeData(
      primaryColor: const Color.fromARGB(255, 255, 251, 238),
      primaryColorDark: const Color(0xFF3F2305),
      primaryColorLight: const Color(0xFFDFD7BF),
      focusColor: const Color.fromARGB(255, 34, 19, 3),
      // backgroundColor: Colors.grey[900],
      scaffoldBackgroundColor: const Color.fromARGB(255, 255, 251, 238),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF3F2305),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            color: Colors.white,
          ),
          shadowColor: const Color.fromARGB(255, 34, 19, 3),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        prefixIconColor: Color(0xFF3F2305),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF3F2305)),
        ),
        labelStyle: TextStyle(color: Color(0xFF3F2305)),
        filled: true,
        fillColor: Color.fromARGB(255, 255, 251, 238),
        hintStyle: TextStyle(color: Color(0xFF3F2305)),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.black,
      ),
      dialogTheme: const DialogTheme(
        backgroundColor: Color.fromARGB(255, 255, 251, 238),
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: Color(0xFF3F2305)),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF3F2305)),
      bottomAppBarTheme: const BottomAppBarTheme(color: Color(0xFF3F2305)),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
          foregroundColor: Colors.white, backgroundColor: Color(0xFF3F2305)),
      cardTheme: const CardTheme(
        color: Color(0xFF3F2305),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          overlayColor: const MaterialStatePropertyAll(Color(0xFF3F2305)),
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.white;
            }
            return const Color(0xFF3F2305);
          }),
        ),
      ),
    );
  }

  static ThemeData get blueTheme {
    return ThemeData(
      primaryColor: const Color.fromARGB(255, 233, 245, 255),
      primaryColorDark: const Color.fromARGB(255, 8, 71, 180),
      primaryColorLight: const Color.fromARGB(255, 183, 223, 255),
      // backgroundColor: Colors.grey[900],
      scaffoldBackgroundColor: const Color.fromARGB(255, 233, 245, 255),
      focusColor: const Color.fromARGB(255, 7, 52, 131),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color.fromARGB(255, 8, 71, 180),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            color: Colors.white,
          ),
          shadowColor: const Color.fromARGB(255, 7, 52, 131),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        prefixIconColor: Color.fromARGB(255, 8, 71, 180),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 8, 71, 180)),
        ),
        labelStyle: TextStyle(color: Color.fromARGB(255, 8, 71, 180)),
        filled: true,
        fillColor: Color.fromARGB(255, 233, 245, 255),
        hintStyle: TextStyle(color: Color.fromARGB(255, 8, 71, 180)),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.black,
      ),
      dialogTheme: const DialogTheme(
        backgroundColor: Color.fromARGB(255, 233, 245, 255),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color.fromARGB(255, 8, 71, 180)),
      appBarTheme:
          const AppBarTheme(backgroundColor: Color.fromARGB(255, 8, 71, 180)),
      bottomAppBarTheme:
          const BottomAppBarTheme(color: Color.fromARGB(255, 8, 71, 180)),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
          foregroundColor: Colors.white,
          backgroundColor: Color.fromARGB(255, 8, 71, 180)),
      cardTheme: const CardTheme(
        color: Color.fromARGB(255, 8, 71, 180),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          overlayColor:
              const MaterialStatePropertyAll(Color.fromARGB(255, 8, 71, 180)),
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.white;
            }
            return const Color.fromARGB(255, 8, 71, 180);
          }),
        ),
      ),
    );
  }

  static ThemeData get purpleTheme {
    return ThemeData(
      primaryColor: const Color.fromARGB(255, 253, 244, 255),
      primaryColorDark: const Color.fromARGB(255, 87, 23, 99),
      primaryColorLight: const Color.fromARGB(255, 248, 207, 255),
      // backgroundColor: Colors.grey[900],
      scaffoldBackgroundColor: const Color.fromARGB(255, 253, 244, 255),
      focusColor: const Color.fromARGB(255, 57, 15, 65),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color.fromARGB(255, 87, 23, 99),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          shadowColor: const Color.fromARGB(255, 57, 15, 65),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        prefixIconColor: Color.fromARGB(255, 87, 23, 99),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 87, 23, 99)),
        ),
        labelStyle: TextStyle(color: Color.fromARGB(255, 87, 23, 99)),
        filled: true,
        fillColor: Color.fromARGB(255, 253, 244, 255),
        hintStyle: TextStyle(color: Color.fromARGB(255, 87, 23, 99)),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.black,
      ),
      dialogTheme: const DialogTheme(
        backgroundColor: Color.fromARGB(255, 253, 244, 255),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color.fromARGB(255, 87, 23, 99)),
      appBarTheme:
          const AppBarTheme(backgroundColor: Color.fromARGB(255, 87, 23, 99)),
      bottomAppBarTheme:
          const BottomAppBarTheme(color: Color.fromARGB(255, 87, 23, 99)),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
          foregroundColor: Colors.white,
          backgroundColor: Color.fromARGB(255, 87, 23, 99)),
      cardTheme: const CardTheme(
        color: Color.fromARGB(255, 87, 23, 99),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          overlayColor:
              const MaterialStatePropertyAll(Color.fromARGB(255, 87, 23, 99)),
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.white;
            }
            return const Color.fromARGB(255, 87, 23, 99);
          }),
        ),
      ),
    );
  }

  static ThemeData get cyanTheme {
    return ThemeData(
      primaryColor: const Color.fromARGB(255, 231, 253, 255),
      primaryColorDark: const Color.fromARGB(255, 14, 137, 153),
      primaryColorLight: const Color.fromARGB(255, 148, 211, 219),
      // backgroundColor: Colors.grey[900],
      scaffoldBackgroundColor: const Color.fromARGB(255, 231, 253, 255),
      focusColor: const Color.fromARGB(255, 10, 93, 104),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color.fromARGB(255, 14, 137, 153),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            color: Colors.white,
          ),
          shadowColor: const Color.fromARGB(255, 10, 93, 104),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        prefixIconColor: Color.fromARGB(255, 14, 137, 153),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 14, 137, 153)),
        ),
        labelStyle: TextStyle(color: Color.fromARGB(255, 14, 137, 153)),
        filled: true,
        fillColor: Color.fromARGB(255, 231, 253, 255),
        hintStyle: TextStyle(color: Color.fromARGB(255, 14, 137, 153)),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.black,
      ),
      dialogTheme: const DialogTheme(
        backgroundColor: Color.fromARGB(255, 231, 253, 255),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color.fromARGB(255, 14, 137, 153)),
      appBarTheme:
          const AppBarTheme(backgroundColor: Color.fromARGB(255, 14, 137, 153)),
      bottomAppBarTheme:
          const BottomAppBarTheme(color: Color.fromARGB(255, 14, 137, 153)),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
          foregroundColor: Colors.white,
          backgroundColor: Color.fromARGB(255, 14, 137, 153)),
      cardTheme: const CardTheme(
        color: Color.fromARGB(255, 14, 137, 153),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          overlayColor:
              const MaterialStatePropertyAll(Color.fromARGB(255, 14, 137, 153)),
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.white;
            }
            return const Color.fromARGB(255, 14, 137, 153);
          }),
        ),
      ),
    );
  }

  static ThemeData get blackTheme {
    return ThemeData(
      primaryColor: Colors.grey.shade800,
      primaryColorDark: Colors.grey.shade900,
      primaryColorLight: Colors.grey.shade700,
      // backgroundColor: Colors.grey[900],
      scaffoldBackgroundColor: const Color.fromARGB(255, 19, 19, 19),
      focusColor: Colors.black,
      secondaryHeaderColor: Colors.white,

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            color: Colors.white,
          ),
          shadowColor: Colors.black,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        prefixIconColor: Colors.black,
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        labelStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.grey.shade900,
        hintStyle: const TextStyle(color: Colors.black),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.black,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: Colors.grey.shade900,
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: Colors.black),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
      bottomAppBarTheme: const BottomAppBarTheme(color: Colors.black),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
          foregroundColor: Colors.white, backgroundColor: Colors.black),
      cardTheme: const CardTheme(
        color: Colors.black,
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
            overlayColor: MaterialStatePropertyAll(Colors.grey.shade900),
            foregroundColor: const MaterialStatePropertyAll(Colors.white)),
      ),
    );
  }

  static ThemeData get whiteTheme {
    return ThemeData(
      primaryColor: Colors.white,
      primaryColorDark: Colors.grey,
      primaryColorLight: Colors.grey.shade200,
      // backgroundColor: Colors.grey[900],
      scaffoldBackgroundColor: Colors.white,

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            textStyle: const TextStyle(
              color: Colors.black,
            ),
            shadowColor: Colors.grey),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        prefixIconColor: Colors.grey,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        labelStyle: TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(color: Colors.grey),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.black,
      ),
      dialogTheme: const DialogTheme(
        backgroundColor: Colors.white,
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: Colors.grey),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.grey),
      bottomAppBarTheme: const BottomAppBarTheme(color: Colors.grey),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
          foregroundColor: Colors.black, backgroundColor: Colors.grey),
      cardTheme: const CardTheme(
        color: Colors.grey,
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          overlayColor: const MaterialStatePropertyAll(Colors.grey),
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.white;
            }
            return Colors.grey;
          }),
        ),
      ),
    );
  }
}

// Provider for the color scheme theme setting on the Settings page
class ColorSchemeProvider extends ChangeNotifier {
  late String _selectedColor = "Default";
  late String _selectedBgImage = "assets/images/bg_brown.png";

  ColorSchemeProvider() {
    // Initialize with the default color scheme or the one from SharedPreferences
    _loadSelectedColor();
  }

  Future<void> _loadSelectedColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _selectedColor = prefs.getString('colorScheme') ?? 'Default';
    // Notify listeners to update widgets using this provider
    notifyListeners();
  }

  String get selectedColor => _selectedColor;
  String get selectedBgImage => _selectedBgImage;

  set selectedColor(String color) {
    _selectedColor = color;
    // Save to SharedPreferences
    _saveSelectedColor();
    // Notify listeners to update widgets using this provider
    notifyListeners();
  }

  set selectedBgImage(String bgImage) {
    _selectedBgImage = bgImage;
    notifyListeners();
  }

  Future<void> _saveSelectedColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('colorScheme', _selectedColor);
  }
}

// Provider for the Text Size settings on the Settings page
class TextSizeProvider extends ChangeNotifier {
  double _textSize = 16.0; // Default text size

  double get textSize => _textSize;

  set textSize(double size) {
    _textSize = size;
    notifyListeners();
  }
}
