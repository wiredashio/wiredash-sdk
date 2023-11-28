import 'package:flutter/material.dart';
import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/_wiredash_ui.dart';
import 'package:wiredash/src/core/support/back_button_interceptor.dart';
import 'package:wiredash/src/core/support/material_support_layer.dart';
import 'package:wiredash/src/core/support/widget_binding_support.dart';
import 'package:wiredash/src/feedback/ui/grey_scale_filter.dart';

class WiredashFeedbackFlow extends StatefulWidget {
  const WiredashFeedbackFlow({super.key});

  @override
  State<WiredashFeedbackFlow> createState() => _WiredashFeedbackFlowState();
}

class _WiredashFeedbackFlowState extends State<WiredashFeedbackFlow>
    with TickerProviderStateMixin {
  final GlobalKey<LarryPageViewState> _lpvKey = GlobalKey();

  int _index = 0;

  @override
  void initState() {
    super.initState();
    _index = context.readFeedbackModel.currentStepIndex ?? 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_index >= context.watchFeedbackModel.steps.length) {
      _index = context.watchFeedbackModel.steps.length - 1;
    }

    final oldIndex = _index;
    final newIndex = context.watchFeedbackModel.currentStepIndex;
    if (newIndex == null) {
      // state not in stack, stay at current page
      return;
    }
    if (oldIndex != newIndex) {
      final state = _lpvKey.currentState;
      if (state == null) return;
      // jump to next page after the widget has been rebuild and LarryPageView
      // knows about the new itemCount
      widgetsBindingInstance.addPostFrameCallback((timeStamp) {
        state.moveToPage(newIndex);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final larryPageView = LarryPageView(
      key: _lpvKey,
      stepCount: context.watchFeedbackModel.steps.length,
      pageIndex: _index,
      onPageChanged: (index) {
        setState(() {
          _index = index;
          final stepIndex = context.readFeedbackModel.currentStepIndex;
          if (stepIndex == null) {
            return;
          }

          if (stepIndex < _index) {
            context.readFeedbackModel.goToNextStep();
          }

          if (stepIndex > _index) {
            context.readFeedbackModel.goToPreviousStep();
          }
        });
      },
      builder: (context) {
        final index = _index;
        final FeedbackFlowStatus status = () {
          final feedbackModel = context.watchFeedbackModel;
          if (feedbackModel.steps.length <= index) {
            final stackIndex = feedbackModel.currentStepIndex;
            if (stackIndex == null) {
              return feedbackModel.steps.first;
            } else {
              return feedbackModel.steps[stackIndex];
            }
          }
          return feedbackModel.steps[index];
        }();

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
          if (status == FeedbackFlowStatus.email) {
            return const Step5Email();
          }
          if (status == FeedbackFlowStatus.submit) {
            return const Step6Submit();
          }
          if (status == FeedbackFlowStatus.submittingAndRetry) {
            return const Step7SubmittingAndError();
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
    );

    return MaterialSupportLayer(
      child: BackButtonInterceptor(
        onBackPressed: () {
          if (_index == 0) {
            return BackButtonAction.ignored;
          }
          context.readFeedbackModel.goToPreviousStep();
          return BackButtonAction.consumed;
        },
        child: Form(
          key: context.watchFeedbackModel.stepFormKey,
          child: larryPageView,
        ),
      ),
    );
  }
}

/// Inherits the step information from [FeedbackModel]
class FeedbackProgressIndicator extends StatefulWidget {
  const FeedbackProgressIndicator({
    super.key,
    required this.flowStatus,
  });

  final FeedbackFlowStatus flowStatus;

  @override
  State<FeedbackProgressIndicator> createState() =>
      _FeedbackProgressIndicatorState();
}

class _FeedbackProgressIndicatorState extends State<FeedbackProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    final feedbackModel = context.watchFeedbackModel;
    final stepIndex = feedbackModel.indexForFlowStatus(widget.flowStatus);
    var currentStep = stepIndex + 1;
    final total = feedbackModel.maxSteps;

    bool completed = false;
    if (currentStep > total) {
      // especially the last "Submit" step should show the number on the
      // previous page
      currentStep = total;
      completed = true;
    }
    return StepIndicator(
      completed: completed,
      total: total,
      currentStep: currentStep,
    );
  }
}
