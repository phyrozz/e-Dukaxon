import 'package:flutter/material.dart';

class HighlightReading extends StatefulWidget {
  final String text;
  const HighlightReading({required this.text, Key? key}) : super(key: key);

  @override
  State<HighlightReading> createState() => _HighlightReadingState();
}

class _HighlightReadingState extends State<HighlightReading> {
  late List<String> _sentences;
  int _currentIndex = 0;
  Key _key = UniqueKey();

  @override
  void initState() {
    super.initState();
    _sentences = widget.text.split('.'); // Split text into sentences
  }

  void _nextSentence() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _sentences.length;
      _key = UniqueKey(); // Update key to trigger animation
    });
  }

  void _previousSentence() {
    setState(() {
      _currentIndex =
          (_currentIndex - 1 + _sentences.length) % _sentences.length;
      _key = UniqueKey(); // Update key to trigger animation
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        automaticallyImplyLeading: false, // Hide back button
        title: const Text('Highlighted Text'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Show account dropdown menu
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _sentences.map((sentence) {
                    final isHighlighted = sentence == _sentences[_currentIndex];
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
                            key: ValueKey(_currentIndex),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              sentence.trim(),
                              style: TextStyle(
                                color: isHighlighted ? Colors.black : null,
                                backgroundColor:
                                    isHighlighted ? Colors.yellow : null,
                                fontWeight:
                                    isHighlighted ? FontWeight.bold : null,
                                fontSize: 24.0,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _previousSentence,
                    child: const Text('Previous'),
                  ),
                  ElevatedButton(
                    onPressed: _nextSentence,
                    child: const Text('Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
