import 'package:flutter/material.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';
import 'package:wiredash/src/feedback/ui/feedback_flow.dart';
import 'package:wiredash/src/feedback/ui/labeled_button.dart';

class Step6Submit extends StatefulWidget {
  const Step6Submit({Key? key}) : super(key: key);

  @override
  _Step6SubmitState createState() => _Step6SubmitState();
}

class _Step6SubmitState extends State<Step6Submit> {
  @override
  Widget build(BuildContext context) {
    return StepPageScaffold(
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(seconds: 1),
          child: () {
            final feedbackModel = context.feedbackModel;
            if (feedbackModel.submitted) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check,
                    size: 64,
                    color: context.theme.primaryColor,
                  ),
                  const SizedBox(height: 8),
                  const Text("Submitted"),
                  const SizedBox(height: 32),
                  LabeledButton(
                    onTap: () {
                      context.feedbackModel.returnToAppPostSubmit();
                    },
                    child: const Text(
                      'Back to app',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }

            if (feedbackModel.submitting) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo_white.png',
                    package: 'wiredash',
                    height: 64,
                    color: context.theme.primaryColor,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Submitting",
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            } else {
              return const Text("Submit your feedback now");
            }
          }(),
        ),
      ),
    );
  }
}
