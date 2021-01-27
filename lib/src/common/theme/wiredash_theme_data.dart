import 'dart:ui' show Brightness;

import 'package:flutter/rendering.dart';

class WiredashThemeData {
  factory WiredashThemeData({
    Brightness brightness = Brightness.light,
    Color? primaryColor,
    Color? secondaryColor,
    Color? primaryTextColor,
    Color? secondaryTextColor,
    Color? tertiaryTextColor,
    Color? primaryBackgroundColor,
    Color? secondaryBackgroundColor,
    Color? backgroundColor,
    Color? dividerColor,
    Color? errorColor,
    Color? firstPenColor,
    Color? secondPenColor,
    Color? thirdPenColor,
    Color? fourthPenColor,
    BorderRadius? sheetBorderRadius,
    String? fontFamily,
  }) {
    if (brightness == Brightness.light) {
      return WiredashThemeData._(
        brightness: brightness,
        primaryColor: primaryColor ?? const Color(0xff03A4E5),
        secondaryColor: secondaryColor ?? const Color(0xff35F1D7),
        primaryTextColor: primaryTextColor ?? const Color(0xff2b2b2b),
        secondaryTextColor: secondaryTextColor ?? const Color(0xff88888a),
        tertiaryTextColor: tertiaryTextColor ?? const Color(0xff586a84),
        primaryBackgroundColor:
            primaryBackgroundColor ?? const Color(0xffffffff),
        secondaryBackgroundColor:
            secondaryBackgroundColor ?? const Color(0xfff5f6f8),
        backgroundColor: backgroundColor ?? const Color(0xff9ba9bc),
        dividerColor: dividerColor ?? const Color(0xffccd2d9),
        errorColor: errorColor ?? const Color(0xffd41121),
        firstPenColor: firstPenColor ?? const Color(0xff483e39),
        secondPenColor: secondPenColor ?? const Color(0xffdbd4d1),
        thirdPenColor: thirdPenColor ?? const Color(0xff14e9d0),
        fourthPenColor: fourthPenColor ?? const Color(0xffe96115),
        sheetBorderRadius: sheetBorderRadius ??
            const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
        fontFamily: fontFamily ?? _fontFamily,
      );
    } else {
      return WiredashThemeData._(
        brightness: brightness,
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
        errorColor: errorColor ?? const Color(0xffff5c6a),
        firstPenColor: firstPenColor ?? const Color(0xff483e39),
        secondPenColor: secondPenColor ?? const Color(0xffdbd4d1),
        thirdPenColor: thirdPenColor ?? const Color(0xff14e9d0),
        fourthPenColor: fourthPenColor ?? const Color(0xffe96115),
        sheetBorderRadius: sheetBorderRadius ??
            const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
        fontFamily: fontFamily ?? _fontFamily,
      );
    }
  }

  WiredashThemeData._({
    required this.brightness,
    required this.primaryColor,
    required this.secondaryColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.tertiaryTextColor,
    required this.primaryBackgroundColor,
    required this.secondaryBackgroundColor,
    required this.backgroundColor,
    required this.dividerColor,
    required this.errorColor,
    required this.firstPenColor,
    required this.secondPenColor,
    required this.thirdPenColor,
    required this.fourthPenColor,
    required this.sheetBorderRadius,
    required this.fontFamily,
  });

  final Brightness brightness;

  final Color primaryColor;
  final Color secondaryColor;

  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color tertiaryTextColor;

  final Color primaryBackgroundColor;
  final Color secondaryBackgroundColor;
  final Color backgroundColor;

  final Color dividerColor;
  final Color errorColor;

  final Color firstPenColor;
  final Color secondPenColor;
  final Color thirdPenColor;
  final Color fourthPenColor;

  final String fontFamily;

  final BorderRadius sheetBorderRadius;

  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  static const _fontFamily = 'LexendDeca';
  static const _packageName = 'wiredash';

  String? get packageName => fontFamily == _fontFamily ? _packageName : null;

  TextStyle get titleStyle => TextStyle(
      package: packageName,
      fontFamily: fontFamily,
      fontSize: 24,
      color: white,
      fontWeight: FontWeight.bold);

  TextStyle get subtitleStyle => TextStyle(
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

  TextStyle get spotlightTitleStyle => TextStyle(
      package: packageName,
      fontFamily: fontFamily,
      fontSize: 18,
      letterSpacing: 1.4,
      color: white,
      fontWeight: FontWeight.bold);

  TextStyle get spotlightTextStyle => TextStyle(
      package: packageName, fontFamily: fontFamily, fontSize: 15, color: white);
}
