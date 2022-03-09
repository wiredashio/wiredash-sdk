import 'package:flutter/material.dart';
import 'package:wiredash/src/_wiredash_ui.dart';
import 'package:wiredash/src/feedback/_feedback.dart';

class Step7SubmittingAndError extends StatefulWidget {
  const Step7SubmittingAndError({Key? key}) : super(key: key);

  @override
  State<Step7SubmittingAndError> createState() =>
      _Step7SubmittingAndErrorState();
}

class _Step7SubmittingAndErrorState extends State<Step7SubmittingAndError> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedFadeWidgetSwitcher(
        alignment: Alignment.topCenter,
        duration: const Duration(milliseconds: 800),
        child: () {
          final submitting = context.feedbackModel.submitting;
          if (submitting) {
            return const _Submitting();
          }

          final error = context.feedbackModel.submissionError;
          if (error != null) {
            return _Error(
              error: error,
            );
          }

          return const _Submitted();
        }(),
      ),
    );
  }
}

class _Submitted extends StatelessWidget {
  const _Submitted({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
  }
}

class _Submitting extends StatelessWidget {
  const _Submitting({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}

class _Error extends StatelessWidget {
  const _Error({
    required this.error,
    Key? key,
  }) : super(key: key);

  final Object error;

  @override
  Widget build(BuildContext context) {
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(error.toString()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TronButton(
                leadingIcon: Wirecons.refresh,
                onTap: () {
                  context.feedbackModel.submitFeedback();
                },
                child: const Text("Retry"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
