import 'package:flutter/material.dart';
import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';

class Step7SubmittingAndError extends StatefulWidget {
  const Step7SubmittingAndError({super.key});

  @override
  State<Step7SubmittingAndError> createState() =>
      _Step7SubmittingAndErrorState();
}

class _Step7SubmittingAndErrorState extends State<Step7SubmittingAndError> {
  @override
  Widget build(BuildContext context) {
    return AnimatedFadeWidgetSwitcher(
      alignment: Alignment.topCenter,
      duration: const Duration(milliseconds: 800),
      child: () {
        final submitting = context.watchFeedbackModel.submitting;
        if (submitting) {
          return const _Submitting();
        }

        final error = context.watchFeedbackModel.submissionError;
        if (error != null) {
          return _Error(
            error: error,
          );
        }

        return const _Submitted();
      }(),
    );
  }
}

class _Submitted extends StatelessWidget {
  const _Submitted();

  @override
  Widget build(BuildContext context) {
    return StepPageScaffold(
      minHeight: 0,
      alignment: StepPageAlignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            context.l10n.feedbackStep7SubmissionSuccessMessage,
            textAlign: TextAlign.center,
            style: context.text.title.onBackground,
          ),
        ],
      ),
    );
  }
}

class _Submitting extends StatelessWidget {
  const _Submitting();

  @override
  Widget build(BuildContext context) {
    return StepPageScaffold(
      minHeight: 0,
      alignment: StepPageAlignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Wirecons.arrow_right,
            size: 48,
            color: context.theme.primaryColor,
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            context.l10n.feedbackStep7SubmissionInFlightMessage,
            textAlign: TextAlign.center,
            style: context.text.title.onBackground,
          ),
        ],
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({
    required this.error,
  });

  final Object error;

  @override
  Widget build(BuildContext context) {
    return StepPageScaffold(
      minHeight: 0,
      alignment: StepPageAlignment.center,
      child: Column(
        children: [
          Icon(
            Wirecons.x_circle,
            size: 48,
            color: context.theme.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.feedbackStep7SubmissionErrorMessage,
            style: context.text.title.onBackground,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ExpansionTile(
            iconColor: context.theme.secondaryTextOnBackgroundColor,
            collapsedIconColor: context.theme.primaryTextOnBackgroundColor,
            title: Text(
              context.l10n.feedbackStep7SubmissionOpenErrorButton,
              style: context.text.adaptiveBody.onBackground,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  error.toString(),
                  style: context.text.adaptiveBody2.onBackground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TronButton(
              leadingIcon: Wirecons.refresh,
              onTap: () {
                context.readFeedbackModel.submitFeedback();
              },
              child: Text(context.l10n.feedbackStep7SubmissionRetryButton),
            ),
          ),
        ],
      ),
    );
  }
}
