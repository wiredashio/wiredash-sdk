import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/state/wiredash_state.dart';
import 'package:wiredash/src/common/state/wiredash_state_data.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/translation/wiredash_translation.dart';
import 'package:wiredash/src/common/widgets/animated_fade_in.dart';
import 'package:wiredash/src/common/widgets/animated_progress.dart';
import 'package:wiredash/src/common/widgets/simple_button.dart';
import 'package:wiredash/src/common/widgets/wiredash_icons.dart';
import 'package:wiredash/src/feedback/components/input_component.dart';
import 'package:wiredash/src/feedback/components/intro_component.dart';
import 'package:wiredash/src/feedback/components/success_component.dart';

class FeedbackSheet extends StatefulWidget {
  @override
  _FeedbackSheetState createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<FeedbackSheet>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
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
        color: WiredashTheme.of(context).secondaryBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
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
        AnimatedProgress(
          isLoading: WiredashState.of(context, listen: false).loading,
          value: _getProgressValue(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AnimatedSize(
            vsync: this,
            alignment: Alignment.topCenter,
            curve: Curves.fastOutSlowIn,
            duration: const Duration(milliseconds: 350),
            child: Column(
              children: <Widget>[
                _getInputComponent(),
                _buildButtons(),
                _buildFooter(),
              ],
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            WiredashTheme.of(context).primaryColor,
            WiredashTheme.of(context).secondaryColor
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
            alignment: Alignment.center,
            child: Material(
              shape: const StadiumBorder(),
              color: WiredashTheme.of(context).dividerColor,
              child: const SizedBox(
                height: 4,
                width: 56,
              ),
            ),
          ),
          const SizedBox(height: 24),
          AnimatedFadeIn(
            changeKey: ValueKey(WiredashState.of(context).feedbackState),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _getTitle(),
                  style: WiredashTheme.of(context).titleStyle,
                ),
                const SizedBox(height: 4),
                Text(
                  _getSubtitle(),
                  style: WiredashTheme.of(context).subtitleStyle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    if (WiredashState.of(context).feedbackState == FeedbackState.intro) {
      return Image.asset(
        'assets/images/logo_footer.png',
        width: 100,
        package: 'wiredash',
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildButtons() {
    final state = WiredashState.of(context);

    switch (state.feedbackState) {
      case FeedbackState.feedback:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SimpleButton(
              text: WiredashTranslation.of(context).feedbackCancel,
              onPressed: () {
                state.feedbackState = FeedbackState.intro;
              },
            ),
            SimpleButton(
              text: WiredashTranslation.of(context).feedbackSave,
              icon: WiredashIcons.right,
              onPressed: _submitFeedback,
            ),
          ],
        );
      case FeedbackState.email:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SimpleButton(
              text: WiredashTranslation.of(context).feedbackBack,
              onPressed: () => state.feedbackState = FeedbackState.feedback,
            ),
            SimpleButton(
              text: WiredashTranslation.of(context).feedbackSend,
              icon: WiredashIcons.right,
              onPressed: _submitEmail,
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _submitFeedback() {
    if (_feedbackFormKey.currentState.validate()) {
      _feedbackFormKey.currentState.save();
      WiredashState.of(context, listen: false).feedbackState =
          FeedbackState.email;
    }
  }

  void _submitEmail() {
    if (_emailFormKey.currentState.validate()) {
      _emailFormKey.currentState.save();
      WiredashState.of(context, listen: false).feedbackState =
          FeedbackState.success;
    }
  }

  void _onFeedbackModeSelected(FeedbackType mode) {
    WiredashState.of(context, listen: false).feedbackType = mode;

    switch (mode) {
      case FeedbackType.bug:
      case FeedbackType.improvement:
        // Start the capture process
        Navigator.pop(context);
        WiredashState.of(context, listen: false).feedbackState =
            FeedbackState.capture;
        break;
      case FeedbackType.praise:
        // Don't start the screen capturing and directly continue to the feedback form
        WiredashState.of(context, listen: false).feedbackState =
            FeedbackState.feedback;
        break;
    }
  }

  String _getTitle() {
    switch (WiredashState.of(context).feedbackState) {
      case FeedbackState.intro:
        return WiredashTranslation.of(context).feedbackStateIntroTitle;
      case FeedbackState.feedback:
        return WiredashTranslation.of(context).feedbackStateFeedbackTitle;
      case FeedbackState.email:
        return WiredashTranslation.of(context).feedbackStateEmailTitle;
      case FeedbackState.success:
        return WiredashTranslation.of(context).feedbackStateSuccessTitle;
      default:
        return '';
    }
  }

  String _getSubtitle() {
    switch (WiredashState.of(context).feedbackState) {
      case FeedbackState.intro:
        return WiredashTranslation.of(context).feedbackStateIntroMsg;
      case FeedbackState.feedback:
        return WiredashTranslation.of(context).feedbackStateFeedbackMsg;
      case FeedbackState.email:
        return WiredashTranslation.of(context).feedbackStateEmailMsg;
      case FeedbackState.success:
        return WiredashTranslation.of(context).feedbackStateSuccessMsg;
      default:
        return '';
    }
  }

  double _getProgressValue() {
    switch (WiredashState.of(context).feedbackState) {
      case FeedbackState.feedback:
        return 0.3;
      case FeedbackState.email:
        return 0.8;
      case FeedbackState.success:
        return 1.0;
      default:
        return 0;
    }
  }

  Widget _getInputComponent() {
    final state = WiredashState.of(context);
    final uiState = state.feedbackState;
    switch (uiState) {
      case FeedbackState.intro:
        return IntroComponent(_onFeedbackModeSelected);
      case FeedbackState.feedback:
        return InputComponent(
          key: ValueKey(uiState),
          type: InputComponentType.feedback,
          formKey: _feedbackFormKey,
          focusNode: _feedbackFocusNode,
          prefill: state.feedbackMessage,
          autofocus: _emailFocusNode.hasFocus,
        );
      case FeedbackState.email:
        return InputComponent(
          key: ValueKey(uiState),
          type: InputComponentType.email,
          formKey: _emailFormKey,
          focusNode: _emailFocusNode,
          prefill: state.userEmail,
          autofocus: _feedbackFocusNode.hasFocus,
        );
      case FeedbackState.success:
        return SuccessComponent();
      default:
        return IntroComponent(_onFeedbackModeSelected);
    }
  }
}
