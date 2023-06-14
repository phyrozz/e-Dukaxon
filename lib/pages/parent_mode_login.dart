import 'package:e_dukaxon/assessment_data.dart';
import 'package:flutter/material.dart';

class PinAccessPage extends StatefulWidget {
  const PinAccessPage({Key? key}) : super(key: key);

  @override
  State<PinAccessPage> createState() => _PinAccessPageState();
}

class _PinAccessPageState extends State<PinAccessPage> {
  late TextEditingController _pinController;
  String? _errorText;

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
      setState(() {
        _errorText = null;
      });
      isOnParentMode = true;
      Navigator.pushReplacementNamed(context, '/myPages');
    } else {
      setState(() {
        _errorText = 'You must be at least 18 years old to access Parent Mode.';
      });
    }
  } else {
    setState(() {
      _errorText = 'Please enter a valid 4-digit code.';
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Mode'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter your 4-digit birth year to access Parent Mode:',
              style: TextStyle(fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
            TextField(
              style: TextStyle(
                color: Colors.black,
              ),
              controller: _pinController,
              decoration: InputDecoration(
                hintText: 'YYYY',
                errorText: _errorText,
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
            ),
            ElevatedButton(
              onPressed: _verifyPin,
              child: const Text('Enter'),
            ),
          ],
        ),
      ),
    );
  }
}
