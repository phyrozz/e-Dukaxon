import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LetterTracingPage extends StatefulWidget {
  const LetterTracingPage({Key? key}) : super(key: key);

  @override
  State<LetterTracingPage> createState() => _LetterTracingPageState();
}

class _LetterTracingPageState extends State<LetterTracingPage> {
  final List<List<Offset>> _strokes = [];

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
        backgroundColor: Theme.of(context).primaryColorDark,
        child: const FaIcon(FontAwesomeIcons.eraser),
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
    Paint backgroundPaint = Paint()..color = const Color(0xFFF2EAD3);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Draw the letter on the canvas
    const textStyle = TextStyle(
        color: Color.fromARGB(255, 175, 175, 175),
        fontSize: 300,
        fontFamily: 'Comic Sans');
    const textSpan = TextSpan(
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
      ..color = const Color(0xFF3F2305)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10.0;

    for (final stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        if (!stroke[i].isInfinite) {
          canvas.drawLine(stroke[i], stroke[i + 1], paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(Painter oldDelegate) => true;
}
