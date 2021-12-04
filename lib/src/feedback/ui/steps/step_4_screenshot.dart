import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';
import 'package:wiredash/src/feedback/ui/big_blue_button.dart';
import 'package:wiredash/src/feedback/ui/feedback_flow.dart';
import 'package:wiredash/src/feedback/ui/labeled_button.dart';
import 'package:wiredash/src/feedback/ui/larry_page_view.dart';

class Step4Screenshot extends StatefulWidget {
  const Step4Screenshot({Key? key}) : super(key: key);

  @override
  _Step4ScreenshotState createState() => _Step4ScreenshotState();
}

class _Step4ScreenshotState extends State<Step4Screenshot> {
  @override
  Widget build(BuildContext context) {
    return StepPageScaffold(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'For a better understanding. Do you want to take a screenshot of it?',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            BigBlueButton(
              onTap: () {
                context.feedbackModel.enterCaptureMode();
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
