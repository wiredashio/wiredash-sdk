import 'package:flutter/widgets.dart';
import 'package:wiredash/wiredash.dart';

/// Use a [Confidential] widget to hide any widgets containing sensitive info
/// from being captured inside a feedback screenshot.
class Confidential extends StatelessWidget {
  const Confidential({
    super.key,
    this.mode = ConfidentialMode.black,
    this.enabled = true,
    required this.child,
  });

  /// How the confidential widget will be hidden when Wiredash is active.
  ///
  /// This is ignored when [enabled] is `false`.
  final ConfidentialMode mode;

  /// Whether confidentiality should be enabled or not for this widget.
  ///
  /// When `false`, the [mode] is ignored and the [child] is always shown.
  final bool enabled;

  /// Child widget affected by confidentiality when Wiredash is active.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return AnimatedBuilder(
      animation: Wiredash.maybeOf(context)?.visible ??
          const AlwaysStoppedAnimation(false),
      builder: (_, __) {
        final isVisible = Wiredash.maybeOf(context)?.visible.value ?? false;
        return CustomPaint(
          foregroundPainter: isVisible && mode == ConfidentialMode.black
              ? _PaintItBlack()
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

enum ConfidentialMode {
  /// Covers the child widget with black paint.
  black,

  /// Hides the child widget (opacity 0).
  invisible,
}

class _PaintItBlack extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xff000000)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(4),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
