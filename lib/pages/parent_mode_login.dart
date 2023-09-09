import 'package:e_dukaxon/assessment_data.dart';
import 'package:e_dukaxon/my_pages.dart';
import 'package:e_dukaxon/route_anims/horizontal_slide.dart';
import 'package:e_dukaxon/widgets/back_app_bar.dart';
import 'package:flutter/material.dart';

class PinAccessPage extends StatefulWidget {
  const PinAccessPage({Key? key}) : super(key: key);

  @override
  State<PinAccessPage> createState() => _PinAccessPageState();
}

class _PinAccessPageState extends State<PinAccessPage> {
  late TextEditingController _pinController;

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _verifyPin() {
    final int currentYear = DateTime.now().year;
    final String pin = _pinController.text.trim();

    if (pin.length == 4 && pin.contains(RegExp(r'^[0-9]+$'))) {
      final int birthYear = int.parse(pin);

      if (birthYear >= 1920 && currentYear - birthYear >= 18) {
        isOnParentMode = true;
        Navigator.pushAndRemoveUntil(
            context,
            createRouteWithHorizontalSlideAnimation(const MyPages()),
            (route) => false);
      } else {
        _showErrorDialog(
            context, 'Invalid PIN', 'Invalid PIN. Please try again.');
      }
    } else {
      _showErrorDialog(
          context, 'Invalid PIN', 'Invalid PIN. Please try again.');
    }
  }

  void _showErrorDialog(
      BuildContext context, String errorTitle, String errorText) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            errorTitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
          content: Text(
            errorText,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          actions: [
            ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarWithBackButton(text: 'Parent Mode'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Enter your 4-digit birth year to access Parent Mode:',
                style: TextStyle(fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 4,
                child: TextField(
                  controller: _pinController,
                  decoration: const InputDecoration(
                    hintText: 'YYYY',
                  ),
                  style: TextStyle(color: Theme.of(context).primaryColorDark),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                ),
              ),
              ElevatedButton(
                onPressed: _verifyPin,
                child: const Text('Enter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
