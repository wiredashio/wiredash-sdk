import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';
import 'package:wiredash/src/feedback/ui/big_blue_button.dart';
import 'package:wiredash/src/feedback/ui/feedback_flow.dart';
import 'package:wiredash/src/feedback/ui/labeled_button.dart';
import 'package:wiredash/src/feedback/ui/larry_page_view.dart';

class Step3ScreenshotOverview extends StatefulWidget {
  const Step3ScreenshotOverview({Key? key}) : super(key: key);

  @override
  _Step3ScreenshotOverviewState createState() =>
      _Step3ScreenshotOverviewState();
}

class _Step3ScreenshotOverviewState extends State<Step3ScreenshotOverview> {
  @override
  Widget build(BuildContext context) {
    return StepPageScaffold(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Do you want to create a screenshot that explains what you want to say?',
              style: context.theme.titleTextStyle,
            ),
            SizedBox(height: context.theme.titleTextStyle.fontSize!),
            Text(
              'You can still use the app and can take a screenshot when it’s the right screen.',
              style: context.theme.titleTextStyle
                  .copyWith(color: context.theme.secondaryTextColor),
            ),
          ],
        ),
      ),
    );
  }
}
