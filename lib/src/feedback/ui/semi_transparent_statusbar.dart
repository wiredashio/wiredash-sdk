import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wiredash/src/_wiredash_ui.dart';

/// Draws a semi transparent statusbar on iOS to mimic the behavior on Android.
///
/// Usually, the [Scaffold] draws it, be we try to avoid material widgets in
/// Wiredash.
class SemiTransparentStatusBar extends StatelessWidget {
  const SemiTransparentStatusBar({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || !Platform.isIOS) {
      // only draw it on iOS
      return child;
    }

    final backdrop = context.backdropController;
    final bgColor = context.theme.primaryBackgroundColor;
    final luminance = bgColor.computeLuminance();
    final statusbarTextColor = luminance < 0.4
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    final bool showStatusBar =
        backdrop.backdropStatus != WiredashBackdropStatus.closed &&
            backdrop.backdropStatus != WiredashBackdropStatus.closing;
    return Stack(
      children: [
        child,
        Align(
          alignment: Alignment.topCenter,
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: statusbarTextColor,
            child: IgnorePointer(
              child: showStatusBar
                  ? SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).padding.top,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
