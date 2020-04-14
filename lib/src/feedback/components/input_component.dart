import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/state/wiredash_state.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/translation/wiredash_translation.dart';
import 'package:wiredash/src/common/widgets/wiredash_icons.dart';

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
          ),
          keyboardType: TextInputType.emailAddress,
        ),
      ),
    );
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
        return WiredashTranslation.of(context).inputHintFeedback;
      case InputComponentType.email:
        return WiredashTranslation.of(context).inputHintEmail;
    }

    return null;
  }

  String _validateInput(String input) {
    switch (widget.type) {
      case InputComponentType.feedback:
        if (input.isEmpty) {
          return WiredashTranslation.of(context).validationHintFeedbackEmpty;
        } else if (input.length > 512) {
          return WiredashTranslation.of(context).validationHintFeedbackLength;
        }
        break;
      case InputComponentType.email:
        if (input.isEmpty) return null;
        final isValidEmail = RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(input);
        if (isValidEmail) return null;
        return WiredashTranslation.of(context).validationHintEmail;
    }

    return null;
  }

  void _handleInput(String input) {
    final state = WiredashState.of(context, listen: false);
    switch (widget.type) {
      case InputComponentType.feedback:
        state.feedbackMessage = input;
        break;
      case InputComponentType.email:
        state.userEmail = input;
        break;
    }
  }
}
