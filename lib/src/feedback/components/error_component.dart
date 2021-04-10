import 'package:flutter/material.dart';
import 'package:wiredash/src/common/translation/wiredash_localizations.dart';
import 'package:wiredash/src/common/widgets/list_tile_button.dart';
import 'package:wiredash/src/common/widgets/wiredash_icons.dart';

/// Retry button for submission errors
class ErrorComponent extends StatelessWidget {
  final VoidCallback onRetry;

  const ErrorComponent({Key? key, required this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: ListTileButton(
        key: const ValueKey('wiredash.sdk.retry_button'),
        icon: WiredashIcons.redo,
        iconColor: const Color(0xff9c4db1),
        iconBackgroundColor: const Color(0xffffc4f0),
        title: WiredashLocalizations.of(context)!.feedbackSubmitRetryTitle,
        subtitle: WiredashLocalizations.of(context)!.feedbackSubmitRetryMsg,
        onPressed: onRetry,
      ),
    );
  }
}
