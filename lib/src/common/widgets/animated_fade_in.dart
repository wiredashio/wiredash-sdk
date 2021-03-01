import 'package:flutter/widgets.dart';

class AnimatedFadeIn extends StatefulWidget {
  final Key changeKey;
  final Widget child;

  const AnimatedFadeIn({
    Key? key,
    required this.changeKey,
    required this.child,
  }) : super(key: key);

  @override
  _AnimatedFadeInState createState() => _AnimatedFadeInState();
}

class _AnimatedFadeInState extends State<AnimatedFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      value: 1.0,
    );
    _fadeAnimation = CurvedAnimation(
        parent: _animationController, curve: Curves.fastOutSlowIn);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedFadeIn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.changeKey != widget.changeKey) {
      _animationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: widget.child,
    );
  }
}
