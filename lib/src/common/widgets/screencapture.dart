import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class Screencapture extends StatefulWidget {
  const Screencapture({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  ScreencaptureState createState() => ScreencaptureState();
}

class ScreencaptureState extends State<Screencapture> {
  final _repaintBoundaryGlobalKey = GlobalKey();
  MemoryImage? _screenshotMemoryImage;

  Future<ui.Image?> captureScreen() async {
    final canvas = _repaintBoundaryGlobalKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (canvas == null) return null;

    final _screenshot = await canvas.toImage(pixelRatio: 1.2);

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
