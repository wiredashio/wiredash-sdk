import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/widgets/offset_transition.dart';
import 'package:wiredash/src/common/widgets/tron_button.dart';
import 'package:wiredash/src/common/widgets/wirecons.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';

class FeedbackNavigation extends StatefulWidget {
  const FeedbackNavigation({Key? key}) : super(key: key);

  @override
  _FeedbackNavigationState createState() => _FeedbackNavigationState();
}

class _FeedbackNavigationState extends State<FeedbackNavigation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  Animation<Offset> _prevButtonAnimation =
      const AlwaysStoppedAnimation(Offset.zero);
  Animation<Offset> _nextButtonAnimation =
      const AlwaysStoppedAnimation(Offset.zero);

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _prevButtonAnimation = Tween(
      begin: Offset.zero,
      end: Offset(-context.theme.horizontalPadding - 24, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _nextButtonAnimation = Tween(
      begin: Offset.zero,
      end: Offset(context.theme.horizontalPadding + 24, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.theme.horizontalPadding,
            ),
            child: OffsetTransition(
              offset: _prevButtonAnimation,
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeIn,
                  opacity: isPrevButtonVisible() ? 1 : 0,
                  child: _getPrevButton(),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.theme.horizontalPadding,
            ),
            child: OffsetTransition(
              offset: _nextButtonAnimation,
              child: Align(
                alignment: Alignment.centerRight,
                child: _getNextButton(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool isPrevButtonVisible() {
    return context.feedbackModel.feedbackFlowStatus != FeedbackFlowStatus.none;
  }

  Color prevButtonColor() {
    if (context.feedbackModel.feedbackFlowStatus ==
        FeedbackFlowStatus.screenshotDrawing) {
      return context.feedbackModel.picassoController.color;
    }
    return context.theme.secondaryColor;
  }

  Widget _getPrevButton() {
    switch (context.feedbackModel.feedbackFlowStatus) {
      case FeedbackFlowStatus.none:
      case FeedbackFlowStatus.message:
        return TronButton(
          color: context.theme.secondaryColor,
          icon: Wirecons.arrow_narrow_left,
          label: 'Go back',
          onTap: () => context.feedbackModel.goToStep(FeedbackFlowStatus.none),
        );
      case FeedbackFlowStatus.labels:
        return TronButton(
          color: context.theme.secondaryColor,
          icon: Wirecons.arrow_narrow_left,
          label: 'Go back',
          onTap: () =>
              context.feedbackModel.goToStep(FeedbackFlowStatus.message),
        );

      case FeedbackFlowStatus.screenshotNavigating:
      case FeedbackFlowStatus.screenshotCapturing:
        _controller.forward();
        return TronButton(
          color: context.theme.secondaryColor,
          icon: Wirecons.x,
          iconOffset: const Offset(.15, 0),
          label: 'Cancel',
          onTap: () => context.feedbackModel
              .goToStep(FeedbackFlowStatus.screenshotsOverview),
        );
      case FeedbackFlowStatus.screenshotDrawing:
      case FeedbackFlowStatus.screenshotSaving:
        return TronButton(
          color: context.feedbackModel.picassoController.color,
          icon: Wirecons.pencil,
          iconOffset: const Offset(.15, 0),
          label: 'Change paint',
          onTap: () => print('Open paint menu'),
        );
      case FeedbackFlowStatus.screenshotsOverview:
        _controller.reverse();
        if (context.feedbackModel.hasScreenshots) {
          return TronButton(
            color: context.theme.secondaryColor,
            icon: Wirecons.arrow_narrow_left,
            label: 'Go back',
            onTap: () =>
                context.feedbackModel.goToStep(FeedbackFlowStatus.labels),
          );
        } else {
          return TronButton(
            color: context.theme.secondaryColor,
            icon: Wirecons.chevron_double_right,
            label: 'Skip screenshot',
            onTap: () =>
                context.feedbackModel.goToStep(FeedbackFlowStatus.email),
          );
        }

      case FeedbackFlowStatus.email:
        return TronButton(
          color: context.theme.secondaryColor,
          icon: Wirecons.arrow_narrow_left,
          label: 'Go back',
          onTap: () => context.feedbackModel
              .goToStep(FeedbackFlowStatus.screenshotsOverview),
        );
    }
  }

  Widget? _getNextButton() {
    switch (context.feedbackModel.feedbackFlowStatus) {
      case FeedbackFlowStatus.none:
      case FeedbackFlowStatus.message:
        return TronButton(
          color: context.theme.primaryColor,
          icon: Wirecons.arrow_narrow_right,
          label: 'Next',
          onTap: () =>
              context.feedbackModel.goToStep(FeedbackFlowStatus.labels),
        );
      case FeedbackFlowStatus.labels:
        return TronButton(
          color: context.theme.primaryColor,
          icon: Wirecons.arrow_narrow_right,
          label: 'Next',
          onTap: () => context.feedbackModel
              .goToStep(FeedbackFlowStatus.screenshotsOverview),
        );
      case FeedbackFlowStatus.screenshotNavigating:
      case FeedbackFlowStatus.screenshotCapturing:
        return TronButton(
          color: context.theme.primaryColor,
          icon: Wirecons.camera,
          iconOffset: const Offset(-.15, 0),
          label: 'Next',
          onTap: () => context.feedbackModel
              .goToStep(FeedbackFlowStatus.screenshotCapturing),
        );
      case FeedbackFlowStatus.screenshotDrawing:
      case FeedbackFlowStatus.screenshotSaving:
        return TronButton(
          color: context.theme.primaryColor,
          icon: Wirecons.check,
          iconOffset: const Offset(-.15, 0),
          label: 'Next',
          onTap: () => context.feedbackModel
              .goToStep(FeedbackFlowStatus.screenshotSaving),
        );
      case FeedbackFlowStatus.screenshotsOverview:
        return TronButton(
          color: context.theme.primaryColor,
          icon: Wirecons.arrow_narrow_right,
          label: 'Next',
          onTap: () => context.feedbackModel
              .goToStep(FeedbackFlowStatus.screenshotNavigating),
        );
      case FeedbackFlowStatus.email:
        // TODO Implement sending of feedback
        return TronButton(
          color: context.theme.primaryColor,
          icon: Wirecons.arrow_narrow_right,
          label: 'Next',
          onTap: () => context.feedbackModel.goToStep(FeedbackFlowStatus.none),
        );
    }
  }
}
