import 'dart:math' show pi;

import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/translation/wiredash_localizations.dart';

class ColorPicker extends StatelessWidget {
  const ColorPicker({Key? key, required this.selectedColor, this.onChanged})
      : super(key: key);

  final Color selectedColor;
  final void Function(Color color)? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = WiredashTheme.of(context)!;
    final localizations = WiredashLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ColorDot(
          color: theme.firstPenColor,
          selectedColor: selectedColor,
          onChanged: onChanged,
          label: localizations.firstPenLabel,
        ),
        _ColorDot(
          color: theme.secondPenColor,
          selectedColor: selectedColor,
          onChanged: onChanged,
          label: localizations.secondPenLabel,
        ),
        _ColorDot(
          color: theme.thirdPenColor,
          selectedColor: selectedColor,
          onChanged: onChanged,
          label: localizations.thirdPenLabel,
        ),
        _ColorDot(
          color: theme.fourthPenColor,
          selectedColor: selectedColor,
          onChanged: onChanged,
          label: localizations.fourthPenLabel,
        ),
      ],
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    Key? key,
    required this.label,
    required this.color,
    required this.onChanged,
    required Color selectedColor,
  })  : isSelected = color == selectedColor,
        super(key: key);

  final String label;
  final Color color;
  final bool isSelected;
  final Function(Color color)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: () => onChanged?.call(color),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 14,
          ),
          child: SizedBox(
            width: 32,
            height: 32,
            child: CustomPaint(
              painter: _ColorDotPainter(
                color,
                paintRing: isSelected,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorDotPainter extends CustomPainter {
  _ColorDotPainter(
    Color color, {
    required this.paintRing,
  }) : _dotPaint = Paint()..color = color;

  final Paint _dotPaint;
  final Paint _ringPaint = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  final bool paintRing;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    canvas.drawCircle(center, radius, _dotPaint);
    if (paintRing) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 6),
        0,
        pi * 2,
        false,
        _ringPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
