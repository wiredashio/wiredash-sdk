import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Fakes the system statusbar when the app is floating in [WiredashBackdrop]
class FakeAppStatusBar extends StatelessWidget {
  const FakeAppStatusBar({
    Key? key,
    required this.height,
  }) : super(key: key);

  final double height;

  @override
  Widget build(BuildContext context) {
    final double barContentHeight = math.min(12, height);

    return DefaultTextStyle(
      style: TextStyle(
        shadows: const [
          Shadow(
            offset: Offset(2, 2),
            blurRadius: 2,
            color: Color.fromARGB(30, 0, 0, 0),
          ),
        ],
        // TODO make the fake systemChromeUi style customizable in WiredashTheme
        color: Colors.white,
        fontSize: barContentHeight,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black12,
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
                        height: barContentHeight,
                      ),
                      const SizedBox(width: 8),
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
