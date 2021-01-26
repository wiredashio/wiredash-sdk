import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/translation/wiredash_localizations.dart';
import 'package:wiredash/src/common/utils/email_validator.dart';
import 'package:wiredash/src/common/widgets/wiredash_icons.dart';
import 'package:wiredash/src/wiredash_provider.dart';

enum InputComponentType { feedback, email }

class InputComponent extends StatefulWidget {
  final InputComponentType type;
  final GlobalKey<FormState> formKey;
  final FocusNode focusNode;
  final String prefill;
  final bool autofocus;

  const InputComponent(
      {Key key,
      @required this.type,
      @required this.formKey,
      @required this.focusNode,
      this.prefill = '',
      this.autofocus = false})
      : assert(type != null),
        assert(formKey != null),
        super(key: key);

  @override
  _InputComponentState createState() => _InputComponentState();
}

class _InputComponentState extends State<InputComponent> {
  TextEditingController _textEditingController;

  static const _maxInputLength = 2048;
  static const _lengthWarningThreshold = 50;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.prefill);
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.autofocus) {
        widget.focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final interactiveTextSelectionSupported =
        Localizations.of<MaterialLocalizations>(
                context, MaterialLocalizations) !=
            null;

    final wiredashTheme = WiredashTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Form(
        key: widget.formKey,
        child: TextFormField(
          key: const ValueKey('wiredash.sdk.text_field'),
          controller: _textEditingController,
          focusNode: widget.focusNode,
          style: wiredashTheme.inputTextStyle,
          cursorColor: wiredashTheme.primaryColor,
          validator: _validateInput,
          onSaved: _handleInput,
          maxLines: widget.type == InputComponentType.email ? 1 : null,
          enableInteractiveSelection: interactiveTextSelectionSupported,
          decoration: InputDecoration(
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: wiredashTheme.errorColor, width: 2),
            ),
            focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: wiredashTheme.errorColor, width: 2),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: wiredashTheme.dividerColor, width: 2),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: wiredashTheme.primaryColor, width: 2),
            ),
            icon: Icon(
              _getIcon(),
              color: wiredashTheme.dividerColor,
              size: 20,
            ),
            hintText: _getHintText(),
            hintStyle: wiredashTheme.inputHintStyle,
            errorStyle: wiredashTheme.inputErrorStyle,
            errorMaxLines: 2,
          ),
          maxLength: _maxInputLength,
          maxLengthEnforced: false,
          buildCounter: _getCounterText,
          textCapitalization: _getTextCapitalization(),
          keyboardAppearance: WiredashTheme.of(context).brightness,
          keyboardType: _getKeyboardType(),
        ),
      ),
    );
  }

  TextCapitalization _getTextCapitalization() {
    switch (widget.type) {
      case InputComponentType.feedback:
        return TextCapitalization.sentences;
        break;
      case InputComponentType.email:
        return TextCapitalization.none;
    }
    return TextCapitalization.sentences;
  }

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case InputComponentType.feedback:
        return TextInputType.text;
        break;
      case InputComponentType.email:
        return TextInputType.emailAddress;
    }
    return TextInputType.text;
  }

  IconData _getIcon() {
    switch (widget.type) {
      case InputComponentType.feedback:
        return WiredashIcons.edit;
      case InputComponentType.email:
        return WiredashIcons.email;
    }

    return null;
  }

  String _getHintText() {
    switch (widget.type) {
      case InputComponentType.feedback:
        return WiredashLocalizations.of(context).inputHintFeedback;
      case InputComponentType.email:
        return WiredashLocalizations.of(context).inputHintEmail;
    }

    return null;
  }

  Widget _getCounterText(BuildContext context,
      {int currentLength, int maxLength, bool isFocused}) {
    final theme = WiredashTheme.of(context);
    switch (widget.type) {
      case InputComponentType.feedback:
        final difference = maxLength - currentLength;
        return difference <= _lengthWarningThreshold
            ? Text(
                '$currentLength / $_maxInputLength',
                style: currentLength > maxLength
                    ? theme.inputHintStyle.copyWith(color: theme.errorColor)
                    : theme.inputHintStyle,
              )
            : null;
      default:
        return null;
    }
  }

  String _validateInput(String input) {
    switch (widget.type) {
      case InputComponentType.feedback:
        if (input.trim().isEmpty) {
          return WiredashLocalizations.of(context).validationHintFeedbackEmpty;
        } else if (input.characters.length > _maxInputLength) {
          return WiredashLocalizations.of(context).validationHintFeedbackLength;
        }
        break;
      case InputComponentType.email:
        if (input.isEmpty) {
          // It's okay to not provide an email address, in which we consider the
          // input to be valid.
          return null;
        }

        // If the email is non-null, we validate it.
        return debugEmailValidator.validate(input)
            ? null
            : WiredashLocalizations.of(context).validationHintEmail;
    }

    return null;
  }

  void _handleInput(String input) {
    switch (widget.type) {
      case InputComponentType.feedback:
        context.feedbackModel.feedbackMessage = input;
        break;
      case InputComponentType.email:
        context.userManager.userEmail = input;
        break;
    }
  }
}

@visibleForTesting
EmailValidator debugEmailValidator = const EmailValidator();
