import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class Screenshot extends StatefulWidget {
  const Screenshot({
    Key? key,
    required this.capture,
    this.onCaptured,
    required this.child,
  }) : super(key: key);

  final bool capture;
  final void Function(ui.Image image)? onCaptured;
  final Widget child;

  @override
  ScreenshotState createState() => ScreenshotState();
}

class ScreenshotState extends State<Screenshot> {
  final _repaintBoundaryGlobalKey = GlobalKey();

  bool _wasCaptured = false;
  MemoryImage? _screenshotMemoryImage;

  @override
  void didUpdateWidget(Screenshot oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_wasCaptured != widget.capture) {
      _releaseScreen();

      if (!_wasCaptured) {
        scheduleMicrotask(() => _captureScreen());
      }

      _wasCaptured = widget.capture;
    }
  }

  Future<void> _captureScreen() async {
    final canvas = _repaintBoundaryGlobalKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (canvas == null) {
      return;
    }

    final _screenshot = await canvas.toImage(pixelRatio: 1.5);

    final byteData =
        await _screenshot.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      return;
    }

    final image = MemoryImage(byteData.buffer.asUint8List());
    await precacheImage(image, context);
    setState(() {
      _screenshotMemoryImage = image;
    });
    widget.onCaptured?.call(_screenshot);
  }

  void _releaseScreen() {
    _screenshotMemoryImage = null;
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
