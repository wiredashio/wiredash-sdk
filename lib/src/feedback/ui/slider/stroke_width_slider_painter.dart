import 'dart:ui';

import 'package:flutter/material.dart';

class StrokeWidthSliderPainter extends CustomPainter {
  StrokeWidthSliderPainter({
    required this.color,
    required this.progress,
    required this.minWidth,
    required this.maxWidth,
  });

  final double progress;
  final double minWidth;
  final double maxWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      // ignore: deprecated_member_use
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = minWidth;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // ignore: deprecated_member_use
    paint.color = color.withOpacity(0.7);
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width * progress, size.height / 2),
      paint,
    );

    paint.color = color;
    paint.strokeWidth = minWidth + maxWidth * progress;
    canvas.drawPoints(
      PointMode.points,
      [Offset(size.width * progress, size.height / 2)],
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
