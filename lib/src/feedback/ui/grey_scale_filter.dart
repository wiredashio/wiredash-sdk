import 'package:flutter/widgets.dart';

class GreyScaleFilter extends StatelessWidget {
  const GreyScaleFilter({required this.greyScale, super.key, this.child});

  final Widget? child;
  final double greyScale;

  @override
  Widget build(BuildContext context) {
    final f = 1 - greyScale;
    return ColorFiltered(
      colorFilter: ColorFilter.matrix([
        0.2126 * f + (1 - f), 0.7152 * f, 0.0722 * f, 0, 0, //
        0.2126 * f, 0.7152 * f + (1 - f), 0.0722 * f, 0, 0, //
        0.2126 * f, 0.7152 * f, 0.0722 * f + (1 - f), 0, 0, //
        0, 0, 0, 1 - (f / 2), 0, //
      ]),
      child: child,
    );
  }
}
