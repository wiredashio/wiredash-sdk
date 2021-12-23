import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/widgets/translate_transition.dart';
import 'package:wiredash/src/common/widgets/tron_button.dart';
import 'package:wiredash/src/common/widgets/wirecons.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';
import 'package:wiredash/src/feedback/picasso/picasso_provider.dart';
import 'package:wiredash/src/wiredash_model_provider.dart';

class FeedbackNavigation extends StatefulWidget {
  const FeedbackNavigation({
    Key? key,
    required this.defaultLocation,
  }) : super(key: key);

  final Rect defaultLocation;

  @override
  State<FeedbackNavigation> createState() => _FeedbackNavigationState();
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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _recreateAnimations();
  }

  @override
  void didUpdateWidget(covariant FeedbackNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    _recreateAnimations();
  }

  void _recreateAnimations() {
    final width = MediaQuery.of(context).size.width;
    const double buttonTransitionWidth = 30;
    _prevButtonAnimation = Tween(
      begin: Offset(widget.defaultLocation.left, 0),
      end: const Offset(-buttonTransitionWidth, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _nextButtonAnimation = Tween(
      begin: Offset(
        -(width - widget.defaultLocation.right),
        0,
      ),
      end: const Offset(buttonTransitionWidth, 0),
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
    final prevButton = _getPrevButton();
    final nextButton = _getNextButton();
    return Stack(
      children: [
        Positioned(
          top: widget.defaultLocation.top,
          height: widget.defaultLocation.height,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TranslateTransition(
                offset: _prevButtonAnimation,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeInCubic,
                    switchOutCurve: Curves.easeOutCubic,
                    child: prevButton ?? const SizedBox(),
                  ),
                ),
              ),
              TranslateTransition(
                offset: _nextButtonAnimation,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeInCubic,
                    switchOutCurve: Curves.easeOutCubic,
                    child: nextButton ?? const SizedBox(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // TODO use
  Color prevButtonColor() {
    if (context.feedbackModel.feedbackFlowStatus ==
        FeedbackFlowStatus.screenshotDrawing) {
      return context.picasso.color;
    }
    return context.theme.secondaryColor;
  }

  Widget? _getPrevButton() {
    switch (context.feedbackModel.feedbackFlowStatus) {
      case FeedbackFlowStatus.none:
        return null;
      case FeedbackFlowStatus.message:
        return Opacity(
          // don't highlight the exit that much
          opacity: 0.5,
          child: TronButton(
            key: const ValueKey('back'),
            color: context.theme.secondaryColor,
            icon: Wirecons.chevron_double_up,
            label: 'Back to app',
            onTap: () => context.wiredashModel.hide(),
          ),
        );
      case FeedbackFlowStatus.labels:
        return TronButton(
          color: context.theme.secondaryColor,
          icon: Wirecons.arrow_narrow_left,
          label: 'Go back',
          onTap: () => context.feedbackModel.goToPreviousStep(),
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
          color: context.picasso.color,
          icon: Wirecons.pencil,
          iconOffset: const Offset(.15, 0),
          label: 'Change paint',
          onTap: () {
            debugPrint('Open paint menu');
            context.picasso.undo();
          },
        );
      case FeedbackFlowStatus.screenshotsOverview:
        _controller.reverse();
        if (context.feedbackModel.hasScreenshots) {
          return TronButton(
            color: context.theme.secondaryColor,
            icon: Wirecons.arrow_narrow_left,
            label: 'Go back',
            onTap: () => context.feedbackModel.goToPreviousStep(),
          );
        } else {
          return TronButton(
            color: context.theme.secondaryColor,
            icon: Wirecons.chevron_double_right,
            label: 'Skip screenshot',
            onTap: () => context.feedbackModel.goToNextStep(),
          );
        }

      case FeedbackFlowStatus.email:
        return TronButton(
          color: context.theme.secondaryColor,
          icon: Wirecons.arrow_narrow_left,
          label: 'Go back',
          onTap: () => context.feedbackModel.goToPreviousStep(),
        );
      case FeedbackFlowStatus.submitting:
        return null;
    }
  }

  Widget? _getNextButton() {
    switch (context.feedbackModel.feedbackFlowStatus) {
      case FeedbackFlowStatus.none:
        return null;
      case FeedbackFlowStatus.message:
        if (context.feedbackModel.feedbackMessage == null) {
          return null;
        }
        return TronButton(
          color: context.theme.primaryColor,
          icon: Wirecons.arrow_narrow_right,
          label: 'Next',
          onTap: () {
            context.feedbackModel.goToNextStep();
          },
        );

      case FeedbackFlowStatus.labels:
        return TronButton(
          color: context.feedbackModel.selectedLabels.isEmpty
              ? context.theme.secondaryColor
              : context.theme.primaryColor,
          icon: Wirecons.arrow_narrow_right,
          label: 'Next',
          onTap: () => context.feedbackModel.goToNextStep(),
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
          onTap: () {
            if (context.feedbackModel.hasScreenshots) {
              context.feedbackModel.goToStep(FeedbackFlowStatus.email);
            } else {
              context.feedbackModel
                  .goToStep(FeedbackFlowStatus.screenshotNavigating);
            }
          },
        );
      case FeedbackFlowStatus.email:
        return TronButton(
          color: context.theme.primaryColor,
          icon: Wirecons.check,
          label: 'Next',
          onTap: () {
            context.feedbackModel.submitFeedback();
          },
        );
      case FeedbackFlowStatus.submitting:
        return null;
    }
  }
}
