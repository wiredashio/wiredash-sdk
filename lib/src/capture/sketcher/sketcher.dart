import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/capture/sketcher/gesture.dart';
import 'package:wiredash/src/capture/sketcher/sketch_painter.dart';
import 'package:wiredash/src/capture/sketcher/sketcher_controller.dart';

class Sketcher extends StatelessWidget {
  const Sketcher({
    Key? key,
    required SketcherController controller,
    this.isEnabled = false,
    required this.child,
  })  : _controller = controller,
        super(key: key);

  final SketcherController _controller;
  final bool isEnabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior:
          isEnabled ? HitTestBehavior.opaque : HitTestBehavior.translucent,
      onPanDown: isEnabled ? _onPanDown : null,
      onPanUpdate: isEnabled ? _onPanUpdate : null,
      onPanEnd: isEnabled ? _onPanEnd : null,
      child: AbsorbPointer(
        absorbing: isEnabled,
        child: ClipRect(
          child: CustomPaint(
            foregroundPainter: SketchPainter(_controller),
            isComplex: true,
            willChange: true,
            child: child,
          ),
        ),
      ),
    );
  }

  void _onPanDown(DragDownDetails details) {
    _controller.addGesture(
      Gesture.startLine(
        _controller.color, // Selected pen color
        details.localPosition,
      ),
    );
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _controller.updateGesture(details.localPosition);
  }

  void _onPanEnd(DragEndDetails details) {
    _controller.endGesture();
  }
}
