import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VolumeButton extends StatefulWidget {
  final String text;
  const VolumeButton({required this.text, Key? key}) : super(key: key);

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
        backgroundColor: _isSpeaking
            ? Theme.of(context).focusColor
            : Theme.of(context).primaryColorDark,
        onPressed: () {
          setState(() {
            _isMuted = !_isMuted;
          });
          if (_isMuted) {
            _speak(widget.text);
          } else {
            flutterTts.stop();
          }
        },
        child: const Icon(Icons.volume_up));
  }
}
