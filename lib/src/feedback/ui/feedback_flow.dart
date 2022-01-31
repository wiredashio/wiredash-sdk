import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/widgets/tron_labeled_button.dart';
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
      locale:
          context.wiredashModel.services.wiredashWidget.options?.currentLocale,
      child: Stack(
        children: [
          Form(
            key: feedbackModel.stepFormKey,
            child: larryPageView,
          ),
        ],
      ),
    );
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
    Widget child = SingleChildScrollView(
      controller: controller,
      padding: widget.padding,
      child: widget.child,
    );
    final targetPlatform = Theme.of(context).platform;
    final bool isTouchInput = targetPlatform == TargetPlatform.iOS ||
        targetPlatform == TargetPlatform.android;
    if (isTouchInput) {
      child = Scrollbar(
        interactive: false,
        controller: controller,
        isAlwaysShown: false,
        child: child,
      );
    }

    return child;
  }
}

class StepPageScaffold extends StatefulWidget {
  const StepPageScaffold({
    this.currentStep,
    this.totalSteps,
    required this.title,
    this.shortTitle,
    this.description,
    required this.child,
    required this.flowStatus,
    Key? key,
  }) : super(key: key);

  final int? currentStep;
  final int? totalSteps;

  final FeedbackFlowStatus flowStatus;
  final Widget title;
  final Widget? shortTitle;
  final Widget? description;

  final Widget child;

  @override
  State<StepPageScaffold> createState() => _StepPageScaffoldState();
}

class _StepPageScaffoldState extends State<StepPageScaffold> {
  Timer? _reallyTimer;

  Widget _buildTitle(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefaultTextStyle(
          style: context.theme.headlineTextStyle,
          child: widget.title,
        ),
        if (widget.description != null)
          const SizedBox(
            height: 8,
          ),
        if (widget.description != null)
          DefaultTextStyle(
            style: context.theme.bodyTextStyle,
            child: widget.description!,
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    print(context.theme.windowSize.width);
    return Align(
      child: ScrollBox(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FeedbackProgressIndicator(flowStatus: widget.flowStatus),
                  if (widget.shortTitle != null &&
                      context.theme.windowSize.width > 400) ...[
                    SizedBox(
                      height: 16,
                      child: VerticalDivider(
                        color: context.theme.captionTextStyle.color,
                      ),
                    ),
                    Expanded(
                      child: DefaultTextStyle(
                        style: context.theme.captionTextStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        child: widget.shortTitle!,
                      ),
                    )
                  ] else
                    const Spacer(),
                  TronLabeledButton(
                    onTap: () {
                      setState(() {
                        if (_reallyTimer == null) {
                          setState(() {
                            _reallyTimer =
                                Timer(const Duration(seconds: 3), () {
                              setState(() {
                                _reallyTimer = null;
                              });
                            });
                          });
                        } else {
                          context.wiredashModel.hide(discardFeedback: true);
                          _reallyTimer = null;
                        }
                      });
                    },
                    child: _reallyTimer == null
                        ? const Text('Discard Feedback')
                        : Text(
                            'Really? Discard!',
                            style: TextStyle(color: context.theme.errorColor),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTitle(context),
              const SizedBox(height: 32),
              widget.child
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _reallyTimer?.cancel();
    super.dispose();
  }
}

/// Inherits the step information from [FeedbackModel]
class FeedbackProgressIndicator extends StatefulWidget {
  const FeedbackProgressIndicator({
    Key? key,
    required this.flowStatus,
  }) : super(key: key);

  final FeedbackFlowStatus flowStatus;

  @override
  State<FeedbackProgressIndicator> createState() =>
      _FeedbackProgressIndicatorState();
}

class _FeedbackProgressIndicatorState extends State<FeedbackProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    final feedbackModel = context.feedbackModel;
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TronProgressIndicator(
          currentStep: completed ? total : currentStep - 1,
          totalSteps: total,
        ),
        const SizedBox(width: 12),
        Text(
          'Step $currentStep of $total',
          style: context.theme.captionTextStyle,
        ),
      ],
    );
  }
}
