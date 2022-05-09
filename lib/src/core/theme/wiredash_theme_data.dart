import 'dart:ui' show Brightness;

import 'package:flutter/rendering.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:wiredash/src/core/theme/color_ext.dart';
import 'package:wiredash/src/core/theme/key_point_interpolator.dart';

class WiredashThemeData {
  factory WiredashThemeData({
    Brightness brightness = Brightness.light,
    DeviceClass deviceClass = DeviceClass.handsetLarge400,
    Color? primaryColor,
    Color? secondaryColor,
    Color? primaryBackgroundColor,
    Color? secondaryBackgroundColor,
    Color? primaryContainerColor,
    Color? textOnPrimaryContainerColor,
    Color? secondaryContainerColor,
    Color? textOnSecondaryContainerColor,
    Color? appBackgroundColor,
    Color? appHandleBackgroundColor,
    Color? errorColor,
    String? fontFamily,
    Size? windowSize,
  }) {
    return WiredashThemeData._(
      primaryColor: primaryColor ?? const Color(0xff1A56DB),
      secondaryColor: secondaryColor,
      brightness: brightness,
      deviceClass: deviceClass,
      windowSize: windowSize ?? Size.zero,
      primaryBackgroundColor: primaryBackgroundColor,
      secondaryBackgroundColor: secondaryBackgroundColor,
      primaryContainerColor: primaryContainerColor,
      textOnPrimaryContainerColor: textOnPrimaryContainerColor,
      secondaryContainerColor: secondaryContainerColor,
      textOnSecondaryContainerColor: textOnSecondaryContainerColor,
      appBackgroundColor: appBackgroundColor,
      appHandleBackgroundColor: appHandleBackgroundColor,
      errorColor: errorColor,
      fontFamily: fontFamily,
    );
  }

  factory WiredashThemeData.fromColor({
    required Color primaryColor,
    Color? secondaryColor,
    required Brightness brightness,
  }) {
    if (secondaryColor?.value == primaryColor.value) {
      secondaryColor = null;
    }

    final theme = WiredashThemeData(
      brightness: brightness,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
    );

    return theme;
  }

  WiredashThemeData._({
    required this.brightness,
    required this.primaryColor,
    Color? secondaryColor,
    Color? textOnPrimary,
    Color? textOnSecondary,
    Color? primaryBackgroundColor,
    Color? secondaryBackgroundColor,
    Color? primaryContainerColor,
    Color? textOnPrimaryContainerColor,
    Color? secondaryContainerColor,
    Color? textOnSecondaryContainerColor,
    Color? appBackgroundColor,
    Color? appHandleBackgroundColor,
    Color? errorColor,
    String? fontFamily,
    required this.deviceClass,
    required this.windowSize,
  })  : _secondaryColor = secondaryColor,
        _textOnPrimary = textOnPrimary,
        _textOnSecondary = textOnSecondary,
        _primaryBackgroundColor = primaryBackgroundColor,
        _secondaryBackgroundColor = secondaryBackgroundColor,
        _primaryContainerColor = primaryContainerColor,
        _textOnPrimaryContainerColor = textOnPrimaryContainerColor,
        _secondaryContainerColor = secondaryContainerColor,
        _textOnSecondaryContainerColor = textOnSecondaryContainerColor,
        _appBackgroundColor = appBackgroundColor,
        _appHandleBackgroundColor = appHandleBackgroundColor,
        _errorColor = errorColor,
        _fontFamily = fontFamily;

  final Brightness brightness;
  bool get isLight => brightness == Brightness.light;

  // --- Primary --- //
  final Color primaryColor;
  MaterialColorTone? __primaryTone;
  MaterialColorTone get _primaryTone {
    return __primaryTone ??= MaterialColorTone(primaryColor, brightness);
  }

  final Color? _textOnPrimary;
  Color get textOnPrimaryColor {
    final tone = isLight ? 100 : 0;
    return _textOnPrimary ?? _primaryTone.primaryTone(tone);
  }

