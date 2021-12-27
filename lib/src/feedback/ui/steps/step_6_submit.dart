import 'package:flutter/material.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/widgets/wirecons.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';
import 'package:wiredash/src/feedback/ui/feedback_flow.dart';

class Step6Submit extends StatefulWidget {
  const Step6Submit({Key? key}) : super(key: key);

  @override
  State<Step6Submit> createState() => _Step6SubmitState();
}

class _Step6SubmitState extends State<Step6Submit> {
  @override
  Widget build(BuildContext context) {
    return StepPageScaffold(
      child: SafeArea(
        child: Builder(
          builder: (context) {
            final submitting = context.feedbackModel.submitting;
            if (submitting) {
              return ScrollBox(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 24,
                      ),
                      Icon(
                        Wirecons.arrow_right,
                        size: 48,
                        color: context.theme.primaryColor,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Submitting your feedback',
                        textAlign: TextAlign.center,
                        style: context.theme.titleTextStyle,
                      ),
                    ],
                  ),
                ),
              );
            }

            final error = context.feedbackModel.submissionError;
            if (error != null) {
              return ScrollBox(
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 36,
                      ),
                      Icon(
                        Wirecons.x_circle,
                        size: 48,
                        color: context.theme.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Feedback submission failed',
                        style: context.theme.titleTextStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Theme(
                        data: ThemeData(
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          title: Text(
                            'Click to open error details',
                            style: context.theme.bodyTextStyle,
                          ),
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(error.toString()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ScrollBox(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 24,
                    ),
                    Icon(
                      Wirecons.check,
                      size: 48,
                      color: context.theme.primaryColor,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Thanks for your feedback!',
                      textAlign: TextAlign.center,
                      style: context.theme.titleTextStyle,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
