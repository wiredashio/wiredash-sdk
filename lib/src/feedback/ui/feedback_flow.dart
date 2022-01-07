import 'package:flutter/material.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/theme/wiredash_theme_data.dart';
import 'package:wiredash/src/common/widgets/tron_progress_indicator.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';
import 'package:wiredash/src/feedback/ui/grey_scale_filter.dart';
import 'package:wiredash/src/feedback/ui/larry_page_view.dart';
import 'package:wiredash/src/feedback/ui/steps/step_1_feedback_message.dart';
import 'package:wiredash/src/feedback/ui/steps/step_2_labels.dart';
import 'package:wiredash/src/feedback/ui/steps/step_3_screenshot_overview.dart';
import 'package:wiredash/src/feedback/ui/steps/step_5_email.dart';
import 'package:wiredash/src/feedback/ui/steps/step_6_submit.dart';
import 'package:wiredash/src/feedback/ui/steps/step_7_submitting.dart';
import 'package:wiredash/src/support/material_support_layer.dart';
import 'package:wiredash/src/wiredash_model_provider.dart';

class WiredashFeedbackFlow extends StatefulWidget {
  const WiredashFeedbackFlow({Key? key}) : super(key: key);

  @override
  State<WiredashFeedbackFlow> createState() => _WiredashFeedbackFlowState();
}

class _WiredashFeedbackFlowState extends State<WiredashFeedbackFlow>
    with TickerProviderStateMixin {
  final GlobalKey<LarryPageViewState> _lpvKey = GlobalKey();

  int _index = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_index >= context.feedbackModel.steps.length) {
      _index = context.feedbackModel.steps.length - 1;
    }

    final oldIndex = _index;
    final newIndex = context.feedbackModel.currentStepIndex;
    if (newIndex == null) {
      // state not in stack, stay at current page
      return;
    }
    if (oldIndex != newIndex) {
      final state = _lpvKey.currentState;
      if (state == null) return;
      // jump to next page after the widget has been rebuild and LarryPageView
      // knows about the new itemCount
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        state.moveToPage(newIndex);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedbackModel = context.feedbackModel;
    final larryPageView = LarryPageView(
      key: _lpvKey,
      stepCount: feedbackModel.steps.length,
      initialPage: _index,
      pageIndex: _index,
      onPageChanged: (index) {
        setState(() {
          _index = index;
          final _stackIndex = feedbackModel.currentStepIndex;
          if (_stackIndex == null) {
            return;
          }

          if (_stackIndex < _index) {
            feedbackModel.goToNextStep();
          }

          if (_stackIndex > _index) {
            feedbackModel.goToPreviousStep();
          }
        });
      },
      builder: (context) {
        final index = _index;
        final FeedbackFlowStatus status = () {
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
          if (status == FeedbackFlowStatus.submitting) {
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

    return GestureDetector(
      onTap: () {
        Focus.maybeOf(context)?.unfocus();
      },
      child: MaterialSupportLayer(
        locale: context
            .wiredashModel.services.wiredashWidget.options?.currentLocale,
        child: DefaultTextEditingShortcuts(
          child: Stack(
            children: [
              Form(
                key: feedbackModel.stepFormKey,
                child: larryPageView,
              ),
              _buildProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the circular progress indicator in the top left
  Widget _buildProgressIndicator() {
    if (context.theme.deviceClass == DeviceClass.handsetSmall320) {
      // hide progress indicator on small screens
      return const SizedBox();
    }

    return Positioned(
      top: 16,
      right: 0,
      child: TronProgressIndicator(
        totalSteps: 5,
        currentStep: _getCurrentProgressStep(),
      ),
    );
  }

  int _getCurrentProgressStep() {
    switch (context.feedbackModel.feedbackFlowStatus) {
      case FeedbackFlowStatus.none:
      case FeedbackFlowStatus.message:
        return 1;
      case FeedbackFlowStatus.labels:
        return 2;
      case FeedbackFlowStatus.screenshotsOverview:
      case FeedbackFlowStatus.screenshotNavigating:
      case FeedbackFlowStatus.screenshotCapturing:
      case FeedbackFlowStatus.screenshotDrawing:
      case FeedbackFlowStatus.screenshotSaving:
        return 3;
      case FeedbackFlowStatus.email:
        return 4;
      case FeedbackFlowStatus.submit:
      case FeedbackFlowStatus.submitting:
        return 5;
    }
  }
}

/// Scrollable area with scrollbar
class ScrollBox extends StatefulWidget {
  const ScrollBox({
    Key? key,
    required this.child,
    this.padding,
  }) : super(key: key);

  final Widget child;

  final EdgeInsetsGeometry? padding;

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
          padding: widget.padding,
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
