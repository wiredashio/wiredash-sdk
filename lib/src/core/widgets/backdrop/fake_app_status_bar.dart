import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Fakes the system statusbar when the app is floating in [WiredashBackdrop]
class FakeAppStatusBar extends StatelessWidget {
  const FakeAppStatusBar({
    Key? key,
    required this.height,
    required this.color,
  }) : super(key: key);

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

    return DefaultTextStyle(
      style: TextStyle(
        shadows: const [
          Shadow(
            offset: Offset(2, 2),
            blurRadius: 2,
            color: Color.fromARGB(30, 0, 0, 0),
          ),
        ],
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
              Positioned.fill(
                child: Opacity(
                  opacity: 0.5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(
                        'assets/images/logo_white.png',
                        package: 'wiredash',
                        height: barContentHeight + 5,
                        color: blackOrWhite,
                      ),
                      SizedBox(width: 0.5 * barContentHeight),
                      const Text('Wiredash'),
                    ],
                  ),
                ),
              ),
              const Center(
                child: Text('Return to App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
