import 'package:flutter/widgets.dart';

class DiagonalShapePainter extends CustomPainter {
  final Color color;
  final double padding;

  DiagonalShapePainter({
    required this.color,
    required this.padding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height - 120 - padding)
      ..lineTo(size.width, size.height - 145 - padding)
      ..lineTo(size.width, size.height)
      ..close();
    final paint = Paint()..color = color;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
