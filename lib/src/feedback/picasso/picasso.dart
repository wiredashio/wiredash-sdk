import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:wiredash/src/feedback/picasso/sketcher.dart';
import 'package:wiredash/src/feedback/picasso/stroke.dart';

class Picasso extends StatefulWidget {
  const Picasso({
    super.key,
    required this.controller,
    required this.child,
  });

  final PicassoController controller;
  final Widget child;

  @override
  State<Picasso> createState() => _PicassoState();
}

class _PicassoState extends State<Picasso> {
  List<Stroke> _strokes = const [];
  List<Stroke> _undoneStrokes = const [];
  Stroke? _currentStroke;

  final _strokesStreamController = StreamController<List<Stroke?>>.broadcast();
  final _currentStrokeStreamController = StreamController<Stroke?>.broadcast();

  Size _sketcherCanvasSize = ui.window.physicalSize;

  @override
  void initState() {
    super.initState();
    widget.controller._state = this;
    widget.controller.addListener(_updateWithControllerConfig);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateWithControllerConfig);
    widget.controller._state = null;
    super.dispose();
  }

  void _updateWithControllerConfig() {
    setState(() {
      // Empty setState call to update activated state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.controller.isActive) _buildAllPreviousStrokes(context),
        if (widget.controller.isActive) _buildCurrentStroke(context),
      ],
    );
  }

  Widget _buildCurrentStroke(BuildContext context) {
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

  Widget _buildAllPreviousStrokes(BuildContext context) {
    // 98.2% useful based on metrics in Flutter Inspector 👌
    // Diagnosis:
    // > this is an outstandingly useful repaint boundary and should
    // > definitely be kept
    return RepaintBoundary(
      child: SizedBox.expand(
        child: StreamBuilder<List<Stroke?>>(
          stream: _strokesStreamController.stream,
          builder: (context, snapshot) {
            return CustomPaint(
              painter: Sketcher(
                strokes: _strokes,
                onPaint: (size) => _sketcherCanvasSize = size,
              ),
            );
          },
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    final box = context.findRenderObject()! as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    _currentStroke = Stroke(
      StrokeType.dot,
      [point],
      widget.controller.color ?? Colors.black,
      widget.controller.strokeWidth,
    );
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final box = context.findRenderObject()! as RenderBox;
    final point = box.globalToLocal(details.globalPosition);

    final path = List<Offset>.from(_currentStroke!.path)..add(point);
    _currentStroke = Stroke(
      StrokeType.line,
      path,
      widget.controller.color ?? Colors.black,
      widget.controller.strokeWidth,
    );
    _currentStrokeStreamController.add(_currentStroke);
  }

  void _onPanEnd(DragEndDetails details) {
    _strokes = List.unmodifiable([..._strokes, _currentStroke]);
    _strokesStreamController.add(_strokes);
  }

  void _clear() {
    _currentStroke = null;
    _currentStrokeStreamController.add(_currentStroke);

    _strokes = const [];
    _strokesStreamController.add(_strokes);
  }

  void _undo() {
    _currentStroke = null;
    _currentStrokeStreamController.add(_currentStroke);

    if (_strokes.isNotEmpty) {
      final strokes = _strokes.toList();
      final lastStroke = strokes.removeLast();
      _strokes = List.unmodifiable(strokes);
      _undoneStrokes = List.unmodifiable([..._undoneStrokes, lastStroke]);
      _strokesStreamController.add(_strokes);
    }
  }

  void _redo() {
    if (_undoneStrokes.isNotEmpty) {
      final undoneStroke = _undoneStrokes.toList();
      final lastUndoneStroke = undoneStroke.removeLast();
      _undoneStrokes = List.unmodifiable(undoneStroke);
      _strokes = List.unmodifiable([_strokes, lastUndoneStroke]);
      _strokesStreamController.add(_strokes);
    }
  }

  Future<Uint8List> _paintOntoImage(
    ui.Image image,
    Color backgroundColor,
  ) async {
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final recording = ui.PictureRecorder();
    assert(_sketcherCanvasSize.width > 0);
    assert(_sketcherCanvasSize.height > 0);
    final canvas = Canvas(
      recording,
      Rect.fromLTWH(0.0, 0.0, imageSize.width, imageSize.height),
    );

    // draw the background
    canvas.drawColor(backgroundColor, BlendMode.src);

    // Draw the screenshot
    canvas.drawImage(image, Offset.zero, Paint());
    canvas.scale(
      imageSize.width / _sketcherCanvasSize.width,
      imageSize.height / _sketcherCanvasSize.height,
    );

    // draw drawing
    Sketcher(strokes: _strokes).paint(canvas, imageSize);

    final masterpiece = await recording.endRecording().toImage(
          imageSize.width.toInt(),
          imageSize.height.toInt(),
        );

    final bytes = await masterpiece.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }
}

class PicassoController extends ChangeNotifier {
  _PicassoState? _state;

  bool _isActive = false;
  double _strokeWidth = 8.0;

  bool get isActive => _isActive;

  set isActive(bool value) {
    _isActive = value;
    notifyListeners();
  }

  Color? _color;
  Color? get color => _color;
  set color(Color? value) {
    _color = value;
    notifyListeners();
  }

  double get strokeWidth => _strokeWidth;

  set strokeWidth(double value) {
    _strokeWidth = value;
    notifyListeners();
  }

  void clear() {
    _state?._clear();
  }

  void undo() {
    _state?._undo();
  }

  void redo() {
    _state?._redo();
  }

  bool canUndo() {
    if (_state == null) return false;
    return _state!._strokes.isNotEmpty;
  }

  Future<Uint8List> paintDrawingOntoImage(
    ui.Image image,
    Color backgroundColor,
  ) async {
    return _state!._paintOntoImage(image, backgroundColor);
  }
}
