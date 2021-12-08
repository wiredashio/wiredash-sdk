import 'package:flutter/material.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';
import 'package:wiredash/src/feedback/ui/feedback_flow.dart';

class Step5Email extends StatefulWidget {
  const Step5Email({Key? key}) : super(key: key);

  @override
  _Step5EmailState createState() => _Step5EmailState();
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    'Email',
                    style: context.theme.titleTextStyle,
                  ),
                ),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.emailAddress,
                  style: context.theme.bodyTextStyle,
                  onSubmitted: (_) {
                    context.feedbackModel
                        .goToStep(FeedbackFlowStatus.submitting);
                  },
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
          ],
        ),
      ),
    );
  }
}
