import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';
import 'package:wiredash/src/feedback/picasso/picasso.dart';
import 'package:wiredash/src/feedback/ui/grey_scale_filter.dart';

class ScreenCapture extends StatefulWidget {
  const ScreenCapture({
    super.key,
    required this.controller,
    required this.child,
  });

  final ScreenCaptureController controller;
  final Widget child;

  @override
  State<ScreenCapture> createState() => _ScreenCaptureState();
}

class _ScreenCaptureState extends State<ScreenCapture>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _screenshotFlashAnimation;

  final _repaintBoundaryGlobalKey = GlobalKey();
  MemoryImage? _screenshotMemoryImage;
  ui.Size? _screenshotSize;

  static const _screenshotPixelRatio = 1.5;

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
    widget.controller.addListener(_repaint);
  }

  @override
  void didUpdateWidget(covariant ScreenCapture oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller._state = null;
      oldWidget.controller.removeListener(_repaint);
      widget.controller._state = this;
      widget.controller.addListener(_repaint);
    }
  }

  void _repaint() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller._state = null;
    widget.controller.removeListener(_repaint);
    _controller.dispose();
    super.dispose();
  }

  Future<ui.Image?> captureScreen() async {
    final canvas = _repaintBoundaryGlobalKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (canvas == null) return null;

    final screenshot = await canvas.toImage(pixelRatio: _screenshotPixelRatio);

    await precacheScreenshot(screenshot).catchError((e, stack) {
      debugPrint(e?.toString());
      debugPrint(stack?.toString());
    });
    return screenshot;
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
      _screenshotSize = Size(
        screenshot.width.toDouble() / _screenshotPixelRatio,
        screenshot.height.toDouble() / _screenshotPixelRatio,
      );
      _controller.forward(from: 0);
    });
  }

  void releaseScreen() {
    setState(() {
      _screenshotMemoryImage = null;
    });
  }

  Widget _buildScreenshotFlash() {
    return IgnorePointer(
      child: FadeTransition(
        opacity: _screenshotFlashAnimation,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
          child: SizedBox.expand(),
        ),
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
          child: GreyScaleFilter(
            greyScale: widget.controller._error != null ? 0.0 : 1.0,
            child: RepaintBoundary(
              key: _repaintBoundaryGlobalKey,
              child: widget.child,
            ),
          ),
        ),
        if (_screenshotMemoryImage != null) ...[
          // Allow overflow to right/bottom when screen becomes smaller
          Positioned(
            top: 0,
            left: 0,
            // Once the screenshot is made, resizing isn't allowed anymore
            child: SizedBox.fromSize(
              size: _screenshotSize,
              // Don't show drawings outside of Picasso
              child: ClipRect(
                // keep Picasso directly connected to the Image so they scale equally
                child: Picasso(
                  controller: context.wiredashModel.services.picassoController,
                  child: Image(image: _screenshotMemoryImage!),
                ),
              ),
            ),
          ),
          _buildScreenshotFlash(),
        ],
        AnimatedFadeWidgetSwitcher(
          duration: const Duration(milliseconds: 1000),
          child: () {
            if (widget.controller._error != null) {
              return ColoredBox(
                color: const Color(0xa0000000),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.theme.horizontalPadding,
                    vertical: context.theme.verticalPadding,
                  ),
                  child: Center(
                    child: ErrorWidget(_screenshotTakenErrorMessage),
                  ),
                ),
              );
            }
            return const SizedBox();
          }(),
        ),
      ],
    );
  }
}

const String _screenshotTakenErrorMessage = '''
Error while taking screenshot

Some UI elements in the app are not able to be rendered correctly. You might be able to take a screenshot on a different screen.

This rendering error is usually caused by platform widgets, such as the PointerInterceptor, that include plain HTML elements in canvaskit. Developers might be able to work around this bug by using Wiredashs 'Confidential' Widget, hiding buggy widgets when taking screenshots.

See github.com/flutter/flutter/issues/101720 for more information
''';

class ScreenCaptureController extends ChangeNotifier {
  late _ScreenCaptureState? _state;

  ui.Image? get screenshot => _screenshot;
  ui.Image? _screenshot;
  FlutterErrorDetails? _error;
  FlutterErrorDetails? get error => _error;

  Future<ui.Image?> captureScreen() async {
    try {
      _screenshot = await _state!.captureScreen();
    } catch (e, stack) {
      _error = reportWiredashError(e, stack, _screenshotTakenErrorMessage);
    }
    notifyListeners();
    return _screenshot;
  }

  void releaseScreen() {
    _error = null;
    _screenshot = null;
    _state?.releaseScreen();
    notifyListeners();
  }
}
