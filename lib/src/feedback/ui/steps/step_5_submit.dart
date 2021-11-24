import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/widgets/wirecons.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';
import 'package:wiredash/src/feedback/ui/big_blue_button.dart';
import 'package:wiredash/src/responsive_layout.dart';

class Step5Submit extends StatefulWidget {
  const Step5Submit({Key? key}) : super(key: key);

  @override
  _Step5SubmitState createState() => _Step5SubmitState();
}

class _Step5SubmitState extends State<Step5Submit> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveLayout.horizontalMargin,
        vertical: 16,
      ),
      child: Container(
        // TODO required?
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Summary',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Message: ${context.feedbackModel.feedbackMessage}\n'
                '\n'
                'Email: ${context.feedbackModel.userEmail}\n'
                '\n'
                'Screenshots: 0\n'
                '\n'
                'AppVersion: TODO\n'
                'Browser Version: TODO\n'
                'Whatever is useful\n',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Center(
                child: BigBlueButton(
                  text: const Text('Submit'),
                  onTap: () {
                    context.feedbackModel.submitFeedback();
                  },
                  child: const Icon(Wirecons.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
