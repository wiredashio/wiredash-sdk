import 'package:flutter/material.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/widgets/wirecons.dart';
import 'package:wiredash/src/feedback/ui/feedback_flow.dart';

class Step6Submit extends StatefulWidget {
  const Step6Submit({Key? key}) : super(key: key);

  @override
  State<Step6Submit> createState() => _Step6SubmitState();
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
              const SizedBox(
                height: 24,
              ),
              Icon(
                Wirecons.check,
                size: 48,
                color: context.theme.primaryColor,
              ),
              const SizedBox(
                height: 20,
              ),
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
