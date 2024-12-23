import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:wiredash/src/_wiredash_ui.dart';

class TronProgressIndicator extends StatefulWidget {
  const TronProgressIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  final int totalSteps;
  final int currentStep;

  @override
  State<TronProgressIndicator> createState() => _TronProgressIndicatorState();
}

class _TronProgressIndicatorState extends State<TronProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _currentAnimation;
  late Animation<double> _nextAnimation;

  double _currentProgress = 0;
  double _nextProgress = 0;

  static const _duration = Duration(seconds: 1);
  static const _size = 28.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    _updateTweens();
    _controller.forward(from: 1);
  }

  @override
  void didUpdateWidget(covariant TronProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep ||
        oldWidget.totalSteps != widget.currentStep) {
      _updateTweens();
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateTweens() {
    final double currentProgress = max(
      0,
      min(1, widget.currentStep / widget.totalSteps),
    );
    final double nextProgress = max(
      0,
      min(1, (widget.currentStep + 1.0) / widget.totalSteps),
    );

    _currentAnimation =
        Tween(begin: _currentProgress, end: currentProgress).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.35, curve: Curves.easeOut),
      ),
    );
    _nextAnimation = Tween(begin: _nextProgress, end: nextProgress).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.05, 1, curve: Curves.easeOut),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        _currentProgress = _currentAnimation.value;
        _nextProgress = _nextAnimation.value;

        return SizedBox(
          width: _size,
          height: _size,
          child: CustomPaint(
            painter: _TronProgressPainter(
              context.theme.primaryColor,
              _currentProgress,
              context.theme.primaryColor.darken(0.05),
              // ignore: deprecated_member_use
              context.theme.primaryColor.withOpacity(0.2),
              _nextProgress,
            ),
          ),
        );
      },
    );
  }
}

class _TronProgressPainter extends CustomPainter {
  const _TronProgressPainter(
    this.colorCurrent,
    this.currentProgress,
    this.circleColor,
    this.colorNext,
    this.nextProgress,
  );

  static const _borderWidth = 2.0;

  final Color colorCurrent;
  final Color colorNext;
  final Color circleColor;
  final double currentProgress;
  final double nextProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _borderWidth
      ..color = circleColor;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = colorCurrent;

    canvas.drawCircle(
      size.center(Offset.zero),
      (size.width - _borderWidth) / 2,
      circlePaint,
    );

    fillPaint.color = colorNext;
    canvas.drawArc(
      Rect.fromLTWH(
        _borderWidth * 2,
        _borderWidth * 2,
        size.width - _borderWidth * 4,
        size.height - _borderWidth * 4,
      ),
      pi,
      pi * 2 * nextProgress,
      true,
      fillPaint,
    );

    fillPaint.color = colorCurrent;
    canvas.drawArc(
      Rect.fromLTWH(
        _borderWidth * 2,
        _borderWidth * 2,
        size.width - _borderWidth * 4,
        size.height - _borderWidth * 4,
      ),
      pi,
      pi * 2 * currentProgress,
      true,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(_TronProgressPainter oldDelegate) {
    return oldDelegate.currentProgress != currentProgress ||
        oldDelegate.nextProgress != nextProgress;
  }
}
