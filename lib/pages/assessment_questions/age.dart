import 'package:flutter/material.dart';

class AgeSelectPage extends StatefulWidget {
  const AgeSelectPage({super.key});

  @override
  State<AgeSelectPage> createState() => _AgeSelectPageState();
}

class _AgeSelectPageState extends State<AgeSelectPage> {
  double _currentAge = 10; // Default age value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Please enter your child's age",
              style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 32.0,
            ),
            Text(
              'Age: ${_currentAge.toInt()}',
              style: const TextStyle(fontSize: 16.0),
            ),
            Slider(
              value: _currentAge,
              min: 1,
              max: 100,
              divisions: 99,
              onChanged: (value) {
                setState(() {
                  _currentAge = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Save the entered age and navigate back
                Navigator.pop(context, _currentAge.toInt().toString());
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
