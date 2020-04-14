import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class SketcherModel extends ChangeNotifier {
  final List<SketcherGesture> _gestures = [];
  Size size = Size.zero;

  List<SketcherGesture> get gestures => List.unmodifiable(_gestures);

  SketcherGesture _last;

  void addGesture(SketcherGesture gesture) {
    _gestures.add(gesture);
    _last = gesture;
    notifyListeners();
  }

  void undoGesture() {
    if (_gestures.isNotEmpty) _gestures.removeLast();
    notifyListeners();
  }

  void updateGesture(Offset offset) {
    _last..addPoint(offset)..addPoint(offset);
    notifyListeners();
  }

  void endGesture() {
    // Interpret as a point when less than 5 points recorded
    if (_last.points.length < 5) {
      _gestures.removeLast();
      _gestures.add(_last.firstPoint());
    } else {
      _last.addPoint(_last.points[_last.points.length - 1]);
    }
    notifyListeners();
  }

  void clearGestures() {
    _gestures.clear();
    notifyListeners();
  }
}

class SketcherGesture {
  SketcherGesture(this.mode, this.paint)
      : assert(mode != null && paint != null);

  factory SketcherGesture.point(Color color, Offset point) {
    return SketcherGesture(
      ui.PointMode.points,
      ui.Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 8.0
        ..color = color,
    )..addPoint(point);
  }

  factory SketcherGesture.startLine(Color color, Offset start) {
    return SketcherGesture(
      ui.PointMode.lines,
      ui.Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 4.0
        ..color = color,
    )..addPoint(start);
  }

  final ui.PointMode mode;
  final Paint paint;
  final List<Offset> points = [];

  void addPoint(Offset offset) {
    points.add(offset);
  }

  SketcherGesture firstPoint() {
    return SketcherGesture.point(paint.color, points[0]);
  }
}