  // --- Secondary --- //
  final Color? _secondaryColor;
  Color get secondaryColor => _secondaryColor ?? _secondaryTone.baseColor;
  MaterialColorTone? __secondaryTone;
  MaterialColorTone get _secondaryTone {
    return __secondaryTone ??= MaterialColorTone(
      _secondaryColor ??
          () {
            if (isLight) {
              return primaryColor
                  // .shiftHue(-10)
                  // .withValue(0.98)
                  .adjustValue(
                    (value) => KeyPointInterpolator({0: 0.70, 1: 0.90})
                        .interpolate(value),
                  )
                  .adjustHsvSaturation(
                    (saturation) => KeyPointInterpolator({0: 0.12, 1: 0.2})
                        .interpolate(saturation),
                  );
            } else {
              return primaryColor
                  .adjustValue(
                    (value) => KeyPointInterpolator({0: 0.00, 1: 0.50})
                        .interpolate(value),
                  )
                  .adjustHsvSaturation(
                    (saturation) => KeyPointInterpolator({0: 0.02, 1: 0.2})
                        .interpolate(saturation),
                  );
            }
          }(),
      brightness,
    );
  }

  final Color? _textOnSecondary;
  Color get textOnSecondaryColor {
    final tone = isLight ? 99 : 1;
    return _textOnSecondary ?? _secondaryTone.primaryTone(tone);
  }

  // --- primaryContainer --- //
  final Color? _primaryContainerColor;
  Color get primaryContainerColor {
    return _primaryContainerColor ?? _primaryTone.primaryContainer;
  }

  final Color? _textOnPrimaryContainerColor;
  Color get textOnPrimaryContainerColor {
    return _textOnPrimaryContainerColor ?? _primaryTone.onPrimaryContainer;
  }

  // --- secondadryContainer --- //
  final Color? _secondaryContainerColor;
  Color get secondaryContainerColor =>
      _secondaryContainerColor ?? _secondaryTone.primaryContainer;

  final Color? _textOnSecondaryContainerColor;
  Color get textOnSecondaryContainerColor {
    return _textOnSecondaryContainerColor ?? _secondaryTone.onPrimaryContainer;
  }

  // --- Background --- //
  final Color? _primaryBackgroundColor;
  Color get primaryBackgroundColor {
    if (brightness == Brightness.light) {
      return _primaryBackgroundColor ?? _primaryTone.primaryTone(100);
    } else {
      return _primaryBackgroundColor ??
          primaryColor.withHslSaturation(0.08).withLightness(0.2);
    }
  }

  final Color? _secondaryBackgroundColor;
  Color get secondaryBackgroundColor {
    if (brightness == Brightness.light) {
      return _secondaryBackgroundColor ?? _primaryTone.primaryTone(98);
    } else {
      return _secondaryBackgroundColor ??
          secondaryColor.withHslSaturation(0.0).withLightness(0.05);
    }
  }

  Color get primaryTextOnBackgroundColor {
    final merged =
        Color.lerp(primaryBackgroundColor, secondaryBackgroundColor, 0.5)!;
    final palette = CorePalette.of(merged.value);

    final tone = isLight ? 10 : 100;
    return Color(palette.neutralVariant.get(tone));
  }

  Color get secondaryTextOnBackgroundColor {
    final merged =
        Color.lerp(primaryBackgroundColor, secondaryBackgroundColor, 0.5)!;
    final palette = CorePalette.of(merged.value);

    final tone = isLight ? 40 : 70;
    return Color(palette.neutralVariant.get(tone));
  }

  final Color? _appBackgroundColor;
  Color get appBackgroundColor {
    return _appBackgroundColor ??
        (brightness == Brightness.light
            ? const Color(0xfff5f6f8)
            : const Color(0xff3d3e3e));
  }

  /// The color of the app handle, the "Return to app" bar above the app
  final Color? _appHandleBackgroundColor;
  Color get appHandleBackgroundColor {
    return _appHandleBackgroundColor ?? _primaryTone.primaryTone(20);
  }

  // --- Surface --- //
  Color get surfaceColor {
    return _primaryTone.surface;
  }

  Color get primaryTextOnSurfaceColor {
    return _primaryTone.onSurface;
  }

  Color get secondaryTextOnSurfaceColor {
    return _primaryTone.onSurface.withOpacity(0.8);
  }

