import 'package:flutter/material.dart';
import 'package:wiredash/src/common/translation/wiredash_translation.dart';
import 'package:wiredash/src/common/widgets/list_tile_button.dart';
import 'package:wiredash/src/common/widgets/wiredash_icons.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';

class IntroComponent extends StatelessWidget {
  final Function(FeedbackType) onModeSelectedCallback;

  const IntroComponent(this.onModeSelectedCallback, {Key key})
      : assert(onModeSelectedCallback != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 8),
          ListTileButton(
            icon: WiredashIcons.bug,
            iconColor: const Color(0xff9c4db1),
            iconBackgroundColor: const Color(0xffffc4f0),
            title: WiredashTranslation.of(context).feedbackModeBugTitle,
            subtitle: WiredashTranslation.of(context).feedbackModeBugMsg,
            onPressed: () => onModeSelectedCallback(FeedbackType.bug),
          ),
          const SizedBox(height: 12),
          ListTileButton(
            icon: WiredashIcons.feature,
            iconColor: const Color(0xff007cbc),
            iconBackgroundColor: const Color(0xff2bd9fc),
            title: WiredashTranslation.of(context).feedbackModeImprovementTitle,
            subtitle:
                WiredashTranslation.of(context).feedbackModeImprovementMsg,
            onPressed: () => onModeSelectedCallback(FeedbackType.improvement),
          ),
          const SizedBox(height: 12),
          ListTileButton(
            icon: WiredashIcons.applause,
            iconColor: const Color(0xff00b779),
            iconBackgroundColor: const Color(0xffcdfbcb),
            title: WiredashTranslation.of(context).feedbackModePraiseTitle,
            subtitle: WiredashTranslation.of(context).feedbackModePraiseMsg,
            onPressed: () => onModeSelectedCallback(FeedbackType.praise),
          ),
        ],
      ),
    );
  }
}
