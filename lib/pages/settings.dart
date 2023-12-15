import 'package:e_dukaxon/data/theme_data.dart';
import 'package:e_dukaxon/homepage_tree.dart';
import 'package:e_dukaxon/widgets/back_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isEnglish = true;
  String selectedColorScheme = 'Default'; // Default color scheme

  @override
  void initState() {
    super.initState();
    loadLanguagePreference();
  }

  // Load the language preference from shared preferences
  Future<void> loadLanguagePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isEnglish = prefs.getBool('isEnglish') ?? true;
      selectedColorScheme = prefs.getString('colorScheme') ?? 'Default';
    });
  }

  Future<void> saveLanguagePreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isEnglish', value);
  }

  Future<void> saveColorScheme(String colorScheme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('colorScheme', colorScheme);
  }

  // Toggle the language and update the preference
  void toggleLanguage(bool newValue) {
    setState(() {
      isEnglish = newValue;
      saveLanguagePreference(isEnglish);
    });
  }

  // Handle color scheme selection
  void onColorSchemeSelected(String colorScheme) {
    final colorSchemeProvider =
        Provider.of<ColorSchemeProvider>(context, listen: false);
    colorSchemeProvider.selectedColor = colorScheme;

    setState(() {
      selectedColorScheme = colorScheme;
      saveColorScheme(selectedColorScheme);
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const HomePageTree(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
          text: isEnglish ? "Settings" : "Mga Setting"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isEnglish ? 'Language' : 'Wika'),
            Row(
              children: [
                Text(
                  'Filipino',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Switch(
                  value: isEnglish,
                  onChanged: toggleLanguage,
                  activeColor: Theme.of(context).primaryColorDark,
                  inactiveThumbColor: Theme.of(context).primaryColorDark,
                ),
                Text(
                  'English',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(isEnglish ? 'Color Scheme' : 'Kulay ng App'),
            Row(
              children: [
                ColorSchemeOption(
                  color: const Color(0xFF3F2305),
                  name: 'Default',
                  isSelected: selectedColorScheme == 'Default',
                  onSelected: onColorSchemeSelected,
                ),
                ColorSchemeOption(
                  color: const Color.fromARGB(255, 8, 71, 180),
                  name: 'Blue',
                  isSelected: selectedColorScheme == 'Blue',
                  onSelected: onColorSchemeSelected,
                ),
                ColorSchemeOption(
                  color: const Color.fromARGB(255, 87, 23, 99),
                  name: 'Purple',
                  isSelected: selectedColorScheme == 'Purple',
                  onSelected: onColorSchemeSelected,
                ),
                ColorSchemeOption(
                  color: const Color.fromARGB(255, 14, 137, 153),
                  name: 'Cyan',
                  isSelected: selectedColorScheme == 'Cyan',
                  onSelected: onColorSchemeSelected,
                ),
                ColorSchemeOption(
                  color: Colors.black,
                  name: 'Black',
                  isSelected: selectedColorScheme == 'Black',
                  onSelected: onColorSchemeSelected,
                ),
                ColorSchemeOption(
                  color: Colors.white,
                  name: 'White',
                  isSelected: selectedColorScheme == 'White',
                  onSelected: onColorSchemeSelected,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ColorSchemeOption extends StatelessWidget {
  final Color color;
  final String name;
  final bool isSelected;
  final Function(String) onSelected;

  const ColorSchemeOption({
    Key? key,
    required this.color,
    required this.name,
    required this.isSelected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelected(name),
      child: Container(
        width: 48,
        height: 48,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: color,
            border: Border.all(
                color: isSelected ? Colors.black : Colors.transparent,
                width: isSelected ? 5 : 0,
                strokeAlign: BorderSide.strokeAlignCenter),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.grey.shade600, blurRadius: 8),
            ]),
      ),
    );
  }
}
