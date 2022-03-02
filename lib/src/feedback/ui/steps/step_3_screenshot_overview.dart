import 'package:flutter/material.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/utils/color_ext.dart';
import 'package:wiredash/src/common/widgets/tron_button.dart';
import 'package:wiredash/src/common/widgets/tron_icon.dart';
import 'package:wiredash/src/common/widgets/wirecons.dart';
import 'package:wiredash/src/feedback/data/persisted_feedback_item.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';
import 'package:wiredash/src/feedback/ui/base_click_target.dart';
import 'package:wiredash/src/feedback/ui/feedback_flow.dart';

class Step3ScreenshotOverview extends StatefulWidget {
  const Step3ScreenshotOverview({Key? key}) : super(key: key);

  @override
  State<Step3ScreenshotOverview> createState() =>
      _Step3ScreenshotOverviewState();
}

class _Step3ScreenshotOverviewState extends State<Step3ScreenshotOverview> {
  @override
  Widget build(BuildContext context) {
    if (!context.feedbackModel.hasAttachments) {
      return const Step3NotAttachments();
    }
    return const Step3WithGallery();
  }
}

class Step3NotAttachments extends StatelessWidget {
  const Step3NotAttachments({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StepPageScaffold(
      flowStatus: FeedbackFlowStatus.screenshotsOverview,
      title: const Text('Include a screenshot for more context?'),
      shortTitle: const Text('Screenshots'),
      description: const Text(
        'You’ll be able to navigate the app and choose when to take a screenshot',
      ),
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
                  label: 'Back',
                  onTap: context.feedbackModel.goToPreviousStep,
                ),
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
                        label: 'Skip',
                        trailingIcon: Wirecons.chevron_double_right,
                        onTap: context.feedbackModel.goToNextStep,
                      ),
                      // const SizedBox(width: 12),
                      TronButton(
                        label: 'Add screenshot',
                        trailingIcon: Wirecons.arrow_right,
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
      flowStatus: FeedbackFlowStatus.screenshotsOverview,
      currentStep: 2,
      totalSteps: 3,
      title: const Text('Attached screenshots'),
      shortTitle: const Text('Screenshots'),
      description: const Text('Add, edit or remove images'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              height: 200,
              child: Row(
                children: [
                  for (final att in context.feedbackModel.attachments)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _Attachment(attachment: att),
                    ),
                  const _NewAttachment(),
                ],
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
                label: 'Back',
                onTap: context.feedbackModel.goToPreviousStep,
              ),
              TronButton(
                label: 'Next',
                trailingIcon: Wirecons.arrow_right,
                onTap: context.feedbackModel.goToNextStep,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Attachment extends StatelessWidget {
  const _Attachment({
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
            borderRadius: BorderRadius.circular(2),
            child: visual,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: TronButton(
            color: context.theme.secondaryBackgroundColor,
            onTap: () {
              context.feedbackModel.deleteAttachment(attachment);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TronIcon(
                Wirecons.trash,
                color: context.theme.primaryColor,
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
            return Container(
              width: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color.lerp(
                  context.theme.secondaryColor,
                  context.theme.primaryColor,
                  anims.pressedAnim.value * 0.2,
                )!
                    .darken(anims.hoveredAnim.value * 0.05),
              ),
              alignment: Alignment.center,
              child: AbsorbPointer(
                child: TronButton(
                  color: context.theme.secondaryBackgroundColor,
                  // onTap: ,
                  child: TronIcon(
                    Wirecons.plus,
                    color: context.theme.primaryColor,
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
    return Container(
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
