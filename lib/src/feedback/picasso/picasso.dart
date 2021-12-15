import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:wiredash/src/feedback/picasso/sketcher.dart';
import 'package:wiredash/src/feedback/picasso/stroke.dart';

class Picasso extends StatefulWidget {
  const Picasso({
    Key? key,
    required this.controller,
    required this.child,
  }) : super(key: key);

  final PicassoController controller;
  final Widget child;

  @override
  State<Picasso> createState() => _PicassoState();
}

class PicassoController extends ChangeNotifier {
  late _PicassoState? _state;

  bool _isActive = false;
  Color _color = const Color(0xff6B46C1);
  double _strokeWidth = 5.0;

  bool get isActive => _isActive;
  set isActive(bool value) {
    _isActive = value;
    notifyListeners();
  }

  Color get color => _color;

  set color(Color value) {
    _color = value;
    notifyListeners();
  }

  double get strokeWidth => _strokeWidth;

  set strokeWidth(double value) {
    _strokeWidth = value;
    notifyListeners();
  }

  void clear() {
    _state!._clear();
  }

  void undo() {
    _state!._undo();
  }

  void redo() {
    _state!._redo();
  }

  Future<Uint8List> paintDrawingOntoImage(ui.Image image) async {
    return _state!._paintOntoImage(image);
  }
}

class _PicassoState extends State<Picasso> {
  List<Stroke> _strokes = const [];
  List<Stroke> _undoneStrokes = const [];
  Stroke? _currentStroke;

  final _strokesStreamController = StreamController<List<Stroke?>>.broadcast();
  final _currentStrokeStreamController = StreamController<Stroke?>.broadcast();

  @override
  void initState() {
    super.initState();
    widget.controller._state = this;
    widget.controller.addListener(_updateWithControllerConfig);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateWithControllerConfig);
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

  void _onPanStart(DragStartDetails details) {
    final box = context.findRenderObject()! as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    _currentStroke = Stroke(
      StrokeType.dot,
      [point],
      widget.controller.color,
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
      widget.controller.color,
      widget.controller.strokeWidth,
    );
    _currentStrokeStreamController.add(_currentStroke);
  }

  void _onPanEnd(DragEndDetails details) {
    _strokes = List.unmodifiable([..._strokes, _currentStroke!]);
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

  Future<Uint8List> _paintOntoImage(ui.Image image) async {
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

    final bytes = await masterpiece.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }
}
