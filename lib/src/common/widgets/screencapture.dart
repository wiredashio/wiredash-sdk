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
  State<ScreenCapture> createState() => _ScreenCaptureState();
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

class _ScreenCaptureState extends State<ScreenCapture>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _screenshotFlashAnimation;

  final _repaintBoundaryGlobalKey = GlobalKey();
  MemoryImage? _screenshotMemoryImage;

  @override
  void initState() {
    super.initState();
    widget.controller._state = this;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _screenshotFlashAnimation = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubicEmphasized,
      ),
    );
  }

  Future<ui.Image?> captureScreen() async {
    final canvas = _repaintBoundaryGlobalKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (canvas == null) return null;

    final _screenshot = await canvas.toImage(pixelRatio: 1.5);

    precacheScreenshot(_screenshot).catchError((e, stack) {
      debugPrint(e?.toString());
      debugPrint(stack?.toString());
    });
    return _screenshot;
  }

  Future<void> precacheScreenshot(ui.Image screenshot) async {
    final byteData =
        await screenshot.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    final image = MemoryImage(byteData.buffer.asUint8List());
    try {
      if (!mounted) return;
      await precacheImage(image, context);
    } catch (e) {
      debugPrint(e.toString());
    }
    if (!mounted) return;
    setState(() {
      _screenshotMemoryImage = image;
      _controller.forward(from: 0);
    });
  }

  void releaseScreen() {
    setState(() {
      _screenshotMemoryImage = null;
    });
  }

  Widget _buildScreenshotFlash() {
    return FadeTransition(
      opacity: _screenshotFlashAnimation,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xffffffff),
        ),
        child: SizedBox.expand(),
      ),
    );
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
        if (_screenshotMemoryImage != null) ...[
          Image(image: _screenshotMemoryImage!),
          _buildScreenshotFlash()
        ],
      ],
    );
  }
}
