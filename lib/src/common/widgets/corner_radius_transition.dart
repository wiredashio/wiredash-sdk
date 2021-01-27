import 'package:flutter/material.dart';

class CornerRadiusTransition extends AnimatedWidget {
  const CornerRadiusTransition({
    Key? key,
    required this.radius,
    required this.child,
  }) : super(key: key, listenable: radius);

  final Animation<double> radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      shadowColor: const Color(0xffe5e7eb),
      borderRadius: BorderRadius.lerp(
          BorderRadius.circular(0), BorderRadius.circular(16), radius.value),
      clipBehavior: Clip.antiAlias,
      animationDuration: Duration.zero,
      child: child,
    );
  }
}
