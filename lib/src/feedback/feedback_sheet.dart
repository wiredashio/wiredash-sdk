import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/translation/wiredash_localizations.dart';
import 'package:wiredash/src/common/user/user_manager.dart';
import 'package:wiredash/src/common/widgets/animated_fade_in.dart';
import 'package:wiredash/src/common/widgets/animated_progress.dart';
import 'package:wiredash/src/common/widgets/navigation_buttons.dart';
import 'package:wiredash/src/common/widgets/wiredash_icons.dart';
import 'package:wiredash/src/feedback/components/input_component.dart';
import 'package:wiredash/src/feedback/components/intro_component.dart';
import 'package:wiredash/src/feedback/components/success_component.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';

// ignore: use_key_in_widget_constructors
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
          isLoading: Provider.of<FeedbackModel>(context).loading,
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
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
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
            changeKey:
                ValueKey(Provider.of<FeedbackModel>(context).feedbackUiState),
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
    if (Provider.of<FeedbackModel>(context).feedbackUiState ==
        FeedbackUiState.intro) {
      return Image.asset(
        'assets/images/logo_footer.png',
        width: 100,
        package: 'wiredash',
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildButtons() {
    final state = Provider.of<FeedbackModel>(context);

    switch (state.feedbackUiState) {
      case FeedbackUiState.feedback:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: PreviousButton(
                text: WiredashLocalizations.of(context).feedbackCancel,
                onPressed: () => state.feedbackUiState = FeedbackUiState.intro,
              ),
            ),
            Expanded(
              child: NextButton(
                text: WiredashLocalizations.of(context).feedbackSave,
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
                text: WiredashLocalizations.of(context).feedbackBack,
                onPressed: () =>
                    state.feedbackUiState = FeedbackUiState.feedback,
              ),
            ),
            Expanded(
              child: NextButton(
                text: WiredashLocalizations.of(context).feedbackSend,
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
    if (_feedbackFormKey.currentState.validate()) {
      _feedbackFormKey.currentState.save();
      Provider.of<FeedbackModel>(context, listen: false).feedbackUiState =
          FeedbackUiState.email;
    }
  }

  void _submitEmail() {
    if (_emailFormKey.currentState.validate()) {
      _emailFormKey.currentState.save();
      Provider.of<FeedbackModel>(context, listen: false).feedbackUiState =
          FeedbackUiState.success;
    }
  }

  void _onFeedbackModeSelected(FeedbackType mode) {
    final feedbackModel = Provider.of<FeedbackModel>(context, listen: false);
    feedbackModel.feedbackType = mode;

    switch (mode) {
      case FeedbackType.bug:
      case FeedbackType.improvement:
        // Start the capture process
        Navigator.pop(context);
        feedbackModel.feedbackUiState = FeedbackUiState.capture;
        break;
      case FeedbackType.praise:
        // Don't start the screen capturing and directly continue to the feedback form
        feedbackModel.feedbackUiState = FeedbackUiState.feedback;
        break;
    }
  }

  String _getTitle() {
    switch (Provider.of<FeedbackModel>(context).feedbackUiState) {
      case FeedbackUiState.intro:
        return WiredashLocalizations.of(context).feedbackStateIntroTitle;
      case FeedbackUiState.feedback:
        return WiredashLocalizations.of(context).feedbackStateFeedbackTitle;
      case FeedbackUiState.email:
        return WiredashLocalizations.of(context).feedbackStateEmailTitle;
      case FeedbackUiState.success:
        return WiredashLocalizations.of(context).feedbackStateSuccessTitle;
      default:
        return '';
    }
  }

  String _getSubtitle() {
    switch (Provider.of<FeedbackModel>(context).feedbackUiState) {
      case FeedbackUiState.intro:
        return WiredashLocalizations.of(context).feedbackStateIntroMsg;
      case FeedbackUiState.feedback:
        return WiredashLocalizations.of(context).feedbackStateFeedbackMsg;
      case FeedbackUiState.email:
        return WiredashLocalizations.of(context).feedbackStateEmailMsg;
      case FeedbackUiState.success:
        return WiredashLocalizations.of(context).feedbackStateSuccessMsg;
      default:
        return '';
    }
  }

  double _getProgressValue() {
    switch (Provider.of<FeedbackModel>(context).feedbackUiState) {
      case FeedbackUiState.feedback:
        return 0.3;
      case FeedbackUiState.email:
        return 0.8;
      case FeedbackUiState.success:
        return 1.0;
      default:
        return 0;
    }
  }

  Widget _getInputComponent() {
    final feedbackModel = Provider.of<FeedbackModel>(context);
    final uiState = feedbackModel.feedbackUiState;
    switch (uiState) {
      case FeedbackUiState.intro:
        return IntroComponent(_onFeedbackModeSelected);
      case FeedbackUiState.feedback:
        return InputComponent(
          key: ValueKey(uiState),
          type: InputComponentType.feedback,
          formKey: _feedbackFormKey,
          focusNode: _feedbackFocusNode,
          prefill: feedbackModel.feedbackMessage,
          autofocus: _emailFocusNode.hasFocus,
        );
      case FeedbackUiState.email:
        return InputComponent(
          key: ValueKey(uiState),
          type: InputComponentType.email,
          formKey: _emailFormKey,
          focusNode: _emailFocusNode,
          prefill: Provider.of<UserManager>(context, listen: false).userEmail,
          autofocus: _feedbackFocusNode.hasFocus,
        );
      case FeedbackUiState.success:
        return SuccessComponent(
          () {
            Provider.of<FeedbackModel>(context, listen: false).feedbackUiState =
                FeedbackUiState.hidden;
            Navigator.pop(context);
          },
        );
      default:
        return IntroComponent(_onFeedbackModeSelected);
    }
  }
}
