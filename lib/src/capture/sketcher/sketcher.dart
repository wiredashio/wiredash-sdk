import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wiredash/src/capture/sketcher/sketcher_model.dart';
import 'package:wiredash/src/capture/state/capture_state.dart';

class Sketcher extends StatefulWidget {
  const Sketcher({
    Key key,
    @required this.isEnabled,
    @required this.color,
    @required this.child,
  })  : assert(isEnabled != null),
        assert(color != null),
        assert(child != null),
        super(key: key);

  final bool isEnabled;
  final Color color;
  final Widget child;

  @override
  SketcherState createState() => SketcherState();
}

class SketcherState extends State<Sketcher> {
  final _sketcherRepaintBoundaryGlobalKey = GlobalKey();
  bool _wasEnabled = false;

  ui.Image _screenshotImage;
  MemoryImage _screenshotMemoryImage;

  @override
  void didUpdateWidget(Sketcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_wasEnabled != widget.isEnabled) {
      _clearScreenshot();

      if (!_wasEnabled) {
        _captureScreenshot();
      }

      CaptureState.of(context).sketcherModel.clearGestures();
      _wasEnabled = widget.isEnabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.isEnabled
          ? HitTestBehavior.opaque
          : HitTestBehavior.translucent,
      onPanDown: widget.isEnabled ? _onPanDown : null,
      onPanUpdate: widget.isEnabled ? _onPanUpdate : null,
      onPanEnd: widget.isEnabled ? _onPanEnd : null,
      child: AbsorbPointer(
        absorbing: widget.isEnabled,
        child: ClipRect(
          child: CustomPaint(
            foregroundPainter:
                _SketchPainter(CaptureState.of(context).sketcherModel),
            isComplex: true,
            willChange: true,
            child: Stack(
              children: <Widget>[
                Visibility(
                  maintainState: true,
                  visible: _screenshotMemoryImage == null,
                  child: AbsorbPointer(
                    absorbing: _screenshotMemoryImage != null,
                    child: RepaintBoundary(
                      key: _sketcherRepaintBoundaryGlobalKey,
                      child: widget.child,
                    ),
                  ),
                ),
                if (_screenshotMemoryImage != null)
                  Image(image: _screenshotMemoryImage),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onPanDown(DragDownDetails details) {
    CaptureState.of(context).sketcherModel.addGesture(
        SketcherGesture.startLine(widget.color, details.localPosition));
  }

  void _onPanUpdate(DragUpdateDetails details) {
    CaptureState.of(context).sketcherModel.updateGesture(details.localPosition);
  }

  void _onPanEnd(DragEndDetails details) {
    CaptureState.of(context).sketcherModel.endGesture();
  }

  Future<void> _captureScreenshot() async {
    _screenshotImage = await _getScreenshot();
    final byteData =
        await _screenshotImage.toByteData(format: ui.ImageByteFormat.png);
    _screenshotMemoryImage = MemoryImage(byteData.buffer.asUint8List());
    await precacheImage(_screenshotMemoryImage, context);

    setState(() {
      // Update the UI with the screenshot image
    });
  }

  Future<ui.Image> _getScreenshot() {
    final canvas = _sketcherRepaintBoundaryGlobalKey.currentContext
        .findRenderObject() as RenderRepaintBoundary;
    return canvas.toImage(pixelRatio: 1.5);
  }

  void _clearScreenshot() {
    _screenshotImage = null;
    _screenshotMemoryImage = null;
  }

  Future<Uint8List> getSketch() async {
    final size = Size(
        _screenshotImage.width.toDouble(), _screenshotImage.height.toDouble());
    final recording = ui.PictureRecorder();
    final sketcherModel = CaptureState.of(context).sketcherModel;
    final canvas =
        Canvas(recording, Rect.fromLTWH(0.0, 0.0, size.width, size.height))
          ..drawImage(_screenshotImage, Offset.zero, Paint())
          ..scale(size.width / sketcherModel.size.width,
              size.height / sketcherModel.size.height);
    _SketchPainter(sketcherModel).paint(canvas, size);
    final combined = await recording
        .endRecording()
        .toImage(size.width.toInt(), size.height.toInt());
    return (await combined.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }
}

class _SketchPainter extends CustomPainter {
  _SketchPainter(this.model)
      : assert(model != null),
        super(repaint: model);

  final SketcherModel model;

  @override
  void paint(Canvas canvas, Size size) {
    model.size = size;

    for (final gesture in model.gestures) {
      canvas.drawPoints(gesture.mode, gesture.points, gesture.paint);
    }
  }

  @override
  bool shouldRepaint(_SketchPainter oldDelegate) => oldDelegate.model != model;
}
