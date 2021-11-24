import 'package:flutter/material.dart';
import 'package:wiredash/src/feedback/ui/grey_scale_filter.dart';
import 'package:wiredash/src/feedback/ui/larry_page_view.dart';
import 'package:wiredash/src/feedback/ui/steps/step_1_feedback_message.dart';
import 'package:wiredash/src/feedback/ui/steps/step_2_labels.dart';
import 'package:wiredash/src/feedback/ui/steps/step_3_email.dart';
import 'package:wiredash/src/feedback/ui/steps/step_4_screenshot.dart';
import 'package:wiredash/src/feedback/ui/steps/step_5_submit.dart';

class WiredashFeedbackFlow extends StatefulWidget {
  const WiredashFeedbackFlow({Key? key}) : super(key: key);

  @override
  State<WiredashFeedbackFlow> createState() => _WiredashFeedbackFlowState();
}

class _WiredashFeedbackFlowState extends State<WiredashFeedbackFlow>
    with TickerProviderStateMixin {
  final GlobalKey<LarryPageViewState> stepFormKey =
      GlobalKey<LarryPageViewState>();
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Focus.maybeOf(context)?.unfocus();
      },
      child: LarryPageView(
        viewInsets: MediaQuery.of(context).padding,
        stepCount: 5,
        initialPage: _page,
        onPageChanged: (index) {
          setState(() {
            _page = index;
          });
        },
        builder: (context) {
          final index = _page;
          final stepWidget = () {
            if (index == 0) {
              return const Step1FeedbackMessage();
            }
            if (index == 1) {
              return ScrollBox(
                child: Step2Labels(),
              );
            }
            if (index == 2) {
              return ScrollBox(
                child: Step3Email(),
              );
            }
            if (index == 3) {
              return ScrollBox(
                child: Step4Screenshot(),
              );
            }
            if (index == 4) {
              return ScrollBox(
                child: Step5Submit(),
              );
            }
            throw 'Index out of bounds $index';
          }();
          final step = StepInformation.of(context);
          return GreyScaleFilter(
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
    required this.body,
    this.bottomBarBuilder,
    Key? key,
  }) : super(key: key);

  final Widget body;
  final Widget Function(BuildContext context)? bottomBarBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ScrollBox(
            child: body,
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.fastOutSlowIn,
          switchOutCurve: Curves.fastOutSlowIn,
          child: bottomBarBuilder?.call(context),
        )
      ],
    );
  }
}
