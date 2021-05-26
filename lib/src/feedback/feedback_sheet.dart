import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/options/wiredash_options.dart';
import 'package:wiredash/src/common/renderer/renderer.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/translation/wiredash_localizations.dart';
import 'package:wiredash/src/common/widgets/animated_fade_in.dart';
import 'package:wiredash/src/common/widgets/animated_progress.dart';
import 'package:wiredash/src/common/widgets/navigation_buttons.dart';
import 'package:wiredash/src/common/widgets/wiredash_icons.dart';
import 'package:wiredash/src/feedback/components/error_component.dart';
import 'package:wiredash/src/feedback/components/input_component.dart';
import 'package:wiredash/src/feedback/components/intro_component.dart';
import 'package:wiredash/src/feedback/components/loading_component.dart';
import 'package:wiredash/src/feedback/components/success_component.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';
import 'package:wiredash/src/wiredash_provider.dart';

class FeedbackSheet extends StatefulWidget {
  const FeedbackSheet({Key? key}) : super(key: key);

  @override
  _FeedbackSheetState createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<FeedbackSheet>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final _emailFormKey = GlobalKey<FormState>();
  final _feedbackFormKey = GlobalKey<FormState>();

  final _feedbackFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();

  @override
  void dispose() {
    _feedbackFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: WiredashTheme.of(context)!.secondaryBackgroundColor,
        borderRadius: WiredashTheme.of(context)!.sheetBorderRadius,
        elevation: 8,
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          left: false,
          right: false,
          minimum: const EdgeInsets.only(bottom: 16),
          child: _buildCardContent(),
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    return Column(
      children: <Widget>[
        _buildHeader(),
        AnimatedBuilder(
          animation: context.feedbackModel!,
          builder: (context, _) {
            return AnimatedProgress(
              isLoading: context.feedbackModel!.loading,
              value: _getProgressValue(),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AnimatedSize(
            // remove when min Flutter SDK is after v2.2.0-10.1.pre
            // ignore: deprecated_member_use
            vsync: this,
            alignment: Alignment.topCenter,
            curve: Curves.fastOutSlowIn,
            duration: const Duration(milliseconds: 350),
            child: AnimatedBuilder(
              animation: context.feedbackModel!,
              builder: (context, _) => Column(
                children: <Widget>[
                  _getInputComponent(),
                  _buildButtons(),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            WiredashTheme.of(context)!.primaryColor,
            WiredashTheme.of(context)!.secondaryColor
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Align(
            child: Material(
              shape: const StadiumBorder(),
              color: WiredashTheme.of(context)!.dividerColor,
              child: const SizedBox(
                height: 4,
                width: 56,
              ),
            ),
          ),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: context.feedbackModel!,
            builder: (context, child) => AnimatedFadeIn(
              changeKey: ValueKey(context.feedbackModel!.feedbackUiState),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 250),
                // remove when min Flutter SDK is after v2.2.0-10.1.pre
                // ignore: deprecated_member_use
                vsync: this,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _getTitle(),
                      style: WiredashTheme.of(context)!.titleStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getSubtitle(),
                      style: WiredashTheme.of(context)!.subtitleStyle,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    if (context.feedbackModel!.feedbackUiState == FeedbackUiState.intro) {
      return Image.asset(
        'assets/images/logo_footer.png',
        width: 100,
        package: 'wiredash',
        semanticLabel: WiredashLocalizations.of(context)!.companyLogoLabel,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildButtons() {
    final state = context.feedbackModel!;

    switch (state.feedbackUiState) {
      case FeedbackUiState.feedback:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: PreviousButton(
                text: WiredashLocalizations.of(context)!.feedbackCancel,
                onPressed: () => state.feedbackUiState = FeedbackUiState.intro,
              ),
            ),
            Expanded(
              child: NextButton(
                key: const ValueKey('wiredash.sdk.save_feedback_button'),
                text: WiredashLocalizations.of(context)!.feedbackSave,
                icon: WiredashIcons.right,
                onPressed: _submitFeedback,
              ),
            ),
          ],
        );
      case FeedbackUiState.email:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: PreviousButton(
                text: WiredashLocalizations.of(context)!.feedbackBack,
                onPressed: () =>
                    state.feedbackUiState = FeedbackUiState.feedback,
              ),
            ),
            Expanded(
              child: NextButton(
                key: const ValueKey('wiredash.sdk.send_feedback_button'),
                text: WiredashLocalizations.of(context)!.feedbackSend,
                icon: WiredashIcons.right,
                onPressed: _submitEmail,
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _submitFeedback() {
    if (_feedbackFormKey.currentState!.validate()) {
      _feedbackFormKey.currentState!.save();
      context.feedbackModel!.feedbackUiState = FeedbackUiState.email;
    }
  }

  void _submitEmail() {
    if (_emailFormKey.currentState!.validate()) {
      _emailFormKey.currentState!.save();
      context.feedbackModel!.feedbackUiState = FeedbackUiState.submit;
    }
  }

  void _onFeedbackModeSelected(FeedbackType mode) {
    final feedbackModel = context.feedbackModel;
    feedbackModel!.feedbackType = mode;

    switch (mode) {
      case FeedbackType.bug:
      case FeedbackType.improvement:
        final renderer = getRenderer();
        if (WiredashOptions.of(context)!.screenshotStep &&
            renderer != Renderer.html) {
          // Start the capture process
          Navigator.pop(context);
          feedbackModel.feedbackUiState = FeedbackUiState.capture;
        } else {
          // Don't start the screen capturing and directly continue to the
          // feedback form
          feedbackModel.feedbackUiState = FeedbackUiState.feedback;
        }
        break;
      case FeedbackType.praise:
        // Don't start the screen capturing and directly continue to the
        // feedback form
        feedbackModel.feedbackUiState = FeedbackUiState.feedback;
        break;
    }
  }

  String _getTitle() {
    switch (context.feedbackModel!.feedbackUiState) {
      case FeedbackUiState.intro:
        return WiredashLocalizations.of(context)!.feedbackStateIntroTitle;
      case FeedbackUiState.feedback:
        return WiredashLocalizations.of(context)!.feedbackStateFeedbackTitle;
      case FeedbackUiState.email:
        return WiredashLocalizations.of(context)!.feedbackStateEmailTitle;
      case FeedbackUiState.submit:
      case FeedbackUiState.submitted:
        return WiredashLocalizations.of(context)!.feedbackStateSuccessTitle;
      case FeedbackUiState.submissionError:
        return WiredashLocalizations.of(context)!.feedbackStateErrorTitle;
      default:
        return '';
    }
  }

  String _getSubtitle() {
    switch (context.feedbackModel!.feedbackUiState) {
      case FeedbackUiState.intro:
        return WiredashLocalizations.of(context)!.feedbackStateIntroMsg;
      case FeedbackUiState.feedback:
        return WiredashLocalizations.of(context)!.feedbackStateFeedbackMsg;
      case FeedbackUiState.email:
        return WiredashLocalizations.of(context)!.feedbackStateEmailMsg;
      case FeedbackUiState.submit:
      case FeedbackUiState.submitted:
        return WiredashLocalizations.of(context)!.feedbackStateSuccessMsg;
      case FeedbackUiState.submissionError:
        return WiredashLocalizations.of(context)!.feedbackStateErrorMsg;
      default:
        return '';
    }
  }

  double _getProgressValue() {
    switch (context.feedbackModel!.feedbackUiState) {
      case FeedbackUiState.feedback:
        return 0.3;
      case FeedbackUiState.email:
        return 0.7;
      case FeedbackUiState.submit:
        return 0.9;
      case FeedbackUiState.submissionError:
        return 0.9;
      case FeedbackUiState.submitted:
        return 1.0;
      default:
        return 0;
    }
  }

  Widget _getInputComponent() {
    final uiState = context.feedbackModel!.feedbackUiState;
    switch (uiState) {
      case FeedbackUiState.intro:
        return IntroComponent(_onFeedbackModeSelected);
      case FeedbackUiState.feedback:
        return InputComponent(
          key: const ValueKey('wiredash.sdk.feedback_input_field'),
          type: InputComponentType.feedback,
          formKey: _feedbackFormKey,
          focusNode: _feedbackFocusNode,
          prefill: context.feedbackModel!.feedbackMessage,
          autofocus: _emailFocusNode.hasFocus,
        );
      case FeedbackUiState.email:
        return InputComponent(
          key: const ValueKey('wiredash.sdk.email_input_field'),
          type: InputComponentType.email,
          formKey: _emailFormKey,
          focusNode: _emailFocusNode,
          prefill: context.userManager!.userEmail,
          autofocus: _feedbackFocusNode.hasFocus,
        );
      case FeedbackUiState.submit:
        return const LoadingComponent();
      case FeedbackUiState.submitted:
        return SuccessComponent(
          () {
            context.feedbackModel!.feedbackUiState = FeedbackUiState.hidden;
            Navigator.pop(context);
          },
        );
      case FeedbackUiState.submissionError:
        return ErrorComponent(
          onRetry: () {
            context.feedbackModel!.feedbackUiState = FeedbackUiState.submit;
          },
        );
      default:
        return IntroComponent(_onFeedbackModeSelected);
    }
  }
}
