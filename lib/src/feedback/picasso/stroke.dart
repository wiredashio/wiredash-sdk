import 'package:flutter/material.dart';

enum StrokeType { dot, line }

class Stroke {
  final StrokeType type;
  final List<Offset> path;
  final Color color;
  final double width;

  Stroke(this.type, this.path, this.color, this.width);
}
