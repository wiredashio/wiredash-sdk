import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/feedback/picasso/sketcher.dart';
import 'package:wiredash/src/feedback/picasso/stroke.dart';

class Picasso extends StatefulWidget {
  const Picasso({Key? key}) : super(key: key);

  @override
  _PicassoState createState() => _PicassoState();
}

class _PicassoState extends State<Picasso> {
  List<Stroke> _strokes = const [];
  List<Stroke> _undoneStrokes = const [];
  Stroke? _currentStroke;

  final _strokesStreamController = StreamController<List<Stroke?>>.broadcast();
  final _currentStrokeStreamController = StreamController<Stroke?>.broadcast();

  Color _selectedColor = Colors.black;
  double _selectedWidth = 5.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        buildAllPreviousStrokes(context),
        buildCurrentStroke(context),
        _buildDebugMenu(),
      ],
    );
  }

  Widget buildCurrentStroke(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: RepaintBoundary(
        child: SizedBox.expand(
          child: StreamBuilder<Stroke?>(
            stream: _currentStrokeStreamController.stream,
            builder: (context, snapshot) {
              return CustomPaint(
                painter: Sketcher(
                  strokes: [_currentStroke],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildAllPreviousStrokes(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox.expand(
        child: StreamBuilder<List<Stroke?>>(
          stream: _strokesStreamController.stream,
          builder: (context, snapshot) {
            return CustomPaint(
              painter: Sketcher(
                strokes: _strokes,
              ),
            );
          },
        ),
      ),
    );
  }

  /// Just a crappy debug menu for quick testing, will get removed real soon
  Widget _buildDebugMenu() {
    return Column(
      children: [
        const SizedBox(height: 120),
        Row(
          children: [
            MaterialButton(
              onPressed: undo,
              child: const Text('Undo'),
            ),
            MaterialButton(
              onPressed: redo,
              child: const Text('Redo'),
            ),
            MaterialButton(
              onPressed: clear,
              child: const Text('Clear'),
            ),
          ],
        ),
        Row(
          children: [
            MaterialButton(
              onPressed: () => setPaint(color: Colors.red, width: 8),
              child: const Text('Choose fat red'),
            ),
            MaterialButton(
              onPressed: () => setPaint(color: Colors.green, width: 2),
              child: const Text('Choose thin green'),
            ),
          ],
        )
      ],
    );
  }

  void _onPanStart(DragStartDetails details) {
    final box = context.findRenderObject()! as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    _currentStroke =
        Stroke(StrokeType.dot, [point], _selectedColor, _selectedWidth);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final box = context.findRenderObject()! as RenderBox;
    final point = box.globalToLocal(details.globalPosition);

    final path = List<Offset>.from(_currentStroke!.path)..add(point);
    _currentStroke =
        Stroke(StrokeType.line, path, _selectedColor, _selectedWidth);
    _currentStrokeStreamController.add(_currentStroke);
  }

  void _onPanEnd(DragEndDetails details) {
    _strokes = List.unmodifiable([..._strokes, _currentStroke!]);
    _strokesStreamController.add(_strokes);
  }

  void clear() {
    _currentStroke = null;
    _currentStrokeStreamController.add(_currentStroke);

    _strokes = const [];
    _strokesStreamController.add(_strokes);
  }

  void undo() {
    _currentStroke = null;
    _currentStrokeStreamController.add(_currentStroke);

    if (_strokes.isNotEmpty) {
      final strokes = _strokes.toList();
      final lastStroke = strokes.removeLast();
      _strokes = List.unmodifiable(strokes);
      _undoneStrokes.add(lastStroke);
      _strokesStreamController.add(_strokes);
    }
  }

  void redo() {
    if (_undoneStrokes.isNotEmpty) {
      final undoneStroke = _undoneStrokes.toList();
      final lastUndoneStroke = undoneStroke.removeLast();
      _undoneStrokes = List.unmodifiable(undoneStroke);
      _strokes = List.unmodifiable([_strokes, lastUndoneStroke]);
      _strokesStreamController.add(_strokes);
    }
  }

  void setPaint({Color color = Colors.black, double width = 5}) {
    _selectedColor = color;
    _selectedWidth = width;
  }

  Future<ui.Image> paintOntoImage(ui.Image image) async {
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final recording = ui.PictureRecorder();
    final canvas = Canvas(
      recording,
      Rect.fromLTWH(0.0, 0.0, imageSize.width, imageSize.height),
    )..drawImage(image, Offset.zero, Paint());
    // ..scale(imageSize.width / size.width, imageSize.height / size.height);

    Sketcher(strokes: _strokes).paint(canvas, imageSize);

    final masterpiece = await recording.endRecording().toImage(
          imageSize.width.toInt(),
          imageSize.height.toInt(),
        );

    return masterpiece;

    // final bytes = await masterpiece.toByteData(format: ui.ImageByteFormat.png);
    // return bytes!.buffer.asUint8List();
  }
}
