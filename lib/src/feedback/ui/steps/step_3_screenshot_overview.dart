import 'package:flutter/material.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/widgets/wirecons.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';
import 'package:wiredash/src/feedback/ui/feedback_flow.dart';

class Step3ScreenshotOverview extends StatefulWidget {
  const Step3ScreenshotOverview({Key? key}) : super(key: key);

  @override
  State<Step3ScreenshotOverview> createState() =>
      _Step3ScreenshotOverviewState();
}

class _Step3ScreenshotOverviewState extends State<Step3ScreenshotOverview> {
  @override
  Widget build(BuildContext context) {
    if (context.feedbackModel.hasScreenshots) {
      return StepPageScaffold(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Add, edit or remove',
                style: context.theme.captionTextStyle,
              ),
              const SizedBox(height: 12),
              Text(
                'Attached screenshots',
                style: context.theme.titleTextStyle,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        Image.memory(
                          context.feedbackModel.screenshot!,
                          width: 160, // 160
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.black38, Colors.black12],
                              ),
                            ),
                            width: 160,
                            alignment: Alignment.center,
                            child: const Icon(
                              Wirecons.trash,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 160,
                    height: 100, // 100
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: context.theme.secondaryColor,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Wirecons.plus,
                      color: context.theme.primaryColor,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return StepPageScaffold(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Do you want to create a screenshot that explains what you '
                'want to say?',
                style: context.theme.titleTextStyle,
              ),
              SizedBox(height: context.theme.titleTextStyle.fontSize),
              Text(
                'You will be able to navigate through the app and take a '
                'screenshot on the right screen.',
                style: context.theme.titleTextStyle
                    .copyWith(color: context.theme.secondaryTextColor),
              ),
            ],
          ),
        ),
      );
    }
  }
}
