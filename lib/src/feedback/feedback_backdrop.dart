import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';
import 'package:wiredash/src/core/support/back_button_interceptor.dart';

/// The backdrop for [WiredashFlow.feedback]
class FeedbackBackdrop extends StatelessWidget {
  const FeedbackBackdrop({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return WiredashBackdrop(
      controller: context.wiredashModel.services.backdropController,
      padding: context.wiredashModel.services.wiredashWidget.padding,
      app: ScreenCapture(
        controller: context.wiredashModel.services.screenCaptureController,
        child: child,
      ),
      contentBuilder: (context) {
        return WiredashFeedbackFlow(
          // this allows discarding feedback in the message step
          key: ValueKey(context.watchFeedbackModel),
        );
      },
      foregroundLayerBuilder: (c, r, mq) {
        return _buildForegroundLayer(c, r, mq);
      },
      backgroundLayerBuilder: (c, r, mq) {
        return _buildBackgroundLayer(c, r, mq);
      },
    );
  }
}

Widget? _buildForegroundLayer(
  BuildContext context,
  Rect appRect,
  MediaQueryData mediaQueryData,
) {
  final List<Widget> stackChildren = [];

  final services = context.wiredashModel.services;
  final status = services.backdropController.backdropStatus;
  final animatingCenter = status == WiredashBackdropStatus.openingCentered ||
      status == WiredashBackdropStatus.closingCentered;
  if (animatingCenter || status == WiredashBackdropStatus.centered) {
    final topBar = SafeArea(
      bottom: false,
      left: false,
      right: false,
      child: SizedBox(
        height: double.infinity,
        child: BackButtonInterceptor(
          onBackPressed: () {
            if (status == WiredashBackdropStatus.openingCentered ||
                status == WiredashBackdropStatus.centered) {
              if (services.picassoController.canUndo()) {
                services.picassoController.undo();
                return BackButtonAction.consumed;
              }

              context.readFeedbackModel.cancelScreenshotCapturingMode();
              return BackButtonAction.consumed;
            }
            return BackButtonAction.ignored;
          },
          child: const ScreenshotBar(),
        ),
      ),
    );

    stackChildren.add(
      SizedBox(
        height: appRect.top,
        width: double.infinity,
        child: Padding(
          // padding: EdgeInsets.zero,
          padding: EdgeInsets.only(
            left: appRect.left,
            right: appRect.left,
          ),
          child: AnimatedFadeWidgetSwitcher(
            // hide buttons early when exiting centered
            child: status == WiredashBackdropStatus.openingCentered ||
                    status == WiredashBackdropStatus.centered
                ? topBar
                : null,
          ),
        ),
      ),
    );

    final bottomBar = Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedSlide(
        duration: const Duration(seconds: 1),
        curve: const Interval(
          0.5,
          1,
          curve: Curves.easeOutCirc,
        ),
        offset: Offset(
          0,
          context.watchFeedbackModel.feedbackFlowStatus ==
                  FeedbackFlowStatus.screenshotDrawing
              ? 0
              : 1,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: ColorPalette(
            colors: [
              context.theme.firstPenColor,
              context.theme.secondPenColor,
              context.theme.thirdPenColor,
              context.theme.fourthPenColor,
            ],
            initialSelection: services.picassoController.color ?? Colors.black,
            initialStrokeWidth: services.picassoController.strokeWidth,
            onNewColorSelected: (color) =>
                services.picassoController.color = color,
            onNewStrokeWidthSelected: (width) =>
                services.picassoController.strokeWidth = width,
            onUndo: services.picassoController.undo,
          ),
        ),
      ),
    );

    // poor way to prevent overflow during enter/exit anim
    if (!animatingCenter) {
      stackChildren.add(bottomBar);
    }
  }

  if (stackChildren.isEmpty) {
    return null;
  }
  return Stack(children: stackChildren);
}

Widget? _buildBackgroundLayer(
  BuildContext context,
  Rect appRect,
  MediaQueryData mediaQueryData,
) {
  final List<Widget> stackChildren = [];

  final services = context.wiredashModel.services;
  final status = services.backdropController.backdropStatus;
  final animatingCenter = status == WiredashBackdropStatus.openingCentered ||
      status == WiredashBackdropStatus.closingCentered;
  if (animatingCenter || status == WiredashBackdropStatus.centered) {
    if (appRect.width < 500) {
      final bottomText = Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          height: math.max(mediaQueryData.size.height - appRect.bottom, 0),
          width: appRect.width,
          child: SafeArea(
            top: false,
            left: false,
            right: false,
            child: AnimatedSlide(
              duration: const Duration(seconds: 1),
              curve: const Interval(
                0.5,
                1,
                curve: Curves.easeOutCirc,
              ),
              offset: Offset(
                0,
                context.watchFeedbackModel.feedbackFlowStatus ==
                        FeedbackFlowStatus.screenshotNavigating
                    ? 0
                    : 4,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    context.l10n.feedbackStep3ScreenshotBottomBarTitle,
                    style: context.text.appbarTitle.onBackground,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      stackChildren.add(bottomText);
    }
  }

  if (stackChildren.isEmpty) {
    return null;
  }
  return Stack(children: stackChildren);
}
