import 'package:flutter/material.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/utils/email_validator.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';
import 'package:wiredash/src/feedback/ui/feedback_flow.dart';
import 'package:wiredash/wiredash.dart';

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
    _controller = TextEditingController(
      text: FeedbackModelProvider.of(context, listen: false).userEmail,
    )..addListener(() {
        final text = _controller.text;
        if (context.feedbackModel.userEmail != text) {
          context.feedbackModel.userEmail = text;
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StepPageScaffold(
      child: SafeArea(
        child: ScrollBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Optional step',
                    style: context.theme.captionTextStyle,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enter your email to get updates regarding your issue',
                    style: context.theme.titleTextStyle,
                  ),
                  TextFormField(
                    controller: _controller,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: context.theme.primaryColor,
                    style: context.theme.bodyTextStyle,
                    onFieldSubmitted: (_) {
                      if (context.feedbackModel.validateForm()) {
                        context.feedbackModel.submitFeedback();
                      }
                    },
                    validator: (data) {
                      final email = data ?? '';
                      if (email.isEmpty) {
                        // leaving this field empty is ok
                        return null;
                      }
                      final valid = const EmailValidator().validate(email);
                      return valid
                          ? null
                          : WiredashLocalizations.of(context)!
                              .validationHintEmail;
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      hintText: 'i.e. example@wiredash.io',
                      contentPadding: const EdgeInsets.only(top: 16),
                      hintStyle: context.theme.body2TextStyle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
