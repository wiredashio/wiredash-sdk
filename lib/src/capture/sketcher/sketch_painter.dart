import 'package:flutter/widgets.dart';
import 'package:wiredash/src/capture/sketcher/sketcher_controller.dart';

class SketchPainter extends CustomPainter {
  SketchPainter(this.controller) : super(repaint: controller);

  final SketcherController controller;

  @override
  void paint(Canvas canvas, Size size) {
    controller.size = size;

    for (final gesture in controller.gestures) {
      canvas.drawPoints(gesture.mode, gesture.points, gesture.paint);
    }
  }

  @override
  bool shouldRepaint(SketchPainter oldDelegate) =>
      oldDelegate.controller != controller;
}
