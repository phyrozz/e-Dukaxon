import 'package:e_dukaxon/pages/highlight_reading.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/widgets/app_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<String> generateText(String prompt) async {
    final endpoint =
        'https://api.openai.com/v1/engines/davinci-codex/completions';
    final promptJson =
        jsonEncode({'prompt': prompt, 'temperature': 0.7, 'max_tokens': 60});

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer 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',
      },
      body: promptJson,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final choices = responseData['choices'];
      if (choices.isNotEmpty) {
        return choices.first['text'];
      } else {
        throw Exception('Empty response from OpenAI API');
      }
    } else {
      throw Exception('Failed to generate text: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar("eDukaxon"),
      body: Container(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () async {
                // final text = await generateText("Generate a random paragraph.");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HighlightReading(
                        text:
                            "The headphones were on. They had been utilized on purpose. She could hear her mom yelling in the background, but couldn't make out exactly what the yelling was about. That was exactly why she had put them on. She knew her mom would enter her room at any minute, and she could pretend that she hadn't heard any of the previous yelling."),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(14.0),
                child: Text('Highlight Reading'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}