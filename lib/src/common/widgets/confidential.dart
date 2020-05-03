import 'package:flutter/widgets.dart';
import 'package:wiredash/src/wiredash_widget.dart';

/// Use a [Confidential] widget to hide any widgets containing sensitive info
/// from being captured inside a feedback screenshot.
class Confidential extends StatelessWidget {
  const Confidential(
      {Key key, this.mode = ConfidentialMode.black, @required this.child})
      : assert(child != null),
        super(key: key);

  final ConfidentialMode mode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Wiredash.of(context).visible,
      builder: (_, __) {
        final isVisible = Wiredash.of(context).visible.value;
        return CustomPaint(
          foregroundPainter: isVisible && mode == ConfidentialMode.black
              ? PaintItBlack()
              : null,
          child: Opacity(
            opacity: isVisible ? 0.0 : 1.0,
            child: child,
          ),
        );
      },
    );
  }
}

enum ConfidentialMode { black, invisible }

class PaintItBlack extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xff000000)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromLTRBR(
        0,
        0,
        size.width,
        size.height,
        const Radius.circular(4),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
