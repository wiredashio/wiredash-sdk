import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ScreenCapture extends StatefulWidget {
  const ScreenCapture({
    Key? key,
    required this.controller,
    required this.child,
  }) : super(key: key);

  final ScreenCaptureController controller;
  final Widget child;

  @override
  _ScreenCaptureState createState() => _ScreenCaptureState();
}

class ScreenCaptureController extends ChangeNotifier {
  late _ScreenCaptureState? _state;

  ui.Image? get screenshot => _screenshot;
  ui.Image? _screenshot;

  Future<ui.Image?> captureScreen() async {
    _screenshot = await _state!.captureScreen();
    notifyListeners();
    return _screenshot;
  }

  void releaseScreen() {
    _state!.releaseScreen();
  }
}

class _ScreenCaptureState extends State<ScreenCapture> {
  final _repaintBoundaryGlobalKey = GlobalKey();
  MemoryImage? _screenshotMemoryImage;

  @override
  void initState() {
    super.initState();
    widget.controller._state = this;
  }

  Future<ui.Image?> captureScreen() async {
    final canvas = _repaintBoundaryGlobalKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (canvas == null) return null;

    final _screenshot = await canvas.toImage(pixelRatio: 1.5);

    final byteData =
        await _screenshot.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;

    if (mounted) {
      final image = MemoryImage(byteData.buffer.asUint8List());
      await precacheImage(image, context);

      setState(() {
        _screenshotMemoryImage = image;
      });
    }

    return _screenshot;
  }

  void releaseScreen() {
    setState(() {
      _screenshotMemoryImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Visibility(
          maintainState: true,
          visible: _screenshotMemoryImage == null,
          child: RepaintBoundary(
            key: _repaintBoundaryGlobalKey,
            child: widget.child,
          ),
        ),
        if (_screenshotMemoryImage != null)
          Image(image: _screenshotMemoryImage!),
      ],
    );
  }
}
