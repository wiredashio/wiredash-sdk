import 'package:flutter/material.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';
import 'package:wiredash/src/feedback/ui/grey_scale_filter.dart';
import 'package:wiredash/src/feedback/ui/larry_page_view.dart';
import 'package:wiredash/src/feedback/ui/steps/step_1_feedback_message.dart';
import 'package:wiredash/src/feedback/ui/steps/step_2_labels.dart';
import 'package:wiredash/src/feedback/ui/steps/step_3_screenshot_overview.dart';
import 'package:wiredash/src/feedback/ui/steps/step_4_screenshot.dart';
import 'package:wiredash/src/feedback/ui/steps/step_5_email.dart';

class WiredashFeedbackFlow extends StatefulWidget {
  const WiredashFeedbackFlow({Key? key}) : super(key: key);

  @override
  State<WiredashFeedbackFlow> createState() => _WiredashFeedbackFlowState();
}

class _WiredashFeedbackFlowState extends State<WiredashFeedbackFlow>
    with TickerProviderStateMixin {
  final GlobalKey<LarryPageViewState> stepFormKey =
      GlobalKey<LarryPageViewState>();

  int? get stackIndex {
    final state = context.feedbackModel.feedbackFlowStatus;
    final index = context.feedbackModel.steps.indexOf(state);
    if (index == -1) {
      return null;
    }
    return index;
  }

  int _index = 0;

  final GlobalKey<LarryPageViewState> _lpvKey = GlobalKey();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final oldIndex = _index;
    final newIndex = stackIndex;
    if (newIndex == null) {
      // state not in stack, stay at current page
      return;
    }
    if (oldIndex != newIndex) {
      final state = _lpvKey.currentState!;
      print("didChangeDependencies $oldIndex -> $newIndex");
      state.moveToPage(newIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedbackModel = context.feedbackModel;
    return GestureDetector(
      onTap: () {
        Focus.maybeOf(context)?.unfocus();
      },
      child: LarryPageView(
        key: _lpvKey,
        stepCount: feedbackModel.steps.length,
        initialPage: _index,
        pageIndex: _index,
        onPageChanged: (index) {
          setState(() {
            print("onPageChanged $_index -> $index");
            _index = index;
            final _stackIndex = stackIndex;
            if (_stackIndex == null) {
              return;
            }

            if (_stackIndex < _index) {
              final currentStep = feedbackModel.steps[_stackIndex];
              final nextStepIndex = _stackIndex + 1;
              if (nextStepIndex <= feedbackModel.steps.length) {
                final step = feedbackModel.steps[nextStepIndex];
                print("Adjust state $currentStep -> $step");
                feedbackModel.goToStep(step);
              }
            }

            if (_stackIndex > _index) {
              final currentStep = feedbackModel.steps[_stackIndex];
              final prevStepIndex = _stackIndex - 1;
              if (prevStepIndex <= feedbackModel.steps.length) {
                final step = feedbackModel.steps[prevStepIndex];
                print("Adjust state $currentStep -> $step");
                feedbackModel.goToStep(step);
              }
            }
          });
        },
        builder: (context) {
          final index = _index;
          final status = feedbackModel.steps[index];

          final stepWidget = () {
            if (status == FeedbackFlowStatus.message) {
              return const Step1FeedbackMessage();
            }
            if (status == FeedbackFlowStatus.labels) {
              return const Step2Labels();
            }
            if (status == FeedbackFlowStatus.screenshotsOverview) {
              return const Step3ScreenshotOverview();
            }
            if (status == FeedbackFlowStatus.screenshotSaving) {
              return const Step4ScreenshotSaving();
            }
            if (status == FeedbackFlowStatus.email) {
              return const Step5Email();
            }
            throw 'Unknown step $status at index $index';
          }();

          final step = StepInformation.of(context);
          return GreyScaleFilter(
            key: ValueKey(status),
            greyScale: step.animation.value,
            child: stepWidget,
          );
        },
      ),
    );
  }
}

/// Scrollable area with scrollbar
class ScrollBox extends StatefulWidget {
  const ScrollBox({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  State<ScrollBox> createState() => _ScrollBoxState();
}

class _ScrollBoxState extends State<ScrollBox> {
  @override
  Widget build(BuildContext context) {
    final controller = StepInformation.of(context).innerScrollController;
    return Theme(
      data: ThemeData(brightness: Brightness.light),
      child: Scrollbar(
        interactive: false,
        controller: controller,
        isAlwaysShown: true,
        child: SingleChildScrollView(
          controller: controller,
          child: widget.child,
        ),
      ),
    );
  }
}

class StepPageScaffold extends StatelessWidget {
  const StepPageScaffold({
    required this.child,
    Key? key,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}