  // --- Error --- //
  final Color? _errorColor;
  Color get errorColor => _errorColor ?? _primaryTone.error;

  final DeviceClass deviceClass;
  final Size windowSize;

  final String? _fontFamily;
  String get fontFamily {
    return _fontFamily ?? _defaultFontFamily;
  }

  static const _defaultFontFamily = 'Inter';

  String? get _packageName =>
      fontFamily == _defaultFontFamily ? 'wiredash' : null;

  TextStyle get headlineTextStyle => TextStyle(
        package: _packageName,
        fontFamily: fontFamily,
        fontSize: windowSize.shortestSide > 480 ? 32 : 24,
        color: primaryTextOnSurfaceColor,
        fontWeight: FontWeight.bold,
      );

  TextStyle get appbarTitle => TextStyle(
        package: _packageName,
        fontFamily: fontFamily,
        fontSize: 16,
        color: primaryTextOnSurfaceColor,
        fontWeight: FontWeight.bold,
      );

  TextStyle get titleTextStyle => TextStyle(
        package: _packageName,
        fontFamily: fontFamily,
        fontSize: 20,
        color: primaryTextOnSurfaceColor,
        fontWeight: FontWeight.bold,
      );

  TextStyle get tronButtonTextStyle => TextStyle(
        package: _packageName,
        fontFamily: fontFamily,
        fontSize: 14,
        color: primaryTextOnSurfaceColor,
        fontWeight: FontWeight.w600,
      );

  TextStyle get bodyTextStyle => TextStyle(
        package: _packageName,
        fontFamily: fontFamily,
        fontSize: windowSize.shortestSide > 480 ? 16 : 14,
        color: primaryTextOnSurfaceColor,
        fontWeight: FontWeight.normal,
      );

  TextStyle get body2TextStyle => TextStyle(
        package: _packageName,
        fontFamily: fontFamily,
        fontSize: windowSize.shortestSide > 480 ? 16 : 14,
        color: secondaryTextOnSurfaceColor,
        fontWeight: FontWeight.normal,
      );

  TextStyle get captionTextStyle => TextStyle(
        package: _packageName,
        fontFamily: fontFamily,
        fontSize: 12,
        color: secondaryTextOnSurfaceColor,
        fontWeight: FontWeight.normal,
      );

  TextStyle get inputTextStyle => TextStyle(
        package: _packageName,
        fontFamily: fontFamily,
        fontSize: 14,
        color: primaryTextOnSurfaceColor,
      );

  TextStyle get inputErrorTextStyle => TextStyle(
        package: _packageName,
        fontFamily: fontFamily,
        fontSize: 12,
        color: errorColor,
      );

  double get horizontalPadding {
    final keypoints = KeyPointInterpolator({
      320: 8,
      360: 16,
      400: 32,
      600: 64,
      720: 64,
      1024: 128,
    });
    return keypoints.interpolate(windowSize.width);
  }

  double get verticalPadding {
    final keypoints = KeyPointInterpolator({
      400: 40,
      600: 64,
    });
    return keypoints.interpolate(windowSize.width);
  }

  double get maxContentWidth {
    final width = windowSize.width;
    final keypoints = KeyPointInterpolator({
      0: 0,
      720: 720,
      1024: 1024.0 * 0.75,
      2048: 1024,
    });
    return keypoints.interpolate(width);
  }

