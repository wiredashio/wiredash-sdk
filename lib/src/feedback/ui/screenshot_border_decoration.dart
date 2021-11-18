import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/widgets.dart';

/// Draws a border with prominent corners (thicker)
class ScreenshotBorderDecoration extends Decoration {
  const ScreenshotBorderDecoration({
    required this.cornerRadius,
    required this.cornerStrokeWidth,
    required this.edgeStrokeWidth,
    this.cornerExtensionLength = 8.0,
    required this.color,
  }) : assert(edgeStrokeWidth <= cornerStrokeWidth);

  final double cornerStrokeWidth;
  final double edgeStrokeWidth;
  final double cornerRadius;
  final double cornerExtensionLength;
  final Color color;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _ScreenshotDecorationPainter(
      cornerRadius,
      cornerStrokeWidth,
      edgeStrokeWidth,
      cornerExtensionLength,
      color,
    );
  }
}

class _ScreenshotDecorationPainter extends BoxPainter {
  _ScreenshotDecorationPainter(
    this._cornerRadius,
    this._borderThickness,
    this._edgeThickness,
    this._cornerExtensionLength,
    this._color,
  );

  final double _borderThickness;
  final double _edgeThickness;
  final double _cornerRadius;
  final double _cornerExtensionLength;
  final Color _color;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect bounds = offset & configuration.size!;
    _drawDecoration(canvas, bounds);
  }

  void _drawDecoration(Canvas canvas, Rect bounds) {
    final arcPaint = Paint()
      ..color = _color
      ..style = PaintingStyle.fill;

    // Create one of the corner arcs, it will be redrawn for all 4 corners
    final cornerArc = _createCornerArcPath();

    // Add all 4 corners
    final combinedPath = Path();
    combinedPath.addPath(
      cornerArc,
      Offset(bounds.left, bounds.top),
    );
    combinedPath.addPath(
      cornerArc,
      Offset(bounds.right, bounds.top),
      matrix4: Matrix4.rotationY(math.pi).storage,
    );
    combinedPath.addPath(
      cornerArc,
      Offset(bounds.right, bounds.bottom),
      matrix4: Matrix4.rotationZ(math.pi).storage,
    );
    combinedPath.addPath(
      cornerArc,
      Offset(bounds.left, bounds.bottom),
      matrix4: Matrix4.rotationX(math.pi).storage,
    );

    // Add the edges
    final topEdge = Rect.fromLTRB(
      bounds.left + _cornerRadius + _cornerExtensionLength,
      bounds.top - _edgeThickness / 2,
      bounds.right - _cornerRadius - _cornerExtensionLength,
      bounds.top + _edgeThickness / 2,
    );

    final bottomEdge = Rect.fromLTRB(
      bounds.left + _cornerRadius + _cornerExtensionLength,
      bounds.bottom + _edgeThickness / 2,
      bounds.right - _cornerRadius - _cornerExtensionLength,
      bounds.bottom - _edgeThickness / 2,
    );

    final leftEdge = Rect.fromLTRB(
      bounds.left - _edgeThickness / 2,
      bounds.top + _cornerRadius + _cornerExtensionLength,
      bounds.left + _edgeThickness / 2,
      bounds.bottom - _cornerRadius - _cornerExtensionLength,
    );

    final rightEdge = Rect.fromLTRB(
      bounds.right - _edgeThickness / 2,
      bounds.top + _cornerRadius + _cornerExtensionLength,
      bounds.right + _edgeThickness / 2,
      bounds.bottom - _cornerRadius - _cornerExtensionLength,
    );

    // Add each edge twice to fix intersection issues
    combinedPath.addRect(topEdge);
    combinedPath.addRect(topEdge);
    combinedPath.addRect(bottomEdge);
    combinedPath.addRect(bottomEdge);
    combinedPath.addRect(leftEdge);
    combinedPath.addRect(leftEdge);
    combinedPath.addRect(rightEdge);
    combinedPath.addRect(rightEdge);

    canvas.drawPath(combinedPath, arcPaint);
  }

  Path _createCornerArcPath() {
    final halfArcWidth = _borderThickness / 2;

    final path = Path();
    path.moveTo(
      -halfArcWidth,
      _cornerRadius + _cornerExtensionLength,
    );
    path.lineTo(
      -halfArcWidth,
      _cornerRadius,
    );
    path.arcTo(
      Rect.fromLTWH(
        -halfArcWidth,
        -halfArcWidth,
        (_cornerRadius + halfArcWidth) * 2,
        (_cornerRadius + halfArcWidth) * 2,
      ),
      math.pi,
      math.pi / 2,
      false,
    );
    path.lineTo(
      _cornerRadius,
      -halfArcWidth,
    );
    path.lineTo(
      _cornerRadius + _cornerExtensionLength,
      -halfArcWidth,
    );
    path.arcTo(
      Rect.fromLTWH(
        _cornerRadius + _cornerExtensionLength - _borderThickness / 2,
        -halfArcWidth,
        _borderThickness,
        _borderThickness,
      ),
      math.pi * 1.5,
      math.pi,
      false,
    );
    path.lineTo(
      _cornerRadius + _cornerExtensionLength,
      halfArcWidth,
    );
    path.lineTo(
      _cornerRadius,
      halfArcWidth,
    );
    path.arcTo(
      Rect.fromLTWH(
        halfArcWidth,
        halfArcWidth,
        (_cornerRadius - halfArcWidth) * 2,
        (_cornerRadius - halfArcWidth) * 2,
      ),
      math.pi * 1.5,
      -math.pi / 2,
      false,
    );
    path.lineTo(
      halfArcWidth,
      _cornerRadius,
    );
    path.lineTo(
      halfArcWidth,
      _cornerRadius + _cornerExtensionLength,
    );
    path.arcTo(
      Rect.fromLTWH(
        -_borderThickness / 2,
        _cornerExtensionLength + _cornerRadius - halfArcWidth,
        _borderThickness,
        _borderThickness,
      ),
      math.pi * 2,
      math.pi,
      false,
    );
    path.close();

    return path;
  }
}
