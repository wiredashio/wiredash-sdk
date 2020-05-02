import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class Screenshot extends StatefulWidget {
  const Screenshot(
      {Key key,
      @required this.capture,
      @required this.onCaptured,
      @required this.child})
      : assert(onCaptured != null),
        assert(child != null),
        super(key: key);

  final bool capture;
  final Function(ui.Image image) onCaptured;
  final Widget child;

  @override
  ScreenshotState createState() => ScreenshotState();
}

class ScreenshotState extends State<Screenshot> {
  final _repaintBoundaryGlobalKey = GlobalKey();

  bool _wasCaptured = false;
  ui.Image _screenshot;
  MemoryImage _screenshotMemoryImage;

  @override
  void didUpdateWidget(Screenshot oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_wasCaptured != widget.capture) {
      _releaseScreen(); // _clearScreenshotFromMemory();

      if (!_wasCaptured) {
        scheduleMicrotask(() => _captureScreen());
      }

      _wasCaptured = widget.capture;
    }
  }

  Future<void> _captureScreen() async {
    print('CAPTURE');
    final canvas = _repaintBoundaryGlobalKey.currentContext.findRenderObject()
        as RenderRepaintBoundary;

    _screenshot = await canvas.toImage(pixelRatio: 1);

    final byteData =
        await _screenshot.toByteData(format: ui.ImageByteFormat.png);

    _screenshotMemoryImage = MemoryImage(byteData.buffer.asUint8List());

    await precacheImage(_screenshotMemoryImage, context);
    widget.onCaptured(_screenshot);
    _screenshot = null;

    setState(() {
      // Update the UI with the screenshot image
    });
  }

  void _releaseScreen() {
    _screenshot = null;
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
          Image(image: _screenshotMemoryImage),
      ],
    );
  }
}
