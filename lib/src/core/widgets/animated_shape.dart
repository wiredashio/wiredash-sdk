import 'package:flutter/material.dart';

class AnimatedShape extends ImplicitlyAnimatedWidget {
  const AnimatedShape({
    required this.color,
    required this.shape,
    required this.child,
    super.key,
  }) : super(
          curve: Curves.easeInOutCubic,
          duration: const Duration(milliseconds: 150),
        );

  final Color color;
  final ShapeBorder shape;
  final Widget child;

  @override
  AnimatedWidgetBaseState<AnimatedShape> createState() => _AnimatedShapeState();
}

class _AnimatedShapeState extends AnimatedWidgetBaseState<AnimatedShape> {
  ShapeBorderTween? _borderTween;
  ColorTween? _colorTween;

  @override
  Widget build(BuildContext context) {
    return PhysicalShape(
      shadowColor: _colorTween!.evaluate(animation)!,
      color: _colorTween!.evaluate(animation)!,
      clipper: ShapeBorderClipper(
        shape: _borderTween!.evaluate(animation)!,
      ),
      child: widget.child,
    );
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _colorTween = visitor(
      _colorTween,
      widget.color,
      (dynamic value) => ColorTween(begin: value as Color?),
    ) as ColorTween?;

    _borderTween = visitor(
      _borderTween,
      widget.shape,
      (dynamic value) => ShapeBorderTween(begin: value as ShapeBorder),
    ) as ShapeBorderTween?;
  }
}
