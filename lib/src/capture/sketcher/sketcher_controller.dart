import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:wiredash/src/capture/sketcher/gesture.dart';
import 'package:wiredash/src/capture/sketcher/sketch_painter.dart';
import 'package:wiredash/src/common/theme/wiredash_theme_data.dart';

class SketcherController extends ChangeNotifier {
  final List<Gesture> _gestures = [];
  Color _color = WiredashThemeData.penColors[0];
  Gesture _last;

  Size size = Size.zero;

  Color get color => _color;
  set color(Color newColor) {
    if (_color == newColor) return;
    _color = newColor;
    notifyListeners();
  }

  List<Gesture> get gestures => List.unmodifiable(_gestures);

  void addGesture(Gesture gesture) {
    _gestures.add(gesture);
    _last = gesture;
    notifyListeners();
  }

  void undoGesture() {
    if (_gestures.isNotEmpty) _gestures.removeLast();
    notifyListeners();
  }

  void updateGesture(Offset offset) {
    _last..addPoint(offset)..addPoint(offset);
    notifyListeners();
  }

  void endGesture() {
    // Interpret as a point when less than 5 points recorded
    if (_last.points.length < 5) {
      _gestures.removeLast();
      _gestures.add(_last.firstPoint());
    } else {
      _last.addPoint(_last.points[_last.points.length - 1]);
    }
    notifyListeners();
  }

  void clearGestures() {
    _gestures.clear();
  }

  Future<Uint8List> recordOntoImage(Image image) async {
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final recording = PictureRecorder();
    final canvas = Canvas(
      recording,
      Rect.fromLTWH(0.0, 0.0, imageSize.width, imageSize.height),
    )
      ..drawImage(image, Offset.zero, Paint())
      ..scale(imageSize.width / size.width, imageSize.height / size.height);

    SketchPainter(this).paint(canvas, imageSize);

    final combined = await recording.endRecording().toImage(
          imageSize.width.toInt(),
          imageSize.height.toInt(),
        );

    return (await combined.toByteData(format: ImageByteFormat.png))
        .buffer
        .asUint8List();
  }
}
