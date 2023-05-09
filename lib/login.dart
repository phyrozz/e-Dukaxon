import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Let's start learning!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 36.0,
              ),
            ),
            const SizedBox(height: 32.0),
            const TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person),
                labelText: 'Email / Username',
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock),
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              child: const Padding(
                padding: EdgeInsets.all(14.0),
                child: Text('Log In'),
              ),
              // Change onPressed logic once login auth is implemented
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                primary: Colors.white,
              ),
              child: const Padding(
                padding: EdgeInsets.all(14.0),
                child: Text('I want to create an account'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: const VolumeButton(),
    );
  }
}

class VolumeButton extends StatefulWidget {
  const VolumeButton({Key? key}) : super(key: key);

  @override
  State<VolumeButton> createState() => _VolumeButtonState();
}

class _VolumeButtonState extends State<VolumeButton> {
  bool _isMuted = false;
  bool _isSpeaking = false;
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    flutterTts.setCompletionHandler(() {
      setState(() {
        _isMuted = false;
        _isSpeaking = false;
      });
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future _speak(String text) async {
    setState(() {
      _isSpeaking = true;
    });
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        backgroundColor: _isSpeaking ? Colors.grey[900] : Colors.grey[600],
        onPressed: () {
          setState(() {
            _isMuted = !_isMuted;
          });
          if (_isMuted) {
            _speak(
                "Hello! Let's get started by entering your username or email address. then, enter your password. Once you're done, tap the big gray button! If you don't have an account or you want to create another one, tap the text below the big button that says I want to create an account.");
          } else {
            flutterTts.stop();
          }
        },
        child: const Icon(Icons.volume_up));
  }
}
