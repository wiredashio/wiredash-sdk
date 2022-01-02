import 'dart:ui' show Brightness;

import 'package:flutter/rendering.dart';

class WiredashThemeData {
  factory WiredashThemeData({
    Brightness brightness = Brightness.light,
    DeviceClass deviceClass = DeviceClass.handsetLarge400,
    Color? primaryColor,
    Color? secondaryColor,
    Color? primaryTextColor,
    Color? secondaryTextColor,
    Color? primaryBackgroundColor,
    Color? secondaryBackgroundColor,
    Color? appBackgroundColor,
    Color? errorColor,
    String? fontFamily,
    Size? windowSize,
  }) {
    if (brightness == Brightness.light) {
      return WiredashThemeData._(
        brightness: brightness,
        deviceClass: deviceClass,
        primaryColor: primaryColor ?? const Color(0xff1A56DB),
        secondaryColor: secondaryColor ?? const Color(0xffE8EEFB),
        primaryTextColor: primaryTextColor ?? const Color(0xff030A1C),
        secondaryTextColor: secondaryTextColor ?? const Color(0xff8C93A2),
        primaryBackgroundColor:
            primaryBackgroundColor ?? const Color(0xffffffff),
        secondaryBackgroundColor:
            secondaryBackgroundColor ?? const Color(0xfff5f6f8),
        appBackgroundColor: appBackgroundColor ?? const Color(0xfff5f6f8),
        errorColor: errorColor ?? const Color(0xffff5c6a),
        fontFamily: fontFamily ?? _fontFamily,
        windowSize: windowSize ?? Size.zero,
      );
    } else {
      return WiredashThemeData._(
        brightness: brightness,
        deviceClass: deviceClass,
        primaryColor: primaryColor ?? const Color(0xff1A56DB),
        secondaryColor: secondaryColor ?? const Color(0xffE8EEFB),
        primaryTextColor: primaryTextColor ?? const Color(0xffe3e3e3),
        secondaryTextColor: secondaryTextColor ?? const Color(0xb0a4a4a4),
        primaryBackgroundColor:
            primaryBackgroundColor ?? const Color(0xffffffff),
        secondaryBackgroundColor:
            secondaryBackgroundColor ?? const Color(0xfff5f6f8),
        appBackgroundColor: appBackgroundColor ?? const Color(0xfff5f6f8),
        errorColor: errorColor ?? const Color(0xffff5c6a),
        fontFamily: fontFamily ?? _fontFamily,
        windowSize: windowSize ?? Size.zero,
      );
    }
  }

  factory WiredashThemeData.fromColor({
    required Color color,
    required Brightness brightness,
  }) {
    final hsl = HSLColor.fromColor(color);

    final theme =
        WiredashThemeData(brightness: brightness, primaryColor: color);

    if (brightness == Brightness.light) {
      return theme.copyWith(
        secondaryColor: hsl
            .withHue((hsl.hue - 10) % 360)
            .withSaturation(.60)
            .withLightness(.90)
            .toColor(),
        primaryBackgroundColor:
            hsl.withSaturation(1.0).withLightness(1.0).toColor(),
        secondaryBackgroundColor:
            hsl.withSaturation(.8).withLightness(0.95).toColor(),
      );
    } else {
      return theme.copyWith(
        secondaryColor: hsl
            .withHue((hsl.hue - 10) % 360)
            .withSaturation(.1)
            .withLightness(.1)
            .toColor(),
        primaryBackgroundColor:
            hsl.withSaturation(0.04).withLightness(0.2).toColor(),
        secondaryBackgroundColor:
            hsl.withSaturation(0.0).withLightness(0.1).toColor(),
      );
    }
  }

  WiredashThemeData._({
    required this.brightness,
    required this.primaryColor,
    required this.secondaryColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.primaryBackgroundColor,
    required this.secondaryBackgroundColor,
    required this.appBackgroundColor,
    required this.errorColor,
    required this.deviceClass,
    required this.fontFamily,
    required this.windowSize,
  });

  final Brightness brightness;

  final Color primaryColor;
  final Color secondaryColor;

  final Color primaryTextColor;
  final Color secondaryTextColor;

  final Color primaryBackgroundColor;
  final Color secondaryBackgroundColor;
  final Color errorColor;

  final Color appBackgroundColor;

  final DeviceClass deviceClass;
  final Size windowSize;

