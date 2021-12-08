import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';
import 'package:wiredash/src/feedback/ui/screenshot_border_decoration.dart';

class ScreenshotAppOverlay extends StatefulWidget {
  const ScreenshotAppOverlay({
    Key? key,
    required this.appRect,
    required this.borderRadius,
  }) : super(key: key);

  final BorderRadius borderRadius;

  /// The position of the app displayed in the layer below this overlay
  final Rect appRect;

  @override
  _ScreenshotAppOverlayState createState() => _ScreenshotAppOverlayState();
}

class _ScreenshotAppOverlayState extends State<ScreenshotAppOverlay>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildPositionedScreenshotDecoration(),
      ],
    );
  }

  Widget _buildPositionedScreenshotDecoration() {
    final isScreenshotTaken = context.feedbackModel.feedbackFlowStatus ==
            FeedbackFlowStatus.screenshotCapturing ||
        context.feedbackModel.feedbackFlowStatus ==
            FeedbackFlowStatus.screenshotDrawing;

    return Positioned.fromRect(
      rect: widget.appRect,
      child: AnimatedScreenshotBorder(
        screenshotTaken: isScreenshotTaken,
        borderRadius: widget.borderRadius,
      ),
    );
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
      builder: (context, child) {
        final inScreenshotMode = context.feedbackModel.feedbackFlowStatus ==
                FeedbackFlowStatus.screenshotNavigating ||
            context.feedbackModel.feedbackFlowStatus ==
                FeedbackFlowStatus.screenshotCapturing ||
            context.feedbackModel.feedbackFlowStatus ==
                FeedbackFlowStatus.screenshotDrawing ||
            context.feedbackModel.feedbackFlowStatus ==
                FeedbackFlowStatus.screenshotSaving;
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
      child: _buildScreenshotFlash(),
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
