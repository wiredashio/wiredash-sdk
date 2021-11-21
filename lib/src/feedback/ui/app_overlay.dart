import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/widgets/gradient_shader.dart';
import 'package:wiredash/src/common/widgets/wirecons.dart';
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

class _AppOverlayState extends State<AppOverlay> with TickerProviderStateMixin {
  InAppSheetInheritedWidget? _currentlyShownDialog;

  late AnimationController _dialogAnimationController;

  late Animation<double> _dialogFadeAnimation;
  late Animation<double> _dialogScaleAnimation;

  @override
  void initState() {
    super.initState();

    _dialogAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    final dialogAnimation = CurvedAnimation(
      parent: _dialogAnimationController,
      curve: Curves.easeOutExpo,
      reverseCurve: Curves.easeInExpo,
    );

    _dialogFadeAnimation = Tween(begin: .0, end: 1.0).animate(dialogAnimation);
    _dialogScaleAnimation = Tween(begin: .8, end: 1.0).animate(dialogAnimation);
  }

  @override
  void dispose() {
    _dialogAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildPositionedDialog(),
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
        child: AnimatedScreenshotButtons(
          status: context.feedbackModel.screenshotStatus,
        ),
      ),
    );
  }

  Widget _buildPositionedScreenshotDecoration() {
    final isScreenshotTaken = context.feedbackModel.screenshotStatus ==
            FeedbackScreenshotStatus.screenshotting ||
        context.feedbackModel.screenshotStatus ==
            FeedbackScreenshotStatus.drawing;

    return Positioned.fromRect(
      rect: widget.appRect,
      child: AnimatedScreenshotBorder(
        screenshotTaken: isScreenshotTaken,
        borderRadius: widget.borderRadius,
      ),
    );
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
}

class AnimatedScreenshotButtons extends StatefulWidget {
  const AnimatedScreenshotButtons({Key? key, required this.status})
      : super(key: key);

  final FeedbackScreenshotStatus status;

  @override
  _AnimatedScreenshotButtonsState createState() =>
      _AnimatedScreenshotButtonsState();
}

class _AnimatedScreenshotButtonsState extends State<AnimatedScreenshotButtons>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _leftButtonFadeAnimation;
  late Animation<Offset> _leftButtonTranslateAnimation;
  late Animation<Offset> _rightButtonTranslateAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    const delayedCurve = Interval(0.5, 1.0, curve: Curves.easeOutCubic);

    _leftButtonFadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    _leftButtonTranslateAnimation =
        Tween(begin: const Offset(.5, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: delayedCurve,
      ),
    );

    _rightButtonTranslateAnimation =
        Tween(begin: const Offset(-.5, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: delayedCurve,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedScreenshotButtons oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.status == FeedbackScreenshotStatus.drawing) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SlideTransition(
          position: _leftButtonTranslateAnimation,
          child: FadeTransition(
            opacity: _leftButtonFadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: BigBlueButton(
                onTap: context.feedbackModel.enterCaptureMode,
                child: const Icon(Wirecons.camera),
              ),
            ),
          ),
        ),
        SlideTransition(
          position: _rightButtonTranslateAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: BigBlueButton(
              onTap: _onNextStepTap,
              child: Icon(_getNextStepIconData()),
            ),
          ),
        ),
      ],
    );
  }

  void _onNextStepTap() {
    switch (widget.status) {
      case FeedbackScreenshotStatus.none:
      case FeedbackScreenshotStatus.navigating:
        context.feedbackModel.takeScreenshot();
        break;
      case FeedbackScreenshotStatus.screenshotting:
        break;
      case FeedbackScreenshotStatus.drawing:
        context.feedbackModel.saveScreenshot();
        break;
    }
  }

  IconData _getNextStepIconData() {
    switch (widget.status) {
      case FeedbackScreenshotStatus.none:
      case FeedbackScreenshotStatus.navigating:
      case FeedbackScreenshotStatus.screenshotting:
        return Wirecons.camera;
      case FeedbackScreenshotStatus.drawing:
        return Wirecons.check;
    }
  }
}

class AnimatedScreenshotBorder extends StatefulWidget {
  const AnimatedScreenshotBorder({
    Key? key,
    required this.screenshotTaken,
    required this.borderRadius,
  }) : super(key: key);

  final bool screenshotTaken;
  final BorderRadius borderRadius;

  @override
  _AnimatedScreenshotBorderState createState() =>
      _AnimatedScreenshotBorderState();
}

class _AnimatedScreenshotBorderState extends State<AnimatedScreenshotBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _screenshotFlashAnimation;
  late Animation<double> _screenshotBorderThicknessAnimation;
  late Animation<double> _screenshotCornerExtentAnimation;
  late Animation<Color?> _screenshotBorderColorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _screenshotFlashAnimation = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.ease,
      ),
    );

    _screenshotBorderThicknessAnimation = Tween(begin: 2.0, end: 6.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeInOutExpo),
      ),
    );

    _screenshotCornerExtentAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOutExpo),
      ),
    );

    _screenshotBorderColorAnimation = ColorTween(
      begin: const Color(0xFF1A56DB),
      end: const Color(0xFF1A56DB),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOutCubic),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedScreenshotBorder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.screenshotTaken) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: _buildScreenshotFlash(),
      builder: (context, child) {
        final inScreenshotMode = context.feedbackModel.screenshotStatus ==
                FeedbackScreenshotStatus.navigating ||
            context.feedbackModel.screenshotStatus ==
                FeedbackScreenshotStatus.screenshotting ||
            context.feedbackModel.screenshotStatus ==
                FeedbackScreenshotStatus.drawing;
        return IgnorePointer(
          child: DecoratedBox(
            decoration: inScreenshotMode
                ? ScreenshotBorderDecoration(
                    borderRadius: widget.borderRadius,
                    cornerStrokeWidth: 6,
                    cornerExtensionLength: Tween(
                      begin: 20.0,
                      end: MediaQuery.of(context).size.shortestSide / 4,
                    ).evaluate(_screenshotCornerExtentAnimation),
                    edgeStrokeWidth: _screenshotBorderThicknessAnimation.value,
                    color: _screenshotBorderColorAnimation.value!,
                  )
                : const BoxDecoration(),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildScreenshotFlash() {
    if (widget.screenshotTaken) {
      return FadeTransition(
        opacity: _screenshotFlashAnimation,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xffffffff),
            borderRadius: widget.borderRadius,
          ),
          child: const SizedBox.expand(),
        ),
      );
    } else {
      return const SizedBox.expand();
    }
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
                    Icon(Wirecons.pencil),
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
