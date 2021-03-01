import 'package:flutter/material.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';

class AnimatedProgress extends StatefulWidget {
  final double value;
  final bool isLoading;

  const AnimatedProgress({
    Key? key,
    required this.value,
    this.isLoading = false,
  }) : super(key: key);

  @override
  _AnimatedProgressState createState() => _AnimatedProgressState();
}

class _AnimatedProgressState extends State<AnimatedProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressAnimation = AnimationController(vsync: this, value: widget.value);
  }

  @override
  void didUpdateWidget(AnimatedProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _progressAnimation.animateTo(widget.value,
          duration: const Duration(milliseconds: 450), curve: Curves.ease);
    }
  }

  @override
  void dispose() {
    _progressAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        WiredashTheme.of(context)!.primaryColor.withAlpha(100);
    final progressColor =
        AlwaysStoppedAnimation<Color>(WiredashTheme.of(context)!.primaryColor);

    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, _) {
        return LinearProgressIndicator(
          value: widget.isLoading ? null : _progressAnimation.value,
          backgroundColor: backgroundColor,
          valueColor: progressColor,
        );
      },
    );
  }
}
