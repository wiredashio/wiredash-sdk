import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';
import 'package:wiredash/src/feedback/ui/big_blue_button.dart';
import 'package:wiredash/src/feedback/ui/feedback_flow.dart';
import 'package:wiredash/src/feedback/ui/labeled_button.dart';
import 'package:wiredash/src/feedback/ui/larry_page_view.dart';

class Step4ScreenshotSaving extends StatefulWidget {
  const Step4ScreenshotSaving({Key? key}) : super(key: key);

  @override
  _Step4ScreenshotSavingState createState() => _Step4ScreenshotSavingState();
}

class _Step4ScreenshotSavingState extends State<Step4ScreenshotSaving> {
  @override
  Widget build(BuildContext context) {
    return StepPageScaffold(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'For a better understanding. Do you want to take a screenshot of it?\n'
              'Screenshot saving',
              style: context.theme.titleTextStyle,
            ),
            const SizedBox(height: 32),
            BigBlueButton(
              onTap: () {
                context.feedbackModel
                    .goToStep(FeedbackFlowStatus.screenshotsOverview);
              },
              child: const Text("Yes"),
            ),
            const SizedBox(height: 64),
            LabeledButton(
              onTap: () {
                StepInformation.of(context).pageView.moveToNextPage();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Text("I'm done"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
