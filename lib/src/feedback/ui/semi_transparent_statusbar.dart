import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wiredash/src/wiredash_backdrop.dart';
import 'package:wiredash/src/wiredash_model_provider.dart';

/// Draws a semi transparent statusbar on iOS to mimic the behavior on Android.
///
/// Usually, the [Scaffold] draws it, be we try to avoid material widgets in Wiredash.
class SemiTransparentStatusBar extends StatelessWidget {
  const SemiTransparentStatusBar({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!Platform.isIOS) {
      // only draw it on iOS
      return child;
    }
    final backdrop = context.wiredashModel.state.backdropController;
    final isLight = context.wiredashModel.state.widget.theme?.brightness ==
        Brightness.light;
    return Stack(
      children: [
        child,
        Align(
          alignment: Alignment.topCenter,
          child: IgnorePointer(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: () {
                if (backdrop.backdropStatus == WiredashBackdropStatus.closed) {
                  return 0.0;
                }
                if (!backdrop.isAppInteractive) {
                  return 1.0;
                }
                return 0.0;
              }(),
              child: Container(
                color: isLight ? Colors.black26 : Colors.white30,
                height: MediaQuery.of(context).padding.top,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
