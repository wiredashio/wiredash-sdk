import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

class Gesture {
  Gesture(this.mode, this.paint);

  factory Gesture.point(Color color, Offset point) {
    return Gesture(
      ui.PointMode.points,
      ui.Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 8.0
        ..color = color,
    )..addPoint(point);
  }

  factory Gesture.startLine(Color color, Offset start) {
    return Gesture(
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

  Gesture firstPoint() {
    return Gesture.point(paint.color, points[0]);
  }
}
