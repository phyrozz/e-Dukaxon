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
  String themeName = "Nature Brown";
  double currentTextSize = 16.0;

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
      currentTextSize = prefs.getDouble('textSize') ?? 16.0;
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

  Future<void> saveTextSize(double size) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('textSize', size);
  }

  // Toggle the language and update the preference
  void toggleLanguage(bool newValue) {
    setState(() {
      isEnglish = newValue;
      saveLanguagePreference(isEnglish);
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const HomePageTree(),
      ),
    );
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

  // Handle color scheme selection
  void onTextSizeSliderChange(double textSize) {
    final textProvider = Provider.of<TextSizeProvider>(context, listen: false);
    textProvider.textSize = textSize;

    setState(() {
      currentTextSize = textSize;
      saveTextSize(currentTextSize);
    });

    saveTextSize(textSize);

    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute<void>(
    //     builder: (BuildContext context) => const HomePageTree(),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlowingOverscrollIndicator(
        color: Theme.of(context).primaryColorDark,
        axisDirection: AxisDirection.down,
        child: CustomScrollView(
          slivers: [
            CustomAppBarWithBackButton(
                text: isEnglish ? "Settings" : "Mga Setting"),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: ShapeDecoration(
                          color: Theme.of(context).primaryColorLight,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isEnglish ? "Language" : "Wika",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                  color: Theme.of(context).cardColor),
                              textAlign: TextAlign.right,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Filipino',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Switch(
                                  value: isEnglish,
                                  onChanged: toggleLanguage,
                                  activeColor: Theme.of(context).focusColor,
                                  inactiveThumbColor:
                                      Theme.of(context).focusColor,
                                ),
                                Text(
                                  'English',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: ShapeDecoration(
                          color: Theme.of(context).primaryColorLight,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                                text: TextSpan(
                              text: "Theme: ",
                              style: TextStyle(
                                  fontFamily: "OpenDyslexic",
                                  color: Theme.of(context).cardColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal),
                              children: [
                                TextSpan(
                                  text: selectedColorScheme,
                                  style: TextStyle(
                                      fontFamily: "OpenDyslexic",
                                      color: Theme.of(context).cardColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            )),
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
                                  color:
                                      const Color.fromARGB(255, 14, 137, 153),
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
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: ShapeDecoration(
                          color: Theme.of(context).primaryColorLight,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                                text: TextSpan(
                              text: isEnglish
                                  ? "Text size: "
                                  : "Laki ng teksto: ",
                              style: TextStyle(
                                  fontFamily: "OpenDyslexic",
                                  color: Theme.of(context).cardColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal),
                              children: [
                                TextSpan(
                                  text: (currentTextSize.toInt()).toString(),
                                  style: TextStyle(
                                      fontFamily: "OpenDyslexic",
                                      color: Theme.of(context).cardColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            )),
                            Slider(
                              activeColor: Theme.of(context).primaryColorDark,
                              overlayColor: MaterialStatePropertyAll(
                                  Theme.of(context)
                                      .primaryColorDark
                                      .withOpacity(0.3)),
                              thumbColor: Theme.of(context).focusColor,
                              value: currentTextSize,
                              min: 12,
                              max: 42,
                              divisions: 15,
                              onChanged: (value) {
                                setState(() {
                                  currentTextSize = value;
                                });

                                onTextSizeSliderChange(value);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
