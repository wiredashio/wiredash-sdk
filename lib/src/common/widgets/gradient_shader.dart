import 'package:flutter/widgets.dart';

class GradientShader extends StatelessWidget {
  const GradientShader({
    Key? key,
    required this.gradient,
    required this.child,
  }) : super(key: key);

  final Widget child;

  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: child,
    );
  }
}
