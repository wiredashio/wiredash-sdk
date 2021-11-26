import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';
import 'package:wiredash/src/feedback/ui/big_blue_button.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.theme.horizontalPadding,
            vertical: 16,
          ),
          child: const Text(
            'For a better understanding. Do you want to take a screenshot of it?',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.theme.horizontalPadding,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
      ],
    );
  }
}
