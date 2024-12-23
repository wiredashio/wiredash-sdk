import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/theme/wirecons.dart';

/// Fakes the system statusbar when the app is floating in [WiredashBackdrop]
class FakeAppStatusBar extends StatelessWidget {
  const FakeAppStatusBar({
    super.key,
    required this.height,
    required this.color,
  });

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isMobile = defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    final double barContentHeight = math.min(isMobile ? 14 : 16, height);

    final luminance = color.computeLuminance();
    final blackOrWhite =
        luminance < 0.4 ? const Color(0xffffffff) : const Color(0xff000000);

    return ClipRect(
      child: DefaultTextStyle(
        style: TextStyle(
          color: blackOrWhite,
          fontSize: barContentHeight,
        ),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: color,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 2,
            ),
            child: Stack(
              children: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Wirecons.cheveron_up,
                        // ignore: deprecated_member_use
                        color: blackOrWhite.withOpacity(0.80),
                        size: 16,
                      ),
                      const SizedBox(width: 16),
                      Text(context.l10n.backdropReturnToApp),
                      const SizedBox(width: 16),
                      Icon(
                        Wirecons.cheveron_up,
                        // ignore: deprecated_member_use
                        color: blackOrWhite.withOpacity(0.80),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
