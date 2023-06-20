import 'package:flutter/material.dart';

class LetterTracingPage extends StatefulWidget {
  const LetterTracingPage({Key? key}) : super(key: key);

  @override
  State<LetterTracingPage> createState() => _LetterTracingPageState();
}

class _LetterTracingPageState extends State<LetterTracingPage> {
  List<List<Offset>> _strokes = [];

  @override
  Widget build(BuildContext context) {
    final appBarHeight = AppBar().preferredSize.height;
    final paddingTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Letter Tracing'),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          GestureDetector(
            onPanUpdate: (DragUpdateDetails details) {
              setState(() {
                RenderBox renderBox = context.findRenderObject() as RenderBox;
                Offset localPosition =
                    renderBox.globalToLocal(details.globalPosition) -
                        Offset(0, appBarHeight + paddingTop);
                _strokes.last.add(localPosition);
              });
            },
            onPanStart: (DragStartDetails details) {
              setState(() {
                _strokes.add([]);
              });
            },
            child: CustomPaint(
              painter: Painter(strokes: _strokes),
              size: Size.infinite,
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Done'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[700],
        child: const Icon(Icons.delete_outline),
        onPressed: () {
          setState(() {
            _strokes.clear();
          });
        },
      ),
    );
  }
}

class Painter extends CustomPainter {
  List<List<Offset>> strokes;

  Painter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the background color
    Paint backgroundPaint = Paint()..color = Colors.grey[900]!;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Draw the letter on the canvas
    final textStyle = TextStyle(
        color: Colors.grey[600], fontSize: 300, fontFamily: 'Comic Sans');
    final textSpan = TextSpan(
      text: 'A',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    final offsetX = (size.width - textPainter.width) /
        2; // Calculate X offset for centering horizontally
    final offsetY = (size.height - textPainter.height) /
        2; // Calculate Y offset for centering vertically
    final offset = Offset(offsetX, offsetY);
    textPainter.paint(canvas, offset);

    // Draw the brush strokes
    Paint paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10.0;

    for (final stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        if (stroke[i] != null &&
            stroke[i + 1] != null &&
            !stroke[i].isInfinite) {
          canvas.drawLine(stroke[i], stroke[i + 1], paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(Painter oldDelegate) => true;
}