  double get minContentHeight {
    final height = windowSize.height;
    final keypoints = KeyPointInterpolator({
      0: 320,
      320: 320, // iPhone SE landscape
      1024: 400,
    });
    return keypoints.interpolate(height);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WiredashThemeData &&
          runtimeType == other.runtimeType &&
          brightness == other.brightness &&
          primaryColor == other.primaryColor &&
          secondaryColor == other.secondaryColor &&
          textOnPrimaryColor == other.textOnPrimaryColor &&
          textOnSecondaryColor == other.textOnSecondaryColor &&
          primaryBackgroundColor == other.primaryBackgroundColor &&
          textOnPrimaryContainerColor == other.textOnPrimaryContainerColor &&
          secondaryBackgroundColor == other.secondaryBackgroundColor &&
          textOnSecondaryContainerColor ==
              other.textOnSecondaryContainerColor &&
          primaryContainerColor == other.primaryContainerColor &&
          secondaryContainerColor == other.secondaryContainerColor &&
          appBackgroundColor == other.appBackgroundColor &&
          appHandleBackgroundColor == other.appHandleBackgroundColor &&
          errorColor == other.errorColor &&
          deviceClass == other.deviceClass &&
          windowSize == other.windowSize &&
          fontFamily == other.fontFamily;

  @override
  int get hashCode =>
      brightness.hashCode ^
      primaryColor.hashCode ^
      secondaryColor.hashCode ^
      textOnPrimaryColor.hashCode ^
      textOnSecondaryColor.hashCode ^
      primaryBackgroundColor.hashCode ^
      secondaryBackgroundColor.hashCode ^
      primaryContainerColor.hashCode ^
      textOnPrimaryContainerColor.hashCode ^
      secondaryContainerColor.hashCode ^
      textOnSecondaryContainerColor.hashCode ^
      appBackgroundColor.hashCode ^
      appHandleBackgroundColor.hashCode ^
      errorColor.hashCode ^
      deviceClass.hashCode ^
      windowSize.hashCode ^
      fontFamily.hashCode;

  @override
  String toString() {
    return 'WiredashThemeData{'
        'brightness: $brightness, '
        'primaryColor: $primaryColor, '
        'secondaryColor: $secondaryColor, '
        'textOnPrimaryColor: $textOnPrimaryColor, '
        'textOnSecondaryColor: $textOnSecondaryColor, '
        'primaryBackgroundColor: $primaryBackgroundColor, '
        'secondaryBackgroundColor: $secondaryBackgroundColor, '
        'primaryContainerColor: $primaryContainerColor, '
        'textOnPrimaryContainerColor: $textOnPrimaryContainerColor, '
        'secondaryContainerColor: $secondaryContainerColor, '
        'textOnSecondaryContainerColor: $textOnSecondaryContainerColor, '
        'appBackgroundColor: $appBackgroundColor, '
        'appHandleBackgroundColor: $appHandleBackgroundColor, '
        'errorColor: $errorColor, '
        'deviceClass: $deviceClass, '
        'fontFamily: $fontFamily, '
        'windowSize: $windowSize, '
        '}';
  }

  WiredashThemeData copyWith({
    Brightness? brightness,
    Color? primaryColor,
    Color? secondaryColor,
    Color? primaryBackgroundColor,
    Color? secondaryBackgroundColor,
    Color? primaryContainerColor,
    Color? textOnPrimaryContainerColor,
    Color? secondaryContainerColor,
    Color? textOnSecondaryContainerColor,
    Color? appBackgroundColor,
    Color? appHandleBackgroundColor,
    Color? errorColor,
    DeviceClass? deviceClass,
    String? fontFamily,
    Size? windowSize,
  }) {
    return WiredashThemeData(
      brightness: brightness ?? this.brightness,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      primaryBackgroundColor:
          primaryBackgroundColor ?? this.primaryBackgroundColor,
      secondaryBackgroundColor:
          secondaryBackgroundColor ?? this.secondaryBackgroundColor,
      primaryContainerColor:
          primaryContainerColor ?? this.primaryContainerColor,
      textOnPrimaryContainerColor:
          textOnPrimaryContainerColor ?? this.textOnPrimaryContainerColor,
      secondaryContainerColor:
          secondaryContainerColor ?? this.secondaryContainerColor,
      textOnSecondaryContainerColor:
          textOnSecondaryContainerColor ?? this.textOnSecondaryContainerColor,
      appBackgroundColor: appBackgroundColor ?? this.appBackgroundColor,
      appHandleBackgroundColor:
          appHandleBackgroundColor ?? this.appHandleBackgroundColor,
      errorColor: errorColor ?? this.errorColor,
      deviceClass: deviceClass ?? this.deviceClass,
      fontFamily: fontFamily ?? this.fontFamily,
      windowSize: windowSize ?? this.windowSize,
    );
  }
}

enum DeviceClass {
  /// iPhone SE is 320 width which is the bare minimum for our design to work
  handsetSmall320,

