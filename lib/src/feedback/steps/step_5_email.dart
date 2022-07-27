import 'package:flutter/material.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';
import 'package:wiredash/src/core/support/widget_binding_support.dart';
import 'package:wiredash/src/feedback/_feedback.dart';
import 'package:wiredash/src/utils/email_validator.dart';

class Step5Email extends StatefulWidget {
  const Step5Email({Key? key}) : super(key: key);

  @override
  State<Step5Email> createState() => _Step5EmailState();
}

class _Step5EmailState extends State<Step5Email> with TickerProviderStateMixin {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final feedbackModel = FeedbackModelProvider.of(context, listen: false);
    _controller = TextEditingController(
      // read, not watch, because initState
      text: feedbackModel.hasEmailBeenEdited
          ? feedbackModel.userEmail
          : WiredashModelProvider.of(context, listen: false).metaData.userEmail,
    )..addListener(() {
        final text = _controller.text;
        print('Update userEmail $text');
        if (context.feedbackModel.userEmail != text) {
          context.feedbackModel.userEmail = text;
        }
      });
    widgetsBindingInstance.addPostFrameCallback((_) {
      if (!mounted) return;
      feedbackModel.userEmail = _controller.text;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isValidEmail(String? data) {
    final email = data ?? '';
    if (email.isEmpty) {
      // leaving this field empty is ok
      return true;
    }
    return const EmailValidator().validate(email);
  }

  @override
  Widget build(BuildContext context) {
    return StepPageScaffold(
      indicator:
          const FeedbackProgressIndicator(flowStatus: FeedbackFlowStatus.email),
      title: Text(context.l10n.feedbackStep4EmailTitle),
      breadcrumbTitle: Text(context.l10n.feedbackStep4EmailTitle),
      description: Text(context.l10n.feedbackStep4EmailDescription),
      discardLabel: Text(context.l10n.feedbackDiscardButton),
      discardConfirmLabel: Text(context.l10n.feedbackDiscardConfirmButton),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: TextFormField(
              controller: _controller,
              keyboardType: TextInputType.emailAddress,
              cursorColor: context.theme.primaryColor,
              style: context.text.input.onSurface,
              onFieldSubmitted: (_) {
                if (context.feedbackModel.validateForm()) {
                  context.feedbackModel.goToNextStep();
                }
              },
              validator: (data) {
                if (!_isValidEmail(data)) {
                  return context.l10n.feedbackStep4EmailInvalidEmail;
                }
                return null;
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: context.theme.surfaceColor,
                hoverColor: Colors.transparent,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: context.theme.secondaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: context.theme.secondaryColor),
                ),
                hintText: context.l10n.feedbackStep4EmailInputHint,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                hintStyle: context.text.input.onSurface.copyWith(
                  color: context.text.input.onSurface.color?.withOpacity(0.6),
                ),
                errorStyle: context.text.inputError.textStyle.copyWith(
                  color: context.theme.errorColor,
                ),
                errorMaxLines: 3,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TronButton(
                color: context.theme.secondaryColor,
                leadingIcon: Wirecons.arrow_left,
                label: context.l10n.feedbackBackButton,
                onTap: context.feedbackModel.goToPreviousStep,
              ),
              TronButton(
                label: context.l10n.feedbackNextButton,
                trailingIcon: Wirecons.arrow_right,
                onTap: () {
                  try {
                    context.feedbackModel.goToNextStep();
                  } on FormValidationException {
                    // validator triggered, TextFormField shows error
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
