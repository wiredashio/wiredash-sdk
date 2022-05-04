import 'dart:ui' show Brightness;

import 'package:flutter/rendering.dart';
import 'package:wiredash/src/core/theme/color_ext.dart';
import 'package:wiredash/src/core/theme/key_point_interpolator.dart';

class WiredashThemeData {
  factory WiredashThemeData({
    Brightness brightness = Brightness.light,
    DeviceClass deviceClass = DeviceClass.handsetLarge400,
    Color? primaryColor,
    Color? secondaryColor,
    Color? textOnPrimary,
    Color? textOnSecondary,
    Color? primaryTextColor,
    Color? secondaryTextColor,
    Color? primaryBackgroundColor,
    Color? secondaryBackgroundColor,
    Color? appBackgroundColor,
    Color? appHandleBackgroundColor,
    Color? errorColor,
    String? fontFamily,
    Size? windowSize,
  }) {
    final primary = primaryColor ?? const Color(0xff1A56DB);
    final secondary = secondaryColor ?? const Color(0xffE8EEFB);

    final textOnPrimaryColor = textOnPrimary ??
        (primary.brightness == Brightness.dark
            ? const Color(0xff030A1C)
            : const Color(0xffe3e3e3));
    final textOnSecondaryColor = textOnSecondary ??
        (secondary.brightness == Brightness.dark
            ? const Color(0xff8C93A2)
            : const Color(0xb0a4a4a4));

    if (brightness == Brightness.light) {
      return WiredashThemeData._(
        brightness: brightness,
        deviceClass: deviceClass,
        primaryColor: primary,
        secondaryColor: secondary,
        textOnPrimary: textOnPrimaryColor,
        textOnSecondary: textOnSecondaryColor,
        primaryTextColor: primaryTextColor ?? const Color(0xff030A1C),
        secondaryTextColor: secondaryTextColor ?? const Color(0xff8C93A2),
        primaryBackgroundColor:
            primaryBackgroundColor ?? const Color(0xffffffff),
        secondaryBackgroundColor:
            secondaryBackgroundColor ?? const Color(0xfff5f6f8),
        appBackgroundColor: appBackgroundColor ?? const Color(0xfff5f6f8),
        appHandleBackgroundColor:
            appHandleBackgroundColor ?? const Color(0xfff5f6f8),
        errorColor: errorColor ?? const Color(0xffff5c6a),
        fontFamily: fontFamily ?? _fontFamily,
        windowSize: windowSize ?? Size.zero,
      );
    } else {
      return WiredashThemeData._(
        brightness: brightness,
        deviceClass: deviceClass,
        primaryColor: primary,
        secondaryColor: secondary,
        textOnPrimary: textOnPrimaryColor,
        textOnSecondary: textOnSecondaryColor,
        primaryTextColor: primaryTextColor ?? const Color(0xffe3e3e3),
        secondaryTextColor: secondaryTextColor ?? const Color(0xb0a4a4a4),
        primaryBackgroundColor:
            primaryBackgroundColor ?? const Color(0xffffffff),
        secondaryBackgroundColor:
            secondaryBackgroundColor ?? const Color(0xfff5f6f8),
        appBackgroundColor: appBackgroundColor ?? const Color(0xff3d3e3e),
        appHandleBackgroundColor:
            appHandleBackgroundColor ?? const Color(0xff3d3e3e),
        errorColor: errorColor ?? const Color(0xffdb000a),
        fontFamily: fontFamily ?? _fontFamily,
        windowSize: windowSize ?? Size.zero,
      );
    }
  }

  factory WiredashThemeData.fromColor({
    required Color primaryColor,
    Color? secondaryColor,
    required Brightness brightness,
  }) {
    if (secondaryColor?.value == primaryColor.value) {
      secondaryColor = null;
    }
    final primaryHsl = HSLColor.fromColor(primaryColor);

    final theme =
        WiredashThemeData(brightness: brightness, primaryColor: primaryColor);

    if (brightness == Brightness.light) {
      final secondary = secondaryColor ??
          primaryHsl
              .withHue((primaryHsl.hue - 10) % 360)
              .withSaturation((primaryHsl.saturation * 0.3).clamp(0.1, 1.0))
              .withLightness((primaryHsl.lightness * 1.2).clamp(0.1, 1.0))
              .toColor();
      return theme.copyWith(
        secondaryColor: secondary,
        primaryBackgroundColor:
            primaryHsl.withSaturation(1.0).withLightness(1.0).toColor(),
        secondaryBackgroundColor:
            primaryHsl.withSaturation(.8).withLightness(0.95).toColor(),
        appHandleBackgroundColor: primaryHsl.withLightness(0.1).toColor(),
      );
    } else {
      final secondary = secondaryColor ??
          primaryHsl
              .withHue((primaryHsl.hue - 10) % 360)
              .withSaturation((primaryHsl.saturation * 0.2).clamp(0.1, 1.0))
              .withLightness((primaryHsl.lightness * 0.5).clamp(0.1, 1.0))
              .toColor();
      return theme.copyWith(
        secondaryColor: secondary,
        primaryBackgroundColor:
            primaryHsl.withSaturation(0.04).withLightness(0.2).toColor(),
        secondaryBackgroundColor:
            primaryHsl.withSaturation(0.0).withLightness(0.1).toColor(),
        appHandleBackgroundColor: primaryHsl.withLightness(0.3).toColor(),
      );
    }
  }

