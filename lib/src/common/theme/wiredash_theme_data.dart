import 'dart:ui' show Brightness;

import 'package:flutter/rendering.dart';

class WiredashThemeData {
  factory WiredashThemeData({
    Brightness brightness = Brightness.light,
    Color? primaryColor,
    Color? secondaryColor,
    Color? primaryTextColor,
    Color? secondaryTextColor,
    Color? primaryBackgroundColor,
    Color? secondaryBackgroundColor,
    Color? errorColor,
    String? fontFamily,
  }) {
    if (brightness == Brightness.light) {
      return WiredashThemeData._(
        brightness: brightness,
        primaryColor: primaryColor ?? const Color(0xff1A56DB),
        secondaryColor: secondaryColor ?? const Color(0xffE8EEFB),
        primaryTextColor: primaryTextColor ?? const Color(0xff030A1C),
        secondaryTextColor: secondaryTextColor ?? const Color(0xff8C93A2),
        primaryBackgroundColor:
            primaryBackgroundColor ?? const Color(0xffffffff),
        secondaryBackgroundColor:
            secondaryBackgroundColor ?? const Color(0xfff5f6f8),
        errorColor: errorColor ?? const Color(0xffd41121),
        fontFamily: fontFamily ?? _fontFamily,
      );
    } else {
      return WiredashThemeData._(
        brightness: brightness,
        primaryColor: primaryColor ?? const Color(0xff03A4E5),
        secondaryColor: secondaryColor ?? const Color(0xff35F1D7),
        primaryTextColor: primaryTextColor ?? const Color(0xfffafafa),
        secondaryTextColor: secondaryTextColor ?? const Color(0xff9ba9bc),
        primaryBackgroundColor:
            primaryBackgroundColor ?? const Color(0xff3c4042),
        secondaryBackgroundColor:
            secondaryBackgroundColor ?? const Color(0xff2b2b2b),
        errorColor: errorColor ?? const Color(0xffff5c6a),
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
    required this.primaryBackgroundColor,
    required this.secondaryBackgroundColor,
    required this.errorColor,
    required this.fontFamily,
  });

  final Brightness brightness;

  final Color primaryColor;
  final Color secondaryColor;

  final Color primaryTextColor;
  final Color secondaryTextColor;

  final Color primaryBackgroundColor;
  final Color secondaryBackgroundColor;
  final Color errorColor;

  final String fontFamily;

  static const _fontFamily = 'Inter';
  static const _packageName = 'wiredash';

  String? get packageName => fontFamily == _fontFamily ? _packageName : null;

  TextStyle get headlineStyle => TextStyle(
        package: packageName,
        fontFamily: fontFamily,
        fontSize: 28,
        color: primaryTextColor,
        fontWeight: FontWeight.bold,
      );

  TextStyle get titleStyle => TextStyle(
        package: packageName,
        fontFamily: fontFamily,
        fontSize: 20,
        color: primaryTextColor,
        fontWeight: FontWeight.bold,
      );

  TextStyle get bodyStyle => TextStyle(
        package: packageName,
        fontFamily: fontFamily,
        fontSize: 16,
        color: primaryTextColor,
        fontWeight: FontWeight.normal,
      );

  TextStyle get captionStyle => TextStyle(
        package: packageName,
        fontFamily: fontFamily,
        fontSize: 10,
        color: secondaryTextColor,
        fontWeight: FontWeight.normal,
      );

  TextStyle get inputStyle => TextStyle(
        package: packageName,
        fontFamily: fontFamily,
        fontSize: 14,
        color: primaryTextColor,
      );

  TextStyle get inputErrorStyle => TextStyle(
        package: packageName,
        fontFamily: fontFamily,
        fontSize: 12,
        color: errorColor,
      );
}