  final String fontFamily;

  static const _fontFamily = 'Inter';
  static const _packageName = 'wiredash';

  String? get packageName => fontFamily == _fontFamily ? _packageName : null;

  TextStyle get headlineTextStyle => TextStyle(
        package: packageName,
        fontFamily: fontFamily,
        fontSize: 28,
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
        fontWeight: FontWeight.bold,
      );

  TextStyle get bodyTextStyle => TextStyle(
        package: packageName,
        fontFamily: fontFamily,
        fontSize: 16,
        color: primaryTextColor,
        fontWeight: FontWeight.normal,
      );

  TextStyle get body2TextStyle => TextStyle(
        package: packageName,
        fontFamily: fontFamily,
        fontSize: 16,
        color: secondaryTextColor,
        fontWeight: FontWeight.normal,
      );

  TextStyle get captionTextStyle => TextStyle(
        package: packageName,
        fontFamily: fontFamily,
        fontSize: 10,
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
    switch (deviceClass) {
      case DeviceClass.handsetSmall320:
        return 8;
      case DeviceClass.handsetMedium360:
        return 16;
      case DeviceClass.handsetLarge400:
        return 32;
      case DeviceClass.tabletSmall600:
        return 64;
      case DeviceClass.tabletLarge720:
        return 64;
      case DeviceClass.desktopSmall1024:
        return 128;
      case DeviceClass.desktopLarge1440:
        return 128;
    }
  }

  double get buttonBarHeight {
    if (windowSize.shortestSide <= 600) {
      return 64;
    }
    return 96;
  }

  double get verticalPadding {
    switch (deviceClass) {
      case DeviceClass.handsetSmall320:
      case DeviceClass.handsetMedium360:
      case DeviceClass.handsetLarge400:
      case DeviceClass.tabletSmall600:
      case DeviceClass.tabletLarge720:
        return 40;
      case DeviceClass.desktopSmall1024:
      case DeviceClass.desktopLarge1440:
        return 64;
    }
  }

  double get maxContentWidth {
    switch (deviceClass) {
      case DeviceClass.handsetSmall320:
      case DeviceClass.handsetMedium360:
      case DeviceClass.handsetLarge400:
      case DeviceClass.tabletSmall600:
        return double.infinity;
      case DeviceClass.tabletLarge720:
        return 640;
      case DeviceClass.desktopSmall1024:
        return 720;
      case DeviceClass.desktopLarge1440:
        return 800;
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
          primaryTextColor == other.primaryTextColor &&
          secondaryTextColor == other.secondaryTextColor &&
          primaryBackgroundColor == other.primaryBackgroundColor &&
          secondaryBackgroundColor == other.secondaryBackgroundColor &&
          appBackgroundColor == other.appBackgroundColor &&
          errorColor == other.errorColor &&
          deviceClass == other.deviceClass &&
          windowSize == other.windowSize &&
          fontFamily == other.fontFamily;

  @override
  int get hashCode =>
      brightness.hashCode ^
      primaryColor.hashCode ^
      secondaryColor.hashCode ^
      primaryTextColor.hashCode ^
      secondaryTextColor.hashCode ^
      primaryBackgroundColor.hashCode ^
      secondaryBackgroundColor.hashCode ^
      appBackgroundColor.hashCode ^
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
        'primaryTextColor: $primaryTextColor, '
        'secondaryTextColor: $secondaryTextColor, '
        'primaryBackgroundColor: $primaryBackgroundColor, '
        'secondaryBackgroundColor: $secondaryBackgroundColor, '
        'appBackgroundColor: $appBackgroundColor, '
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
    Color? primaryTextColor,
    Color? secondaryTextColor,
    Color? primaryBackgroundColor,
    Color? secondaryBackgroundColor,
    Color? appBackgroundColor,
    Color? errorColor,
    DeviceClass? deviceClass,
    String? fontFamily,
    Size? windowSize,
  }) {
    return WiredashThemeData(
      brightness: brightness ?? this.brightness,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      primaryTextColor: primaryTextColor ?? this.primaryTextColor,
      secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
      primaryBackgroundColor:
          primaryBackgroundColor ?? this.primaryBackgroundColor,
      secondaryBackgroundColor:
          secondaryBackgroundColor ?? this.secondaryBackgroundColor,
      appBackgroundColor: appBackgroundColor ?? this.appBackgroundColor,
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
