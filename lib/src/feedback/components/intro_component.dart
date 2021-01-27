import 'package:flutter/material.dart';
import 'package:wiredash/src/common/options/wiredash_options.dart';
import 'package:wiredash/src/common/translation/wiredash_localizations.dart';
import 'package:wiredash/src/common/widgets/list_tile_button.dart';
import 'package:wiredash/src/common/widgets/wiredash_icons.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';

class IntroComponent extends StatelessWidget {
  final void Function(FeedbackType)? onModeSelectedCallback;

  const IntroComponent(this.onModeSelectedCallback, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final options = WiredashOptions.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 16),
      child: Column(
        children: [
          if (options.bugReportButton) ...[
            const SizedBox(height: 12),
            ListTileButton(
              key: const ValueKey('wiredash.sdk.intro.report_a_bug_button'),
              icon: WiredashIcons.bug,
              iconColor: const Color(0xff9c4db1),
              iconBackgroundColor: const Color(0xffffc4f0),
              title: WiredashLocalizations.of(context)!.feedbackModeBugTitle,
              subtitle: WiredashLocalizations.of(context)!.feedbackModeBugMsg,
              onPressed: () => onModeSelectedCallback?.call(FeedbackType.bug),
            ),
          ],
          if (options.featureRequestButton) ...[
            const SizedBox(height: 12),
            ListTileButton(
              icon: WiredashIcons.feature,
              iconColor: const Color(0xff007cbc),
              iconBackgroundColor: const Color(0xff2bd9fc),
              title: WiredashLocalizations.of(context)!
                  .feedbackModeImprovementTitle,
              subtitle:
                  WiredashLocalizations.of(context)!.feedbackModeImprovementMsg,
              onPressed: () =>
                  onModeSelectedCallback?.call(FeedbackType.improvement),
            ),
          ],
          if (options.praiseButton) ...[
            const SizedBox(height: 12),
            ListTileButton(
              icon: WiredashIcons.applause,
              iconColor: const Color(0xff00b779),
              iconBackgroundColor: const Color(0xffcdfbcb),
              title: WiredashLocalizations.of(context)!.feedbackModePraiseTitle,
              subtitle:
                  WiredashLocalizations.of(context)!.feedbackModePraiseMsg,
              onPressed: () =>
                  onModeSelectedCallback?.call(FeedbackType.praise),
            ),
          ],
        ],
      ),
    );
  }
}
