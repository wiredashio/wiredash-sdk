import 'package:flutter/material.dart';
import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';

class Step3ScreenshotOverview extends StatefulWidget {
  const Step3ScreenshotOverview({Key? key}) : super(key: key);

  @override
  State<Step3ScreenshotOverview> createState() =>
      _Step3ScreenshotOverviewState();
}

class _Step3ScreenshotOverviewState extends State<Step3ScreenshotOverview> {
  @override
  Widget build(BuildContext context) {
    return AnimatedFadeWidgetSwitcher(
      clipBehavior: Clip.none,
      fadeInOnEnter: false,
      duration: const Duration(milliseconds: 300),
      onSwitch: () {
        WiredashBackdrop.maybeOf(context)?.animateSizeChange = true;
      },
      child: () {
        if (!context.feedbackModel.hasAttachments) {
          return const Step3NotAttachments();
        }
        return const Step3WithGallery();
      }(),
    );
  }
}

class Step3NotAttachments extends StatelessWidget {
  const Step3NotAttachments({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StepPageScaffold(
      indicator: const FeedbackProgressIndicator(
        flowStatus: FeedbackFlowStatus.screenshotsOverview,
      ),
      title: Text(context.l10n.feedbackStep3ScreenshotOverviewTitle),
      breadcrumbTitle:
          Text(context.l10n.feedbackStep3ScreenshotOverviewBreadcrumbTitle),
      description:
          Text(context.l10n.feedbackStep3ScreenshotOverviewDescription),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TronButton(
                  color: context.theme.secondaryColor,
                  leadingIcon: Wirecons.arrow_left,
                  label: context.l10n.feedbackBackButton,
                  onTap: context.feedbackModel.goToPreviousStep,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 10,
                    alignment: WrapAlignment.end,
                    verticalDirection: VerticalDirection.up,
                    runAlignment: WrapAlignment.spaceBetween,
                    children: [
                      TronButton(
                        color: context.theme.secondaryColor,
                        label: context
                            .l10n.feedbackStep3ScreenshotOverviewSkipButton,
                        trailingIcon: Wirecons.chevron_double_right,
                        onTap: () async {
                          if (!context.mounted) return;
                          await context.feedbackModel.skipScreenshot();
                        },
                      ),
                      TronButton(
                        label: context.l10n
                            .feedbackStep3ScreenshotOverviewAddScreenshotButton,
                        trailingIcon: Wirecons.arrow_right,
                        maxWidth: 250,
                        onTap: () => context.feedbackModel
                            .enterScreenshotCapturingMode(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class Step3WithGallery extends StatelessWidget {
  const Step3WithGallery({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StepPageScaffold(
      indicator: const FeedbackProgressIndicator(
        flowStatus: FeedbackFlowStatus.screenshotsOverview,
      ),
      currentStep: 2,
      totalSteps: 3,
      title: Text(context.l10n.feedbackStep3GalleryTitle),
      breadcrumbTitle: Text(context.l10n.feedbackStep3GalleryBreadcrumbTitle),
      description: Text(context.l10n.feedbackStep3GalleryDescription),
      discardLabel: Text(context.l10n.feedbackDiscardButton),
      discardConfirmLabel: Text(context.l10n.feedbackDiscardConfirmButton),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: SizedBox(
                  height: 200,
                  child: Center(
                    child: Row(
                      children: [
                        for (final att in context.feedbackModel.attachments)
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: constraints.maxWidth / 2.5,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: AttachmentPreview(attachment: att),
                            ),
                          ),
                        if (context.feedbackModel.attachments.length < 3)
                          const _NewAttachment(),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TronButton(
                    color: context.theme.secondaryColor,
                    leadingIcon: Wirecons.arrow_left,
                    label: context.l10n.feedbackBackButton,
                    onTap: context.feedbackModel.goToPreviousStep,
                  ),
                  TronButton(
                    label: context.l10n.feedbackNextButton,
                    trailingIcon: Wirecons.arrow_right,
                    onTap: context.feedbackModel.goToNextStep,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class AttachmentPreview extends StatelessWidget {
  const AttachmentPreview({
    Key? key,
    required this.attachment,
  }) : super(key: key);

  final PersistedAttachment attachment;

  @override
  Widget build(BuildContext context) {
    late Widget visual;

    if (attachment is Screenshot) {
      visual = Image.memory(
        attachment.file.data!,
        fit: BoxFit.contain,
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Elevation(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: visual,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: TronButton(
            color: context.theme.primaryContainerColor,
            onTap: () {
              context.feedbackModel.deleteAttachment(attachment);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TronIcon(
                Wirecons.trash,
                color: context.theme.textOnPrimaryContainerColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NewAttachment extends StatelessWidget {
  const _NewAttachment({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Elevation(
      child: AspectRatio(
        aspectRatio: context.theme.windowSize.aspectRatio,
        child: AnimatedClickTarget(
          onTap: () {
            context.feedbackModel.enterScreenshotCapturingMode();
          },
          builder: (context, state, anims) {
            Color hoverColorAdjustment(Color color) {
              if (!state.hovered) {
                return color;
              }
              if (context.theme.brightness == Brightness.dark) {
                return color.lighten(0.02);
              } else {
                return color.darken(0.02);
              }
            }

            return Container(
              width: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color.lerp(
                  context.theme.surfaceColor,
                  context.theme.surfaceColor.darken(0.05),
                  (anims.pressedAnim.value + anims.hoveredAnim.value) * 0.1,
                ),
              ),
              alignment: Alignment.center,
              child: AbsorbPointer(
                child: TronButton(
                  color: state.pressed
                      ? context.theme.primaryContainerColor
                          .let(hoverColorAdjustment)
                      : context.theme.primaryContainerColor
                          .let(hoverColorAdjustment),
                  onTap: () {
                    // nothing but style the button as if it is enabled.
                  },
                  child: TronIcon(
                    Wirecons.plus,
                    color: context.theme.textOnPrimaryContainerColor,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class Elevation extends StatelessWidget {
  const Elevation({Key? key, this.child, this.elevation = 2}) : super(key: key);

  final Widget? child;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.04),
            offset: Offset(0, elevation),
            blurRadius: elevation,
          ),
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.10),
            offset: Offset(0, elevation * 3),
            blurRadius: elevation * 3,
          ),
        ],
      ),
      child: child,
    );
  }
}