  WiredashThemeData._({
    required this.brightness,
    required this.primaryColor,
    required this.secondaryColor,
    required this.textOnPrimary,
    required this.textOnSecondary,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.primaryBackgroundColor,
    required this.secondaryBackgroundColor,
    required this.appBackgroundColor,
    required this.appHandleBackgroundColor,
    required this.errorColor,
    required this.deviceClass,
    required this.fontFamily,
    required this.windowSize,
  });

  final Brightness brightness;

  final Color primaryColor;
  final Color secondaryColor;

  final Color textOnPrimary;
  final Color textOnSecondary;

  final Color primaryTextColor;
  final Color secondaryTextColor;

  final Color primaryBackgroundColor;
  final Color secondaryBackgroundColor;
  final Color errorColor;

  final Color appBackgroundColor;

  /// The color of the app handle, the "Return to app" bar above the app
  final Color appHandleBackgroundColor;

  final DeviceClass deviceClass;
  final Size windowSize;

  final String fontFamily;

  static const _fontFamily = 'Inter';
  static const _packageName = 'wiredash';

  String? get packageName => fontFamily == _fontFamily ? _packageName : null;

  TextStyle get headlineTextStyle => TextStyle(
        package: packageName,
        fontFamily: fontFamily,
        fontSize: windowSize.shortestSide > 480 ? 32 : 24,
        color: primaryTextColor,
        fontWeight: FontWeight.bold,
      );

  TextStyle get appbarTitle => TextStyle(
        package: packageName,
        fontFamily: fontFamily,
        fontSize: 16,
        color: primaryTextColor,
        fontWeight: FontWeight.bold,
      );

  TextStyle get titleTextStyle => TextStyle(
        package: packageName,
        fontFamily: fontFamily,
        fontSize: 20,
        color: primaryTextColor,
        fontWeight: FontWeight.bold,
      );

  TextStyle get tronButtonTextStyle => TextStyle(
        package: packageName,
        fontFamily: fontFamily,
        fontSize: 14,
        color: primaryTextColor,
        fontWeight: FontWeight.w600,
      );

  TextStyle get bodyTextStyle => TextStyle(
        package: packageName,
        fontFamily: fontFamily,
        fontSize: windowSize.shortestSide > 480 ? 16 : 14,
        color: primaryTextColor,
        fontWeight: FontWeight.normal,
      );

  TextStyle get body2TextStyle => TextStyle(
        package: packageName,
        fontFamily: fontFamily,
        fontSize: windowSize.shortestSide > 480 ? 16 : 14,
        color: secondaryTextColor,
        fontWeight: FontWeight.normal,
      );

  TextStyle get captionTextStyle => TextStyle(
        package: packageName,
        fontFamily: fontFamily,
        fontSize: 12,
        color: secondaryTextColor,
        fontWeight: FontWeight.normal,
      );

  TextStyle get inputTextStyle => TextStyle(
        package: packageName,
        fontFamily: fontFamily,
        fontSize: 14,
        color: primaryTextColor,
      );

  TextStyle get inputErrorTextStyle => TextStyle(
        package: packageName,
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

  Color get primaryContainerColor {
    if (brightness == Brightness.dark) {
      return primaryColor.desaturate(0.4).darken(0.2);
    } else {
      return primaryColor.desaturate(0.4).lighten(0.3);
    }
  }

  Color get secondaryContainerColor {
    if (brightness == Brightness.dark) {
      return secondaryColor.desaturate(0.4).darken(0.2);
    } else {
      return secondaryColor.desaturate(0.4).darken(0.2);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WiredashThemeData &&
          runtimeType == other.runtimeType &&
          brightness == other.brightness &&
          primaryColor == other.primaryColor &&
          secondaryColor == other.secondaryColor &&
          textOnPrimary == other.textOnPrimary &&
          textOnSecondary == other.textOnSecondary &&
          primaryTextColor == other.primaryTextColor &&
          secondaryTextColor == other.secondaryTextColor &&
          primaryBackgroundColor == other.primaryBackgroundColor &&
          secondaryBackgroundColor == other.secondaryBackgroundColor &&
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
      textOnPrimary.hashCode ^
      textOnSecondary.hashCode ^
      primaryTextColor.hashCode ^
      secondaryTextColor.hashCode ^
      primaryBackgroundColor.hashCode ^
      secondaryBackgroundColor.hashCode ^
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
        'textOnPrimary: $textOnPrimary, '
        'textOnSecondary: $textOnSecondary, '
        'primaryTextColor: $primaryTextColor, '
        'secondaryTextColor: $secondaryTextColor, '
        'primaryBackgroundColor: $primaryBackgroundColor, '
        'secondaryBackgroundColor: $secondaryBackgroundColor, '
        'appBackgroundColor: $appBackgroundColor, '
        'appBackgroundColor: $appHandleBackgroundColor, '
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
    Color? textOnPrimary,
    Color? textOnSecondary,
    Color? primaryTextColor,
    Color? secondaryTextColor,
    Color? primaryBackgroundColor,
    Color? secondaryBackgroundColor,
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
      textOnPrimary: textOnPrimary ?? this.textOnPrimary,
      textOnSecondary: textOnSecondary ?? this.textOnSecondary,
      primaryTextColor: primaryTextColor ?? this.primaryTextColor,
      secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
      primaryBackgroundColor:
          primaryBackgroundColor ?? this.primaryBackgroundColor,
      secondaryBackgroundColor:
          secondaryBackgroundColor ?? this.secondaryBackgroundColor,
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
