import 'dart:ui';

import 'package:flutter/painting.dart';

extension ColorBrightness on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color desaturate([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark =
        hsl.withSaturation((hsl.saturation - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color saturate([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark =
        hsl.withSaturation((hsl.saturation + amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  Brightness get brightness {
    final grayscale = (0.299 * red) + (0.587 * green) + (0.114 * blue);

    if (grayscale > 128) {
      return Brightness.light;
    } else {
      return Brightness.dark;
    }
  }
}
