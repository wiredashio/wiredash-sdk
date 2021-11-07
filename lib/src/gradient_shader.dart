import 'package:flutter/widgets.dart';

class GradientShader extends StatelessWidget {
  const GradientShader({Key? key, required this.child}) : super(key: key);

  final Widget child;

  LinearGradient get gradient => const LinearGradient(
        colors: [
          Color(0xff03A4E5),
          Color(0xff35F1D7),
        ],
      );

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
