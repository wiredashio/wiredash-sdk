import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/translation/wiredash_localizations.dart';
import 'package:wiredash/src/common/user/user_manager.dart';
import 'package:wiredash/src/common/widgets/wiredash_icons.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';

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

  String _validateInput(String input) {
    switch (widget.type) {
      case InputComponentType.feedback:
        if (input.isEmpty) {
          return WiredashLocalizations.of(context).validationHintFeedbackEmpty;
        } else if (input.length > 512) {
          return WiredashLocalizations.of(context).validationHintFeedbackLength;
        }
        break;
      case InputComponentType.email:
        if (input.isEmpty) return null;
        final isValidEmail = RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(input);
        if (isValidEmail) return null;
        return WiredashLocalizations.of(context).validationHintEmail;
    }

    return null;
  }

  void _handleInput(String input) {
    switch (widget.type) {
      case InputComponentType.feedback:
        Provider.of<FeedbackModel>(context, listen: false).feedbackMessage =
            input;
        break;
      case InputComponentType.email:
        Provider.of<UserManager>(context, listen: false).userEmail = input;
        break;
    }
  }
}
