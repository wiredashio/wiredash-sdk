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

  Color withHslSaturation(double saturation) {
    assert(saturation >= 0 && saturation <= 1);
    return HSLColor.fromColor(this).withSaturation(saturation).toColor();
  }

  Color withHsvSaturation(double saturation) {
    assert(saturation >= 0 && saturation <= 1);
    return HSVColor.fromColor(this).withSaturation(saturation).toColor();
  }

  Color adjustHslSaturation(double Function(double saturation) fn) {
    final hslColor = HSLColor.fromColor(this);
    return hslColor.withSaturation(fn(hslColor.saturation)).toColor();
  }

  Color adjustHsvSaturation(double Function(double saturation) fn) {
    final hsvColor = HSVColor.fromColor(this);
    return hsvColor.withSaturation(fn(hsvColor.saturation)).toColor();
  }

  Color withHue(double hue) {
    assert(hue >= 0 && hue <= 1);
    return HSLColor.fromColor(this).withHue(hue).toColor();
  }

  Color shiftHue(double shift) {
    final hslColor = HSLColor.fromColor(this);
    return hslColor.withHue((hslColor.hue + shift) % 360).toColor();
  }

  Color adjustHue(double Function(double hue) fn) {
    final hslColor = HSLColor.fromColor(this);
    return hslColor.withHue(fn(hslColor.hue)).toColor();
  }

  Color withLightness(double lightness) {
    assert(lightness >= 0 && lightness <= 1);
    return HSLColor.fromColor(this).withLightness(lightness).toColor();
  }

  Color adjustValue(double Function(double value) fn) {
    final hsvColor = HSVColor.fromColor(this);
    return hsvColor.withValue(fn(hsvColor.value)).toColor();
  }

  Color withValue(double value) {
    assert(value >= 0 && value <= 1);
    return HSVColor.fromColor(this).withValue(value).toColor();
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
    // Changed in Flutter 3.26 https://github.com/flutter/engine/pull/54737
    // ignore: deprecated_member_use
    final grayscale = (0.299 * red) + (0.587 * green) + (0.114 * blue);

    if (grayscale > 128) {
      return Brightness.light;
    } else {
      return Brightness.dark;
    }
  }
}