  /// Pixel 4A/5 width: 393
  /// Samsung Galaxy S21 Ultra (2021) width: 384
  /// iPhone 12 mini (2020) width: 360
  handsetMedium360,

  /// Sony Xperia Z4 portrait width: 534
  /// iPhone 12 pro max (2020) width: 428
  /// iPhone 6+, 6S+, 7+, 8+ width: 414
  /// Google Pixel 4 XL width: 412
  handsetLarge400,

  /// Amazon Kindle Fire portrait width: 600
  tabletSmall600,

  /// Microsoft Surface Book width: 1000
  /// Apple iPhone 12 Pro Max (2020) landscape width: 926
  /// MacBook Pro 16" 2019 (default scale) split screen width: 896
  /// Samsung Galaxy Z Fold2 (2020) width: 884
  /// iPad Pro portrait width: 834
  /// iPad Air 4 portrait width: 820
  /// iPad portrait width: 768
  tabletLarge720,

  /// iPad Pro 12.9 landscape width: 1366
  /// Macbook Pro 13" 2018: 1280
  /// iPad Pro 11 landscape with: 1194
  /// iPad Pro 10.5 landscape with: 1112
  /// iPad landscape with: 1024
  /// iPad Pro 12" width: 1024
  /// Microsoft Surface Pro 3 width: 1024
  desktopSmall1024,

  /// MacBook Pro 16" 2019 (more space) width: 2048
  /// MacBook Pro 16" 2019 (default scale) width: 1792
  /// MacBook Pro 16" 2019 (medium scale) width: 1536
  /// MacBook Pro 15" 2018 width: 1440
  desktopLarge1440
}

/// Based on the theory in https://m3.material.io/styles/color/dynamic-color/user-generated-color
class MaterialColorTone {
  MaterialColorTone(this.baseColor, this.brightness)
      : palette = CorePalette.of(baseColor.value);
  final Color baseColor;
  final CorePalette palette;
  final Brightness brightness;
  bool get _isLight => brightness == Brightness.light;

  Color primaryTone(int tone) => Color(palette.primary.get(tone));
  Color get primary => primaryTone(_isLight ? 40 : 80);
  Color get onPrimary => primaryTone(_isLight ? 100 : 20);
  Color get primaryContainer => primaryTone(_isLight ? 90 : 30);
  Color get onPrimaryContainer => primaryTone(_isLight ? 10 : 90);

  Color secondaryTone(int tone) => Color(palette.secondary.get(tone));
  Color get secondary => secondaryTone(_isLight ? 40 : 80);
  Color get onSecondary => secondaryTone(_isLight ? 100 : 20);
  Color get secondaryContainer => secondaryTone(_isLight ? 90 : 30);
  Color get onSecondaryContainer => secondaryTone(_isLight ? 10 : 90);

  Color tertiaryTone(int tone) => Color(palette.tertiary.get(tone));
  Color get tertiary => tertiaryTone(_isLight ? 40 : 80);
  Color get onTertiary => tertiaryTone(_isLight ? 100 : 20);
  Color get tertiaryContainer => tertiaryTone(_isLight ? 90 : 30);
  Color get onTertiaryContainer => tertiaryTone(_isLight ? 10 : 90);

  Color errorTone(int tone) => Color(palette.error.get(tone));
  Color get error => errorTone(_isLight ? 40 : 80);
  Color get onError => errorTone(_isLight ? 100 : 20);
  Color get errorContainer => errorTone(_isLight ? 90 : 30);
  Color get onErrorContainer => errorTone(_isLight ? 10 : 90);

  Color neutralTone(int tone) => Color(palette.neutral.get(tone));
  Color get background => neutralTone(_isLight ? 10 : 90);
  Color get onBackground => neutralTone(_isLight ? 10 : 90);
  Color get surface => neutralTone(_isLight ? 99 : 10);
  Color get onSurface => neutralTone(_isLight ? 10 : 90);

  Color neutralVariantTone(int tone) => Color(palette.neutralVariant.get(tone));
  Color get surfaceVariant => neutralVariantTone(_isLight ? 90 : 30);
  Color get onSurfaceVaraiant => neutralVariantTone(_isLight ? 30 : 80);
  Color get outline => neutralVariantTone(_isLight ? 50 : 60);
}
