import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wiredash/src/common/widgets/fade_through_transition.dart';
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

    final opacity = () {
      if (backdrop.backdropStatus == WiredashBackdropStatus.closed ||
          backdrop.backdropStatus == WiredashBackdropStatus.closing ||
          backdrop.backdropStatus == WiredashBackdropStatus.opening) {
        return 0.0;
      }
      return 1.0;
    }();
    print("opacity: $opacity");
    return Stack(
      children: [
        child,
        Align(
          alignment: Alignment.topCenter,
          child: IgnorePointer(
            child: PageTransitionSwitcher(
              transitionBuilder: (child, a1, a2) {
                return FadeThroughTransition(
                  animation: a1,
                  secondaryAnimation: a2,
                  fillColor: Colors.transparent,
                  child: child,
                );
              },
              duration: const Duration(milliseconds: 300),
              child: opacity == 0
                  ? const SizedBox()
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
