import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wiredash/src/common/widgets/animated_fade_widget_switcher.dart';
import 'package:wiredash/src/feedback/backdrop/backdrop_controller_provider.dart';
import 'package:wiredash/src/feedback/backdrop/wiredash_backdrop.dart';
import 'package:wiredash/src/wiredash_model_provider.dart';

/// Draws a semi transparent statusbar on iOS to mimic the behavior on Android.
///
/// Usually, the [Scaffold] draws it, be we try to avoid material widgets in
/// Wiredash.
class SemiTransparentStatusBar extends StatelessWidget {
  const SemiTransparentStatusBar({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || !Platform.isIOS) {
      // only draw it on iOS
      return child;
    }

    final backdrop = context.backdropController;
    final brightness =
        context.wiredashModel.services.wiredashWidget.theme?.brightness;
    final isLight = brightness == Brightness.light;

    final bool showStatusBar =
        backdrop.backdropStatus != WiredashBackdropStatus.closed &&
            backdrop.backdropStatus != WiredashBackdropStatus.closing;
    return Stack(
      children: [
        child,
        Align(
          alignment: Alignment.topCenter,
          child: IgnorePointer(
            child: AnimatedFadeWidgetSwitcher(
              fadeInOnEnter: true,
              duration: const Duration(milliseconds: 300),
              child: !showStatusBar
                  ? null
                  : Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).padding.top,
                      color: isLight ? Colors.white30 : Colors.black26,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
