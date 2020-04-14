import 'dart:ui' show Brightness;

import 'package:flutter/rendering.dart';

class WiredashThemeData {
  factory WiredashThemeData({
    Brightness brightness = Brightness.light,
    Color primaryColor,
    Color secondaryColor,
    Color primaryTextColor,
    Color secondaryTextColor,
    Color tertiaryTextColor,
    Color primaryBackgroundColor,
    Color secondaryBackgroundColor,
    Color backgroundColor,
    Color dividerColor,
  }) {
    if (Brightness.light == brightness) {
      return WiredashThemeData._(
        primaryColor: primaryColor ?? const Color(0xff03A4E5),
        secondaryColor: secondaryColor ?? const Color(0xff35F1D7),
        primaryTextColor: primaryTextColor ?? const Color(0xff2b2b2b),
        secondaryTextColor: secondaryTextColor ?? const Color(0xff88888a),
        tertiaryTextColor: tertiaryTextColor ?? const Color(0xff9ba9bc),
        primaryBackgroundColor:
            primaryBackgroundColor ?? const Color(0xffffffff),
        secondaryBackgroundColor:
            secondaryBackgroundColor ?? const Color(0xfff5f6f8),
        backgroundColor: backgroundColor ?? const Color(0xff9ba9bc),
        dividerColor: dividerColor ?? const Color(0xffccd2d9),
      );
    } else {
      return WiredashThemeData._(
        primaryColor: primaryColor ?? const Color(0xff03A4E5),
        secondaryColor: secondaryColor ?? const Color(0xff35F1D7),
        primaryTextColor: primaryTextColor ?? const Color(0xfffafafa),
        secondaryTextColor: secondaryTextColor ?? const Color(0xff9ba9bc),
        tertiaryTextColor: tertiaryTextColor ?? const Color(0xff9ba9bc),
        primaryBackgroundColor:
            primaryBackgroundColor ?? const Color(0xff3c4042),
        secondaryBackgroundColor:
            secondaryBackgroundColor ?? const Color(0xff2b2b2b),
        backgroundColor: backgroundColor ?? const Color(0xff202124),
        dividerColor: dividerColor ?? const Color(0xffccd2d9),
      );
    }
  }

  WiredashThemeData._({
    this.primaryColor,
    this.secondaryColor,
    this.primaryTextColor,
    this.secondaryTextColor,
    this.tertiaryTextColor,
    this.primaryBackgroundColor,
    this.secondaryBackgroundColor,
    this.backgroundColor,
    this.dividerColor,
  });

  final Color primaryColor;
  final Color secondaryColor;

  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color tertiaryTextColor;

  final Color primaryBackgroundColor;
  final Color secondaryBackgroundColor;
  final Color backgroundColor;

  final Color dividerColor;
  final Color errorColor = const Color(0xffe51326);

  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const penColors = [
    Color(0xff483e39),
    Color(0xffdbd4d1),
    Color(0xff14e9d0),
    Color(0xffe96115),
  ];

  static const fontFamily = 'LexendDeca';
  static const packageName = 'wiredash';

  TextStyle get titleStyle => const TextStyle(
      package: packageName,
      fontFamily: fontFamily,
      fontSize: 24,
      color: white,
      fontWeight: FontWeight.bold);

  TextStyle get subtitleStyle => const TextStyle(
      package: packageName, fontFamily: fontFamily, fontSize: 14, color: white);

  TextStyle get body1Style => TextStyle(
      package: packageName,
      fontFamily: fontFamily,
      fontSize: 12,
      color: primaryTextColor,
      fontWeight: FontWeight.bold);

  TextStyle get body2Style => TextStyle(
      package: packageName,
      fontFamily: fontFamily,
      fontSize: 12,
      color: secondaryTextColor);

  TextStyle get inputTextStyle => TextStyle(
      package: packageName,
      fontFamily: fontFamily,
      fontSize: 14,
      color: primaryTextColor);

  TextStyle get inputHintStyle => TextStyle(
      package: packageName,
      fontFamily: fontFamily,
      fontSize: 14,
      color: tertiaryTextColor);

  TextStyle get inputErrorStyle => TextStyle(
      package: packageName,
      fontFamily: fontFamily,
      fontSize: 12,
      color: errorColor);

  TextStyle get buttonStyle => TextStyle(
      package: packageName,
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: primaryColor);

  TextStyle get buttonCancel => TextStyle(
      package: packageName,
      fontFamily: fontFamily,
      fontSize: 14,
      color: tertiaryTextColor);

  TextStyle get spotlightTitleStyle => const TextStyle(
      package: packageName,
      fontFamily: fontFamily,
      fontSize: 18,
      letterSpacing: 1.4,
      color: white,
      fontWeight: FontWeight.bold);

  TextStyle get spotlightTextStyle => const TextStyle(
      package: packageName, fontFamily: fontFamily, fontSize: 15, color: white);
}
