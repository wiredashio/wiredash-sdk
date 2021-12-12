import 'package:flutter/material.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/widgets/wirecons.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';
import 'package:wiredash/src/feedback/ui/feedback_flow.dart';
import 'package:wiredash/src/feedback/ui/labeled_button.dart';

class Step6Submit extends StatefulWidget {
  const Step6Submit({Key? key}) : super(key: key);

  @override
  _Step6SubmitState createState() => _Step6SubmitState();
}

class _Step6SubmitState extends State<Step6Submit> {
  @override
  Widget build(BuildContext context) {
    return StepPageScaffold(
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 24,),
              Icon(Wirecons.check, size: 48, color: context.theme.primaryColor,),
              SizedBox(height: 20,),
              Text(
                'Thanks for your feedback!',
                style: context.theme.titleTextStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
