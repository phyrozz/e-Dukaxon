import 'package:e_dukaxon/widgets/back_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isEnglish = true;

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
    });
  }

  Future<void> saveLanguagePreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isEnglish', value);
  }

  // Toggle the language and update the preference
  void toggleLanguage(bool newValue) {
    setState(() {
      isEnglish = newValue;
      saveLanguagePreference(isEnglish);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarWithBackButton(text: "Settings"),
      body: SingleChildScrollView(
        child: Padding(
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
