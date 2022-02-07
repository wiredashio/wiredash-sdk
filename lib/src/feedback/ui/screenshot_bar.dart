import 'package:flutter/material.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/widgets/animated_fade_widget_switcher.dart';
import 'package:wiredash/src/common/widgets/tron_button.dart';
import 'package:wiredash/src/common/widgets/wirecons.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';
import 'package:wiredash/src/feedback/ui/feedback_flow.dart';

class ScreenshotBar extends StatelessWidget {
  const ScreenshotBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final feedbackStatus = context.feedbackModel.feedbackFlowStatus;
    Widget? trailing;

    if (feedbackStatus == FeedbackFlowStatus.screenshotNavigating) {
      trailing = TronButton(
        key: const Key('capture'),
        color: context.theme.primaryColor,
        leadingIcon: Wirecons.camera,
        iconOffset: const Offset(-.15, 0),
        label: 'Capture',
        onTap: () => context.feedbackModel.captureScreenshot(),
      );
    }

    if (feedbackStatus == FeedbackFlowStatus.screenshotSaving ||
        feedbackStatus == FeedbackFlowStatus.screenshotDrawing) {
      trailing = TronButton(
        key: const Key('save'),
        color: context.theme.primaryColor,
        leadingIcon: Wirecons.check,
        iconOffset: const Offset(-.15, 0),
        label: 'Save',
        onTap: () {
          context.feedbackModel.createMasterpiece();
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            TronButton(
              label: 'Back',
              leadingIcon: Wirecons.arrow_left,
              color: context.theme.secondaryColor,
              onTap: () {
                context.feedbackModel.cancelScreenshotCapturingMode();
              },
            ),
            if (constraints.maxWidth > 720) ...[
              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(left: 8.0, right: 8.0),
                child: FeedbackProgressIndicator(
                  flowStatus: FeedbackFlowStatus.screenshotsOverview,
                ),
              ),
              const SizedBox(
                height: 28,
                child: VerticalDivider(),
              ),
            ],
            if (constraints.maxWidth > 500) ...[
              const SizedBox(width: 8),
              Expanded(
                flex: 10,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  // TODO animate text changes
                  child: DefaultTextStyle(
                    style: context.theme.appbarTitle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    child: AnimatedFadeWidgetSwitcher(
                      fadeInOnEnter: false,
                      child: () {
                        switch (feedbackStatus) {
                          case FeedbackFlowStatus.screenshotDrawing:
                            return const Text(
                              "Draw to highlight what's important",
                            );
                          case FeedbackFlowStatus.screenshotNavigating:
                            return const Text(
                              'Include a screenshot for more context',
                            );
                          default:
                            return const SizedBox();
                        }
                      }(),
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ] else
              const Spacer(flex: 10),
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 140,
                maxWidth: constraints.maxWidth / 2,
              ).normalize(),
              child: AnimatedFadeWidgetSwitcher(
                fadeInOnEnter: false,
                zoomFactor: 0.5,
                alignment: Alignment.centerRight,
                child: trailing,
              ),
            ),
          ],
        );
      },
    );
  }
}
