import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AnimatedShape extends ImplicitlyAnimatedWidget {
  const AnimatedShape({
    required this.color,
    required this.shape,
    required this.child,
    Key? key,
  }) : super(
          key: key,
          curve: Curves.easeInOutCubic,
          duration: const Duration(milliseconds: 150),
        );

  final Color color;
  final ShapeBorder shape;
  final Widget child;

  @override
  _AnimatedShapeState createState() => _AnimatedShapeState();
}

class _AnimatedShapeState extends AnimatedWidgetBaseState<AnimatedShape> {
  ShapeBorderTween? _borderTween;
  ColorTween? _colorTween;

  @override
  Widget build(BuildContext context) {
    return PhysicalShape(
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
