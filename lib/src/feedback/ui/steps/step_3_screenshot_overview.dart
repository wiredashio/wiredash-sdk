import 'package:flutter/material.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/widgets/tron_button.dart';
import 'package:wiredash/src/common/widgets/wirecons.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';
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
    if (context.feedbackModel.hasScreenshots) {
      return StepPageScaffold(
        currentStep: 2,
        totalSteps: 3,
        title: Text('Attached screenshots'),
        description: Text('Add, edit or remove images'),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Image.memory(
                    context.feedbackModel.screenshot!,
                    width: 160, // 160
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black38, Colors.black12],
                        ),
                      ),
                      width: 160,
                      alignment: Alignment.center,
                      child: const Icon(
                        Wirecons.trash,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 160,
              height: 100,
              // 100
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: context.theme.secondaryColor,
              ),
              alignment: Alignment.center,
              child: Icon(
                Wirecons.plus,
                color: context.theme.primaryColor,
              ),
            )
          ],
        ),
      );
    } else {
      return StepPageScaffold(
        title: Text('Include a screenshot for more context?'),
        description: Text(
            'You’ll be able to navigate the app and choose when to take a screenshot'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
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
                          onTap: () => context.feedbackModel.goToStep(
                              FeedbackFlowStatus.screenshotNavigating),
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
}
