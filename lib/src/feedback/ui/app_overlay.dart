import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/widgets/wiredash_icons.dart';
import 'package:wiredash/src/feedback/ui/big_blue_button.dart';
import 'package:wiredash/src/feedback/ui/screenshot_decoration.dart';
import 'package:wiredash/src/gradient_shader.dart';

class AppOverlay extends StatefulWidget {
  const AppOverlay({
    Key? key,
    required this.appRect,
    required this.borderRadius,
  }) : super(key: key);

  final BorderRadius borderRadius;

  final Rect appRect;

  @override
  _AppOverlayState createState() => _AppOverlayState();
}

enum AppOverlayStatus { none, interactive, drawing }

class _AppOverlayState extends State<AppOverlay> with TickerProviderStateMixin {
  Widget? _currentlyShownDialog;

  late AnimationController _dialogAnimationController;
  late AnimationController _drawingAnimationController;

  AppOverlayStatus _status = AppOverlayStatus.none;

  late Animation<double> _dialogFadeAnimation;
  late Animation<double> _dialogScaleAnimation;
  late Animation<double> _screenshotFlashAnimation;
  late Animation<double> _screenshotBorderAnimation;

  @override
  void initState() {
    super.initState();

    _dialogAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _drawingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    final dialogAnimation = CurvedAnimation(
        parent: _dialogAnimationController,
        curve: Curves.easeOutExpo,
        reverseCurve: Curves.easeInExpo);

    _dialogFadeAnimation = Tween(begin: .0, end: 1.0).animate(dialogAnimation);
    _dialogScaleAnimation = Tween(begin: .8, end: 1.0).animate(dialogAnimation);

    _screenshotFlashAnimation = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _drawingAnimationController,
        curve: Curves.ease,
      ),
    );

    _screenshotBorderAnimation = Tween(begin: 2.0, end: 6.0).animate(
      CurvedAnimation(
        parent: _drawingAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _dialogAnimationController.dispose();
    _drawingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildPositionedDialog(),
        _buildPositionedScreenshotFlash(),
        _buildPositionedScreenshotDecoration(),
        _buildButtons()
      ],
    );
  }

  Widget _buildButtons() {
    return Positioned(
      top: widget.appRect.bottom - 26,
      left: widget.appRect.left,
      right: widget.appRect.left,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          BigBlueButton(
            child: Icon(WiredashIcons.feature),
            onTap: () {
              showDialog(Builder(builder: (context) {
                return _buildDialog();
              }));
            },
          ),
          const SizedBox(width: 8),
          BigBlueButton(
            child: Icon(WiredashIcons.screenshotAction),
            onTap: () {
              switchToDrawingMode();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPositionedScreenshotDecoration() {
    return AnimatedBuilder(
        animation: _screenshotBorderAnimation,
        builder: (context, animation) {
          return Positioned.fromRect(
            rect: widget.appRect,
            child: IgnorePointer(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: DecoratedBox(
                    decoration: ScreenshotDecoration(
                      widget.borderRadius.topLeft.x,
                      6,
                      _screenshotBorderAnimation.value,
                    ),
                    child: SizedBox.fromSize(size: widget.appRect.size)),
              ),
            ),
          );
        });
  }

  Widget _buildPositionedScreenshotFlash() {
    if (_status == AppOverlayStatus.drawing) {
      return Positioned.fromRect(
        rect: widget.appRect,
        child: FadeTransition(
          opacity: _screenshotFlashAnimation,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xffffffff),
              borderRadius: widget.borderRadius,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      );
    } else {
      return const SizedBox.expand();
    }
  }

  Widget _buildPositionedDialog() {
    if (_currentlyShownDialog == null) return const SizedBox.expand();

    return Positioned(
      top: widget.appRect.bottom,
      left: widget.appRect.left,
      right: widget.appRect.left,
      child: SlideTransition(
        position: const AlwaysStoppedAnimation(Offset(0, -1)),
        child: ScaleTransition(
          scale: _dialogScaleAnimation,
          child: FadeTransition(
            opacity: _dialogFadeAnimation,
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: _currentlyShownDialog,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialog() {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            GradientShader(child: Icon(WiredashIcons.spotlightDraw)),
            const SizedBox(height: 12),
            GradientShader(
              child: Text(
                'Navigate the app, then take a screenshot',
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              'Give us something visual to get a better understanding',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text('down'),
            const SizedBox(height: 12),
          ],
        ),
        Positioned(
          right: 0,
          child: MaterialButton(
            onPressed: _dismissDialog,
            child: Text('Close'),
          ),
        )
      ],
    );
  }

  Future<void> _dismissDialog() async {
    if (_currentlyShownDialog != null) {
      await _dialogAnimationController.reverse();

      setState(() {
        _currentlyShownDialog = null;
      });
    }
  }

  Future<void> showDialog(Widget child) async {
    await _dismissDialog();

    setState(() {
      _currentlyShownDialog = child;
      _dialogAnimationController.forward(from: 0);
    });
  }

  Future<void> switchToInteractiveMode() async {
    setState(() {
      _status = AppOverlayStatus.interactive;
      _drawingAnimationController.reverse();
    });
  }

  Future<void> switchToDrawingMode() async {
    _dismissDialog();

    setState(() {
      _status = AppOverlayStatus.drawing;
      _drawingAnimationController.forward(from: 0);
    });
  }
}
