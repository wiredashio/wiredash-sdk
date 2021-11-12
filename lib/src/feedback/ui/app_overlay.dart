import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/widgets/gradient_shader.dart';
import 'package:wiredash/src/common/widgets/wiredash_icons.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';
import 'package:wiredash/src/feedback/ui/big_blue_button.dart';
import 'package:wiredash/src/feedback/ui/screenshot_border_decoration.dart';

class AppOverlay extends StatefulWidget {
  const AppOverlay({
    Key? key,
    required this.appRect,
    required this.borderRadius,
  }) : super(key: key);

  final BorderRadius borderRadius;

  /// The position of the app displayed in the layer below this overlay
  final Rect appRect;

  @override
  _AppOverlayState createState() => _AppOverlayState();
}

enum AppOverlayStatus {
  none,
  interactive,
  drawing,
}

class _AppOverlayState extends State<AppOverlay> with TickerProviderStateMixin {
  InAppSheetInheritedWidget? _currentlyShownDialog;

  late AnimationController _dialogAnimationController;
  late AnimationController _drawingAnimationController;

  AppOverlayStatus _status = AppOverlayStatus.none;

  late Animation<double> _dialogFadeAnimation;
  late Animation<double> _dialogScaleAnimation;
  late Animation<double> _screenshotFlashAnimation;
  late Animation<double> _screenshotBorderThicknessAnimation;
  late Animation<double> _screenshotCornerExtentAnimation;
  late Animation<Color?> _screenshotBorderColorAnimation;

  InAppSheet? _drawIntroInAppSheet;

  @override
  void initState() {
    super.initState();

    _dialogAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _drawingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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
        curve: const Interval(0.0, 0.7, curve: Curves.ease),
      ),
    );

    _screenshotBorderThicknessAnimation = Tween(begin: 2.0, end: 6.0).animate(
      CurvedAnimation(
        parent: _drawingAnimationController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeInOutExpo),
      ),
    );

    _screenshotCornerExtentAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _drawingAnimationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOutExpo),
      ),
    );

    _screenshotBorderColorAnimation = ColorTween(
      begin: const Color(0xFF1A56DB),
      end: const Color(0xFF1A56DB),
    ).animate(
      CurvedAnimation(
        parent: _drawingAnimationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOutCubic),
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
        _buildButtons(),
      ],
    );
  }

  Widget _buildButtons() {
    return Visibility(
      visible: context.feedbackModel.screenshotStatus !=
          FeedbackScreenshotStatus.none,
      child: Positioned(
        top: widget.appRect.bottom - 26,
        left: widget.appRect.left,
        right: widget.appRect.left,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            BigBlueButton(
              child: const Icon(WiredashIcons.feature),
              onTap: () async {
                if (_drawIntroInAppSheet?.isDismissed == false) {
                  _drawIntroInAppSheet!.dismiss();
                  _drawIntroInAppSheet = null;
                } else {
                  _drawIntroInAppSheet = showInAppSheet((_) {
                    return const DrawIntroSheet();
                  });
                }
              },
            ),
            const SizedBox(width: 8),
            BigBlueButton(
              child: const Icon(WiredashIcons.screenshotAction),
              onTap: () {
                if (_status == AppOverlayStatus.drawing) {
                  switchToInteractiveMode();
                } else if (_status == AppOverlayStatus.interactive ||
                    _status == AppOverlayStatus.none) {
                  switchToDrawingMode();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionedScreenshotDecoration() {
    return AnimatedBuilder(
      animation: _drawingAnimationController,
      builder: (context, animation) {
        return Positioned.fromRect(
          rect: widget.appRect,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: ScreenshotBorderDecoration(
                cornerRadius: widget.borderRadius.topLeft.x,
                cornerStrokeWidth: 6,
                cornerExtensionLength: Tween(
                        begin: 20.0,
                        end: MediaQuery.of(context).size.shortestSide / 4)
                    .evaluate(_screenshotCornerExtentAnimation),
                edgeStrokeWidth: _screenshotBorderThicknessAnimation.value,
                color: _screenshotBorderColorAnimation.value!,
              ),
              child: SizedBox.fromSize(size: widget.appRect.size),
            ),
          ),
        );
      },
    );
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
                boxShadow: const [
                  BoxShadow(
                    offset: Offset(0, 2),
                    blurRadius: 1,
                    spreadRadius: 1,
                    color: Colors.black26,
                  ),
                ],
              ),
              child: _currentlyShownDialog,
            ),
          ),
        ),
      ),
    );
  }

  InAppSheet showInAppSheet(Widget Function(BuildContext context) builder) {
    final sheet = InAppSheet(
      onDismiss: () async {
        await _dialogAnimationController.reverse();

        setState(() {
          _currentlyShownDialog = null;
        });
      },
    );

    void addNewSheet() {
      setState(() {
        _currentlyShownDialog = InAppSheetInheritedWidget(
          sheet: sheet,
          child: Builder(builder: builder),
        );
        _dialogAnimationController.forward(from: 0);
      });
    }

    final oldDialog = _currentlyShownDialog;
    if (oldDialog != null) {
      _dialogAnimationController.reverse().then((_) {
        addNewSheet();
      });
    } else {
      addNewSheet();
    }

    return sheet;
  }

  Future<void> switchToInteractiveMode() async {
    setState(() {
      _status = AppOverlayStatus.interactive;
      _drawingAnimationController.reverse();
    });
  }

  Future<void> switchToDrawingMode() async {
    setState(() {
      _status = AppOverlayStatus.drawing;
      _drawingAnimationController.forward(from: 0);
    });
  }
}

class DrawIntroSheet extends StatelessWidget {
  const DrawIntroSheet({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GradientShader(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff03A4E5),
                    Color(0xff35F1D7),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(height: 12),
                    Icon(WiredashIcons.spotlightDraw),
                    SizedBox(height: 12),
                    Text(
                      'Navigate the app, then take a screenshot',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Text(
                'Give us something visual to get a better understanding',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text('down'),
              const SizedBox(height: 12),
            ],
          ),
        ),
        Positioned(
          right: 0,
          child: MaterialButton(
            onPressed: () {
              InAppSheet.of(context).dismiss();
            },
            child: const Text('Close'),
          ),
        )
      ],
    );
  }
}

class InAppSheet {
  InAppSheet({
    required FutureOr<void> Function() onDismiss,
  }) : _onDismiss = onDismiss;

  final FutureOr<void> Function() _onDismiss;

  Future<void> dismiss() async {
    await _onDismiss();
    _dismissed = true;
  }

  bool get isDismissed => _dismissed;
  bool _dismissed = false;

  static InAppSheet of(BuildContext context) {
    final InAppSheetInheritedWidget? widget =
        context.dependOnInheritedWidgetOfExactType<InAppSheetInheritedWidget>();
    return widget!.sheet;
  }
}

class InAppSheetInheritedWidget extends InheritedWidget {
  const InAppSheetInheritedWidget({
    Key? key,
    required this.sheet,
    required Widget child,
  }) : super(key: key, child: child);

  final InAppSheet sheet;

  @override
  bool updateShouldNotify(InAppSheetInheritedWidget old) => sheet != old.sheet;
}
