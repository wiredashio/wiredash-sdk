import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/translation/wiredash_localizations.dart';

class FeedbackPen extends StatefulWidget {
  const FeedbackPen({
    Key? key,
    required this.color,
  }) : super(key: key);

  final Color color;

  @override
  _FeedbackPenState createState() => _FeedbackPenState();
}

class _FeedbackPenState extends State<FeedbackPen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  late Color _currentColor;
  late Color _nextColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.color;
    _nextColor = widget.color;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _currentColor = _nextColor;
            _animationController.reverse();
          });
        }
      });

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));
  }

  @override
  void didUpdateWidget(FeedbackPen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color) {
      _nextColor = widget.color;
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SlideTransition(
        position: _slideAnimation,
        child: IntrinsicHeight(
          child: CustomPaint(
            foregroundPainter: _PenNosePainter(_currentColor),
            child: Image.asset(
              'assets/images/pen.png',
              package: 'wiredash',
              semanticLabel: _buildLabel(context),
            ),
          ),
        ),
      ),
    );
  }

  String _buildLabel(BuildContext context) {
    final theme = WiredashTheme.of(context)!;
    final localizations = WiredashLocalizations.of(context)!;

    if (_currentColor == theme.firstPenColor) {
      return localizations.firstPenSelected;
    } else if (_currentColor == theme.secondPenColor) {
      return localizations.secondPenSelected;
    } else if (_currentColor == theme.thirdPenColor) {
      return localizations.thirdPenSelected;
    } else if (_currentColor == theme.fourthPenColor) {
      return localizations.fourthPenSelected;
    }

    throw StateError('Wiredash Error: No Label found for $_currentColor.');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class _PenNosePainter extends CustomPainter {
  _PenNosePainter(this._color)
      : _nosePaint = Paint()
          ..color = _color.withOpacity(0.8)
          ..style = PaintingStyle.fill;

  final Color _color;
  final Paint _nosePaint;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width / 2, 20), radius: 6.5),
      pi * 0.1,
      -pi * 1.2,
      false,
      _nosePaint,
    );
  }

  @override
  bool shouldRepaint(_PenNosePainter oldDelegate) =>
      oldDelegate._color != _color;
}
