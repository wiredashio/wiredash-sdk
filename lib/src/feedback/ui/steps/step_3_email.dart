import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';
import 'package:wiredash/src/feedback/ui/big_blue_button.dart';
import 'package:wiredash/src/feedback/ui/labeled_button.dart';
import 'package:wiredash/src/feedback/ui/larry_page_view.dart';
import 'package:wiredash/src/responsive_layout.dart';

class Step3Email extends StatefulWidget {
  const Step3Email({Key? key}) : super(key: key);

  @override
  _Step3EmailState createState() => _Step3EmailState();
}

class _Step3EmailState extends State<Step3Email> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EmailInput(),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveLayout.horizontalMargin,
            vertical: 16,
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 225),
            // ignore: deprecated_member_use
            vsync: this,
            clipBehavior: Clip.none,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 225),
              reverseDuration: const Duration(milliseconds: 170),
              switchInCurve: Curves.fastOutSlowIn,
              switchOutCurve: Curves.fastOutSlowIn,
              child: () {
                if (context.feedbackModel.userEmail?.isEmpty != false) {
                  return LabeledButton(
                    onTap: () {
                      StepInformation.of(context).pageView.moveToNextPage();
                    },
                    child: const Text('Skip'),
                  );
                }

                return BigBlueButton(
                  onTap: () {
                    StepInformation.of(context).pageView.moveToNextPage();
                  },
                  child: const Icon(Icons.arrow_right_alt),
                );
              }(),
            ),
          ),
        ),
      ],
    );
  }
}

class EmailInput extends StatefulWidget {
  const EmailInput({
    Key? key,
  }) : super(key: key);

  @override
  _EmailInputState createState() => _EmailInputState();
}

class _EmailInputState extends State<EmailInput> {
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
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveLayout.horizontalMargin,
        vertical: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              'Email',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 14),
            decoration: const InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              hintText: 'mail@wiredash.io',
              contentPadding: EdgeInsets.only(top: 16),
            ),
          ),
        ],
      ),
    );
  }
}
