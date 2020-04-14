import 'dart:math' show pi;

import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/theme/wiredash_theme_data.dart';

class ColorPicker extends StatefulWidget {
  const ColorPicker({
    Key key,
    @required this.selectedColor,
    @required this.onColorSelected,
  })  : assert(selectedColor != null),
        assert(onColorSelected != null),
        super(key: key);

  final Color selectedColor;
  final Function(Color color) onColorSelected;

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _buildColors(),
    );
  }

  List<Widget> _buildColors() {
    return WiredashThemeData.penColors.map((color) {
      return GestureDetector(
        onTap: () => widget.onColorSelected(color),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: _ColorDot(
            color: color,
            isSelected: widget.selectedColor == color,
          ),
        ),
      );
    }).toList();
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    Key key,
    @required this.color,
    @required this.isSelected,
  })  : assert(color != null),
        assert(isSelected != null),
        super(key: key);

  final Color color;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: CustomPaint(
        painter: _ColorDotPainter(
          color,
          paintRing: isSelected,
        ),
      ),
    );
  }
}

class _ColorDotPainter extends CustomPainter {
  _ColorDotPainter(
    Color color, {
    @required this.paintRing,
  })  : assert(color != null),
        assert(paintRing != null),
        _dotPaint = Paint()..color = color;

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
