import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wiredash/src/feedback/picasso/stroke.dart';

class Sketcher extends CustomPainter {
  final List<Stroke?> strokes;
  final void Function(Size canvasSize)? onPaint;

  Sketcher({required this.strokes, this.onPaint});

  @override
  void paint(Canvas canvas, Size size) {
    onPaint?.call(size);

    final paint = Paint()..strokeCap = StrokeCap.round;

    for (final stroke in strokes) {
      // Skip an empty stroke
      if (stroke == null) continue;

      // Set correct paint for the stroke
      paint.color = stroke.color;
      paint.strokeWidth = stroke.width;

      // Paint a dot or a connected line, depending on the StrokeType
      if (StrokeType.dot == stroke.type) {
        canvas.drawPoints(PointMode.points, stroke.path, paint);
      } else if (StrokeType.line == stroke.type) {
        canvas.drawPoints(PointMode.polygon, stroke.path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(Sketcher oldDelegate) => true;
}
