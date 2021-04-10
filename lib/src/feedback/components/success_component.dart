import 'package:flutter/material.dart';
import 'package:wiredash/src/common/translation/wiredash_localizations.dart';
import 'package:wiredash/src/common/widgets/list_tile_button.dart';
import 'package:wiredash/src/common/widgets/wiredash_icons.dart';

/// Feedback was successfully submitted -> close
class SuccessComponent extends StatelessWidget {
  final VoidCallback? onClosedCallback;

  const SuccessComponent(
    this.onClosedCallback, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          ListTileButton(
            key: const ValueKey('wiredash.sdk.exit_button'),
            icon: WiredashIcons.exit,
            iconColor: const Color(0xff9c4db1),
            iconBackgroundColor: const Color(0xffffc4f0),
            title: WiredashLocalizations.of(context)!
                .feedbackStateSuccessCloseTitle,
            subtitle:
                WiredashLocalizations.of(context)!.feedbackStateSuccessCloseMsg,
            onPressed: () => onClosedCallback?.call(),
          ),
        ],
      ),
    );
  }
}
