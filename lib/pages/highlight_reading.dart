import 'package:e_dukaxon/widgets/back_app_bar.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_dukaxon/auth.dart';

class HighlightReading extends StatefulWidget {
  final String text;
  const HighlightReading({required this.text, Key? key}) : super(key: key);

  @override
  State<HighlightReading> createState() => _HighlightReadingState();
}

class _HighlightReadingState extends State<HighlightReading> {
  late List<String> _sentences;
  int _currentIndex = 0;
  final FlutterTts flutterTts = FlutterTts();
  bool _isReading = false;
  double _fontSize = 24.0;

  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  @override
  void initState() {
    super.initState();
    _sentences = widget.text.split('.'); // Split text into sentences
    flutterTts.setCompletionHandler(() {
      setState(() {
        _isReading = false;
        _currentIndex = 0; // Reset the highlighted sentence
      });
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    for (var i = 0; i < _sentences.length; i++) {
      setState(() {
        _currentIndex = i;
      });
      await flutterTts.speak(_sentences[i]);
      await Future.delayed(
          const Duration(milliseconds: 5000)); // Pause for 500ms
    }
    setState(() {
      _currentIndex = 0;
      _isReading = false;
    });
  }

  void _highlightSentence(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _toggleReading() async {
    setState(() {
      _isReading = !_isReading;
    });
    if (_isReading) {
      await _speak(widget.text);
      setState(() {
        _isReading = false; // Reset the flag when speaking is done
      });
    } else {
      await flutterTts.stop();
      setState(() {
        _currentIndex = 0; // Reset the highlighted sentence
      });
    }
  }

  void _nextSentence() {
    final newIndex = (_currentIndex + 1) % _sentences.length;
    _highlightSentence(newIndex); // Highlight the next sentence
    setState(() {
      _currentIndex = newIndex;
    });
  }

  void _previousSentence() {
    final newIndex =
        (_currentIndex - 1 + _sentences.length) % _sentences.length;
    _highlightSentence(newIndex); // Highlight the previous sentence
    setState(() {
      _currentIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: CustomAppBarWithBackButton(text: 'Highlight Reading'),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _sentences.asMap().entries.map((entry) {
                    final index = entry.key;
                    final sentence = entry.value;
                    final isHighlighted = index == _currentIndex;
                    return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: Padding(
                            key: ValueKey(
                                index), // <-- use the sentence index as the key
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              sentence.trim(),
                              style: TextStyle(
                                color: isHighlighted ? Colors.black : null,
                                backgroundColor:
                                    isHighlighted ? Colors.yellow : null,
                                fontWeight:
                                    isHighlighted ? FontWeight.bold : null,
                                fontSize: _fontSize,
                              ),
                            ),
                          ),
                        ));
                  }).toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: _previousSentence,
                    child: const Text('Previous'),
                  ),
                  const SizedBox(
                    width: 20.0,
                  ),
                  ElevatedButton(
                    onPressed: _nextSentence,
                    child: const Text('Next'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _fontSize -= 2.0; // decrease font size by 2
                      });
                    },
                    icon: Icon(Icons.remove),
                    label: const Text('Decrease size'),
                  ),
                  const SizedBox(width: 20.0),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _fontSize += 2.0; // increase font size by 2
                      });
                    },
                    icon: Icon(Icons.add),
                    label: const Text("Increase size"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _isReading ? Colors.grey[900] : Colors.grey[600],
        onPressed: _toggleReading,
        tooltip: 'Read the paragraph',
        child:
            _isReading ? const Icon(Icons.stop) : const Icon(Icons.play_arrow),
      ),
    );
  }
}

// class VoiceButton extends StatefulWidget {
//   final String text;
//   const VoiceButton({required this.text, Key? key}) : super(key: key);

//   @override
//   State<VoiceButton> createState() => _VoiceButtonState();
// }

// class _VoiceButtonState extends State<VoiceButton> {
//   final FlutterTts flutterTts = FlutterTts();
//   bool _isReading = false;

//   @override
//   void initState() {
//     super.initState();
//     flutterTts.setCompletionHandler(() {
//       setState(() {
//         _isReading = false;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     flutterTts.stop();
//     super.dispose();
//   }

//   Future<void> _speak(String text) async {
//     setState(() {
//       _isReading = true;
//     });
//     await flutterTts.setLanguage("en-US");
//     await flutterTts.setSpeechRate(0.5);
//     await flutterTts.setVolume(1.0);
//     await flutterTts.setPitch(1.0);
//     await flutterTts.speak(text);
//   }

//   Future<void> _toggleReading() async {
//     setState(() {
//       _isReading = !_isReading;
//     });
//     if (_isReading) {
//       await _speak(widget.text);
//     } else {
//       await flutterTts.stop();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FloatingActionButton(
//       backgroundColor: _isReading ? Colors.grey[900] : Colors.grey[600],
//       onPressed: _toggleReading,
//       tooltip: 'Read the paragraph',
//       child: _isReading ? const Icon(Icons.stop) : const Icon(Icons.play_arrow),
//     );
//   }
// }
