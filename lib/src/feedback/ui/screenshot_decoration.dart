import 'dart:math' as math;
import 'package:flutter/widgets.dart';

class ScreenshotDecoration extends Decoration {
  const ScreenshotDecoration(
    this.cornerRadius,
    this.borderThickness,
    this.edgeThickness,
  );

  final double borderThickness;
  final double edgeThickness;
  final double cornerRadius;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _ScreenshotDecorationPainter(
      cornerRadius,
      borderThickness,
      edgeThickness,
    );
  }
}

class _ScreenshotDecorationPainter extends BoxPainter {
  _ScreenshotDecorationPainter(
    this._cornerRadius,
    this._borderThickness,
    this._edgeThickness,
  )   : _strokeWidth = _borderThickness,
        _strokeWidthHalf = _borderThickness / 2;

  final double _borderThickness;
  final double _edgeThickness;
  final double _cornerRadius;
  final double _cornerStrokeLength = 8;

  final double _strokeWidth;
  final double _strokeWidthHalf;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect bounds = offset & configuration.size!;
    _drawDecoration(canvas, bounds);
  }

  void _drawDecoration(Canvas canvas, Rect bounds) {
    final paintCorner = Paint()
      ..color = const Color(0xFF1A56DB)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..strokeWidth = _strokeWidth;

    final paintStroke = Paint()
      ..color = const Color(0xFF1A56DB)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = _strokeWidth;

    final paintRect = Paint()
      ..color = const Color(0xFF1A56DB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _edgeThickness;

    if (_borderThickness == _edgeThickness) {
      // Only draw big border rect
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          bounds.inflate(_strokeWidthHalf),
          Radius.circular(_cornerRadius),
        ),
        paintCorner,
      );

      return;
    }

    final topLeftArc = Rect.fromCircle(
      center: Offset(
        bounds.left + _cornerRadius - _strokeWidthHalf,
        bounds.top + _cornerRadius - _strokeWidthHalf,
      ),
      radius: _cornerRadius,
    );
    final topRightArc = Rect.fromCircle(
      center: Offset(
        bounds.right - _cornerRadius + _strokeWidthHalf,
        bounds.top + _cornerRadius - _strokeWidthHalf,
      ),
      radius: _cornerRadius,
    );
    final bottomLeftArc = Rect.fromCircle(
      center: Offset(
        bounds.left + _cornerRadius - _strokeWidthHalf,
        bounds.bottom - _cornerRadius + _strokeWidthHalf,
      ),
      radius: _cornerRadius,
    );
    final bottomRightArc = Rect.fromCircle(
      center: Offset(
        bounds.right - _cornerRadius + _strokeWidthHalf,
        bounds.bottom - _cornerRadius + _strokeWidthHalf,
      ),
      radius: _cornerRadius,
    );

    final sweepAngle = math.pi / 2;

    // Top left
    canvas.drawArc(topLeftArc, math.pi, sweepAngle, false, paintCorner);
    canvas.drawLine(
      Offset(
        bounds.left + _cornerRadius,
        bounds.top - _strokeWidthHalf,
      ),
      Offset(
        bounds.left + _cornerRadius + _cornerStrokeLength,
        bounds.top - _strokeWidthHalf,
      ),
      paintStroke,
    );
    canvas.drawLine(
      Offset(
        bounds.left - _strokeWidthHalf,
        bounds.top + _cornerRadius,
      ),
      Offset(
        bounds.left - _strokeWidthHalf,
        bounds.top + _cornerRadius + _cornerStrokeLength,
      ),
      paintStroke,
    );

    // Top right
    canvas.drawArc(topRightArc, math.pi * 1.5, sweepAngle, false, paintCorner);
    canvas.drawLine(
      Offset(bounds.right - _cornerRadius, bounds.top - _strokeWidthHalf),
      Offset(bounds.right - _cornerRadius - _cornerStrokeLength,
          bounds.top - _strokeWidthHalf),
      paintStroke,
    );
    canvas.drawLine(
      Offset(
        bounds.right + _strokeWidthHalf,
        bounds.top + _cornerRadius,
      ),
      Offset(
        bounds.right + _strokeWidthHalf,
        bounds.top + _cornerRadius + _cornerStrokeLength,
      ),
      paintStroke,
    );

    // Bottom right
    canvas.drawArc(bottomRightArc, math.pi * 2, sweepAngle, false, paintCorner);
    canvas.drawLine(
      Offset(
        bounds.right + _strokeWidthHalf,
        bounds.bottom - _cornerRadius,
      ),
      Offset(
        bounds.right + _strokeWidthHalf,
        bounds.bottom - _cornerRadius - _cornerStrokeLength,
      ),
      paintStroke,
    );
    canvas.drawLine(
      Offset(
        bounds.right - _cornerRadius,
        bounds.bottom + _strokeWidthHalf,
      ),
      Offset(
        bounds.right - _cornerRadius - _cornerStrokeLength,
        bounds.bottom + _strokeWidthHalf,
      ),
      paintStroke,
    );

    // Bottom left
    canvas.drawArc(
        bottomLeftArc, math.pi * 2.5, sweepAngle, false, paintCorner);
    canvas.drawLine(
      Offset(
        bounds.left + _cornerRadius,
        bounds.bottom + _strokeWidthHalf,
      ),
      Offset(
        bounds.left + _cornerRadius + _cornerStrokeLength,
        bounds.bottom + _strokeWidthHalf,
      ),
      paintStroke,
    );
    canvas.drawLine(
      Offset(
        bounds.left - _strokeWidthHalf,
        bounds.bottom - _cornerRadius,
      ),
      Offset(
        bounds.left - _strokeWidthHalf,
        bounds.bottom - _cornerRadius - _cornerStrokeLength,
      ),
      paintStroke,
    );

    // Draw thin border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        bounds.inflate(_strokeWidthHalf),
        Radius.circular(_cornerRadius),
      ),
      paintRect,
    );
  }
}
