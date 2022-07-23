import 'package:flutter/material.dart';
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
    Color? firstPenColor,
    Color? secondPenColor,
    Color? thirdPenColor,
    Color? fourthPenColor,
    String? fontFamily,
    Size? windowSize,
    WiredashTextTheme? textTheme,
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
      firstPenColor: firstPenColor,
      secondPenColor: secondPenColor,
      thirdPenColor: thirdPenColor,
      fourthPenColor: fourthPenColor,
      fontFamily: fontFamily,
      textTheme: textTheme,
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
    Color? firstPenColor,
    Color? secondPenColor,
    Color? thirdPenColor,
    Color? fourthPenColor,
    String? fontFamily,
    WiredashTextTheme? textTheme,
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
        _firstPenColor = firstPenColor,
        _secondPenColor = secondPenColor,
        _thirdPenColor = thirdPenColor,
        _fourthPenColor = fourthPenColor,
        _textTheme = textTheme,
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

  // --- secondaryContainer --- //
  final Color? _secondaryContainerColor;

  Color get secondaryContainerColor =>
      _secondaryContainerColor ?? _secondaryTone.primaryContainer;

  final Color? _textOnSecondaryContainerColor;

  Color get textOnSecondaryContainerColor {
    return _textOnSecondaryContainerColor ?? _secondaryTone.onPrimaryContainer;
  }

  // --- Text Theme --- //

  final WiredashTextTheme? _textTheme;

  WiredashTextThemeWithDefaults get textTheme {
    final merged = _defaultWiredashTextTheme.merge(_textTheme);
    return WiredashTextThemeWithDefaults(this, merged);
  }

  SurfaceBasedTextStyle get text {
    return SurfaceBasedTextStyle(this);
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

  final Color? _firstPenColor;

  Color get firstPenColor => _firstPenColor ?? const Color(0xffff0c67);

  final Color? _secondPenColor;

  Color get secondPenColor => _secondPenColor ?? const Color(0xff00081e);

  final Color? _thirdPenColor;

  Color get thirdPenColor => _thirdPenColor ?? const Color(0xff9cdcdc);

  final Color? _fourthPenColor;

  Color get fourthPenColor => _fourthPenColor ?? const Color(0xffe96115);

  // --- Error --- //
  final Color? _errorColor;

  Color get errorColor => _errorColor ?? _primaryTone.error;

  final DeviceClass deviceClass;
  final Size windowSize;

  final String? _fontFamily;

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
          firstPenColor == other.firstPenColor &&
          secondPenColor == other.secondPenColor &&
          thirdPenColor == other.thirdPenColor &&
          fourthPenColor == other.fourthPenColor &&
          deviceClass == other.deviceClass &&
          windowSize == other.windowSize &&
          _fontFamily == other._fontFamily;

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
      firstPenColor.hashCode ^
      secondPenColor.hashCode ^
      thirdPenColor.hashCode ^
      fourthPenColor.hashCode ^
      deviceClass.hashCode ^
      windowSize.hashCode ^
      _fontFamily.hashCode;

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
        'firstPenColor: $firstPenColor'
        'secondPenColor: $secondPenColor'
        'thirdPenColor: $thirdPenColor'
        'fourthPenColor: $fourthPenColor'
        'deviceClass: $deviceClass, '
        'fontFamily: $_fontFamily, '
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
    Color? firstPenColor,
    Color? secondPenColor,
    Color? thirdPenColor,
    Color? fourthPenColor,
    DeviceClass? deviceClass,
    String? fontFamily,
    WiredashTextTheme? textTheme,
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
      firstPenColor: firstPenColor ?? this.firstPenColor,
      secondPenColor: secondPenColor ?? this.secondPenColor,
      thirdPenColor: thirdPenColor ?? this.thirdPenColor,
      fourthPenColor: fourthPenColor ?? this.fourthPenColor,
      deviceClass: deviceClass ?? this.deviceClass,
      fontFamily: fontFamily ?? _fontFamily,
      textTheme: textTheme ?? this.textTheme,
      windowSize: windowSize ?? this.windowSize,
    );
  }
}

/// Definition of all text styles used in the app
///
/// This textTheme is responsible for size, weight, spacing and font family. Explicitly **NOT** color
class WiredashTextTheme {
  const WiredashTextTheme({
    this.headlineMediumTextStyle,
    this.headlineSmallTextStyle,
    this.appbarTitle,
    this.titleTextStyle,
    this.tronButtonTextStyle,
    this.bodyMediumTextStyle,
    this.bodySmallTextStyle,
    this.body2MediumTextStyle,
    this.body2SmallTextStyle,
    this.captionTextStyle,
    this.inputTextStyle,
    this.inputErrorTextStyle,
  });

  final TextStyle? headlineMediumTextStyle;
  final TextStyle? headlineSmallTextStyle;
  final TextStyle? appbarTitle;
  final TextStyle? titleTextStyle;
  final TextStyle? tronButtonTextStyle;
  final TextStyle? bodyMediumTextStyle;
  final TextStyle? bodySmallTextStyle;
  final TextStyle? body2MediumTextStyle;
  final TextStyle? body2SmallTextStyle;
  final TextStyle? captionTextStyle;
  final TextStyle? inputTextStyle;
  final TextStyle? inputErrorTextStyle;

  WiredashTextTheme copyWith({
    TextStyle? headlineMediumTextStyle,
    TextStyle? headlineSmallTextStyle,
    TextStyle? appbarTitle,
    TextStyle? titleTextStyle,
    TextStyle? tronButtonTextStyle,
    TextStyle? bodyMediumTextStyle,
    TextStyle? bodySmallTextStyle,
    TextStyle? body2MediumTextStyle,
    TextStyle? body2SmallTextStyle,
    TextStyle? captionTextStyle,
    TextStyle? inputTextStyle,
    TextStyle? inputErrorTextStyle,
  }) {
    return WiredashTextTheme(
      headlineMediumTextStyle:
          headlineMediumTextStyle ?? this.headlineMediumTextStyle,
      headlineSmallTextStyle:
          headlineSmallTextStyle ?? this.headlineSmallTextStyle,
      appbarTitle: appbarTitle ?? this.appbarTitle,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      tronButtonTextStyle: tronButtonTextStyle ?? this.tronButtonTextStyle,
      bodyMediumTextStyle: bodyMediumTextStyle ?? this.bodyMediumTextStyle,
      bodySmallTextStyle: bodySmallTextStyle ?? this.bodySmallTextStyle,
      body2MediumTextStyle: body2MediumTextStyle ?? this.body2MediumTextStyle,
      body2SmallTextStyle: body2SmallTextStyle ?? this.body2SmallTextStyle,
      captionTextStyle: captionTextStyle ?? this.captionTextStyle,
      inputTextStyle: inputTextStyle ?? this.inputTextStyle,
      inputErrorTextStyle: inputErrorTextStyle ?? this.inputErrorTextStyle,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WiredashTextTheme &&
          runtimeType == other.runtimeType &&
          headlineMediumTextStyle == other.headlineMediumTextStyle &&
          headlineSmallTextStyle == other.headlineSmallTextStyle &&
          appbarTitle == other.appbarTitle &&
          titleTextStyle == other.titleTextStyle &&
          tronButtonTextStyle == other.tronButtonTextStyle &&
          bodyMediumTextStyle == other.bodyMediumTextStyle &&
          bodySmallTextStyle == other.bodySmallTextStyle &&
          body2MediumTextStyle == other.body2MediumTextStyle &&
          body2SmallTextStyle == other.body2SmallTextStyle &&
          captionTextStyle == other.captionTextStyle &&
          inputTextStyle == other.inputTextStyle &&
          inputErrorTextStyle == other.inputErrorTextStyle;

  @override
  int get hashCode {
    return headlineMediumTextStyle.hashCode ^
        headlineSmallTextStyle.hashCode ^
        appbarTitle.hashCode ^
        titleTextStyle.hashCode ^
        tronButtonTextStyle.hashCode ^
        bodyMediumTextStyle.hashCode ^
        bodySmallTextStyle.hashCode ^
        body2MediumTextStyle.hashCode ^
        body2SmallTextStyle.hashCode ^
        captionTextStyle.hashCode ^
        inputTextStyle.hashCode ^
        inputErrorTextStyle.hashCode;
  }

  WiredashTextTheme merge(WiredashTextTheme? other) {
    if (other == null) {
      return this;
    }

    TextStyle? mergeTextStyles(TextStyle? base, TextStyle? addition) {
      final baseFontFamily = base?.fontFamily;
      final additionFontFamily = addition?.fontFamily;

      final result = base?.merge(addition);

      // Removing package if addition changes the fontFamily
      // Bugfix for https://github.com/flutter/flutter/issues/108230
      final basePackage = baseFontFamily?.startsWith('packages/') == true
          ? baseFontFamily?.split('/').first
          : null;
      final additionPackage =
          additionFontFamily?.startsWith('packages/') == true
              ? baseFontFamily?.split('/').first
              : null;

      return TextStyle(
        color: result?.color,
        backgroundColor: result?.backgroundColor,
        fontSize: result?.fontSize,
        fontWeight: result?.fontWeight,
        fontStyle: result?.fontStyle,
        letterSpacing: result?.letterSpacing,
        wordSpacing: result?.wordSpacing,
        textBaseline: result?.textBaseline,
        height: result?.height,
        leadingDistribution: result?.leadingDistribution,
        locale: result?.locale,
        foreground: result?.foreground,
        background: result?.background,
        shadows: result?.shadows,
        fontFeatures: result?.fontFeatures,
        decoration: result?.decoration,
        decorationColor: result?.decorationColor,
        decorationStyle: result?.decorationStyle,
        decorationThickness: result?.decorationThickness,
        debugLabel: result?.debugLabel,
        fontFamilyFallback: result?.fontFamilyFallback,

        // Here starts the custom part of the TextStyle copyWith method
        fontFamily: additionFontFamily ?? baseFontFamily,
        package: () {
          if (additionFontFamily != null || additionPackage != null) {
            // Set addition.package when addition defines a fontFamily
            return additionPackage;
          }
          return basePackage;
        }(),
      );
    }

    return copyWith(
      headlineMediumTextStyle: mergeTextStyles(
          headlineMediumTextStyle, other.headlineMediumTextStyle),
      headlineSmallTextStyle:
          mergeTextStyles(headlineSmallTextStyle, other.headlineSmallTextStyle),
      appbarTitle: mergeTextStyles(appbarTitle, other.appbarTitle),
      titleTextStyle: mergeTextStyles(titleTextStyle, other.titleTextStyle),
      tronButtonTextStyle:
          mergeTextStyles(tronButtonTextStyle, other.tronButtonTextStyle),
      bodyMediumTextStyle:
          mergeTextStyles(bodyMediumTextStyle, other.bodyMediumTextStyle),
      bodySmallTextStyle:
          mergeTextStyles(bodySmallTextStyle, other.bodySmallTextStyle),
      body2MediumTextStyle:
          mergeTextStyles(body2MediumTextStyle, other.body2MediumTextStyle),
      body2SmallTextStyle:
          mergeTextStyles(body2SmallTextStyle, other.body2SmallTextStyle),
      captionTextStyle:
          mergeTextStyles(captionTextStyle, other.captionTextStyle),
      inputTextStyle: mergeTextStyles(inputTextStyle, other.inputTextStyle),
      inputErrorTextStyle:
          mergeTextStyles(inputErrorTextStyle, other.inputErrorTextStyle),
    );
  }

  WiredashTextTheme apply({Color? color}) {
    return copyWith(
      headlineMediumTextStyle: headlineMediumTextStyle?.apply(color: color),
      headlineSmallTextStyle: headlineSmallTextStyle?.apply(color: color),
      appbarTitle: appbarTitle?.apply(color: color),
      titleTextStyle: titleTextStyle?.apply(color: color),
      tronButtonTextStyle: tronButtonTextStyle?.apply(color: color),
      bodyMediumTextStyle: bodyMediumTextStyle?.apply(color: color),
      bodySmallTextStyle: bodySmallTextStyle?.apply(color: color),
      body2MediumTextStyle: body2MediumTextStyle?.apply(color: color),
      body2SmallTextStyle: body2SmallTextStyle?.apply(color: color),
      captionTextStyle: captionTextStyle?.apply(color: color),
      inputTextStyle: inputTextStyle?.apply(color: color),
      inputErrorTextStyle: inputErrorTextStyle?.apply(color: color),
    );
  }
}

/// Convenience class for accessing the text styles when we know everything is provided
class WiredashTextThemeWithDefaults extends WiredashTextTheme {
  final WiredashThemeData theme;

  final WiredashTextTheme textTheme;

  WiredashTextThemeWithDefaults(this.theme, this.textTheme);

  @override
  TextStyle get headlineMediumTextStyle => textTheme.headlineMediumTextStyle!;

  @override
  TextStyle get headlineSmallTextStyle => textTheme.headlineSmallTextStyle!;

  @override
  TextStyle get appbarTitle => textTheme.appbarTitle!;

  @override
  TextStyle get titleTextStyle => textTheme.titleTextStyle!;

  @override
  TextStyle get tronButtonTextStyle => textTheme.tronButtonTextStyle!;

  @override
  TextStyle get bodyMediumTextStyle => textTheme.bodyMediumTextStyle!;

  @override
  TextStyle get bodySmallTextStyle => textTheme.bodySmallTextStyle!;

  @override
  TextStyle get body2MediumTextStyle => textTheme.body2MediumTextStyle!;

  @override
  TextStyle get body2SmallTextStyle => textTheme.body2SmallTextStyle!;

  @override
  TextStyle get captionTextStyle => textTheme.captionTextStyle!;

  @override
  TextStyle get inputTextStyle => textTheme.inputTextStyle!;

  @override
  TextStyle get inputErrorTextStyle => textTheme.inputErrorTextStyle!;

  TextStyle get adaptiveBodyTextStyle {
    if (theme.windowSize.shortestSide > 480) {
      return bodyMediumTextStyle;
    } else {
      return bodySmallTextStyle;
    }
  }

  TextStyle get adaptiveBody2TextStyle {
    if (theme.windowSize.shortestSide > 480) {
      return body2MediumTextStyle;
    } else {
      return body2SmallTextStyle;
    }
  }

  TextStyle get adaptiveHeadlineTextStyle {
    if (theme.windowSize.shortestSide > 480) {
      return headlineMediumTextStyle;
    } else {
      return headlineSmallTextStyle;
    }
  }

  @override
  WiredashTextThemeWithDefaults apply({Color? color}) {
    final copy = super.apply(color: color);
    return WiredashTextThemeWithDefaults(theme, copy);
  }
}

class SurfaceSelector {
  final WiredashThemeData theme;
  final TextStyle textStyle;
  final Color Function(Color)? colorMutation;

  SurfaceSelector(this.theme, this.textStyle, {this.colorMutation});

  Color _mutateColor(Color color) {
    if (colorMutation != null) {
      return colorMutation!(color);
    }
    return color;
  }

  TextStyle get onBackground {
    return textStyle.copyWith(
      color: _mutateColor(theme.primaryTextOnBackgroundColor),
    );
  }

  TextStyle get onSurface {
    return textStyle.copyWith(
      color: _mutateColor(theme.primaryTextOnSurfaceColor),
    );
  }

  TextStyle get onPrimary {
    return textStyle.copyWith(
      color: _mutateColor(theme.textOnPrimaryColor),
    );
  }

  TextStyle get onSecondary {
    return textStyle.copyWith(
      color: _mutateColor(theme.textOnSecondaryColor),
    );
  }

  TextStyle get onPrimaryContainer {
    return textStyle.copyWith(
      color: _mutateColor(theme.textOnPrimaryContainerColor),
    );
  }

  TextStyle get onSecondaryContainer {
    return textStyle.copyWith(
      color: _mutateColor(theme.textOnSecondaryContainerColor),
    );
  }
}

class SurfaceBasedTextStyle {
  final WiredashThemeData theme;

  SurfaceBasedTextStyle(this.theme);

  late final SurfaceSelector headlineMedium =
      SurfaceSelector(theme, theme.textTheme.headlineMediumTextStyle);

  late final SurfaceSelector headlineSmall =
      SurfaceSelector(theme, theme.textTheme.headlineSmallTextStyle);

  late final SurfaceSelector appbarTitle =
      SurfaceSelector(theme, theme.textTheme.appbarTitle);

  late final SurfaceSelector title =
      SurfaceSelector(theme, theme.textTheme.titleTextStyle);

  late final SurfaceSelector tronButton =
      SurfaceSelector(theme, theme.textTheme.tronButtonTextStyle);

  late final SurfaceSelector bodyMedium =
      SurfaceSelector(theme, theme.textTheme.bodyMediumTextStyle);

  late final SurfaceSelector bodySmall =
      SurfaceSelector(theme, theme.textTheme.bodySmallTextStyle);

  late final SurfaceSelector body2Medium = SurfaceSelector(
    theme,
    theme.textTheme.body2MediumTextStyle,
    colorMutation: (color) => color.withOpacity(0.6),
  );

  late final SurfaceSelector body2Small = SurfaceSelector(
    theme,
    theme.textTheme.body2SmallTextStyle,
    colorMutation: (color) => color.withOpacity(0.6),
  );

  late final SurfaceSelector caption =
      SurfaceSelector(theme, theme.textTheme.captionTextStyle);

  late final SurfaceSelector input =
      SurfaceSelector(theme, theme.textTheme.inputTextStyle);

  late final SurfaceSelector inputError =
      SurfaceSelector(theme, theme.textTheme.inputErrorTextStyle);

  SurfaceSelector get adaptiveBody {
    if (theme.windowSize.shortestSide > 480) {
      return bodyMedium;
    } else {
      return bodySmall;
    }
  }

  SurfaceSelector get adaptiveBody2 {
    if (theme.windowSize.shortestSide > 480) {
      return body2Medium;
    } else {
      return body2Small;
    }
  }

  SurfaceSelector get adaptiveHeadline {
    if (theme.windowSize.shortestSide > 480) {
      return headlineMedium;
    } else {
      return headlineSmall;
    }
  }
}

final _defaultWiredashTextTheme = WiredashTextTheme(
  headlineMediumTextStyle: const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: InvalidColor(),
  ).copyWithInter(),
  headlineSmallTextStyle: const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: InvalidColor(),
  ).copyWithInter(),
  appbarTitle: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: InvalidColor(),
  ).copyWithInter(),
  titleTextStyle: const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: InvalidColor(),
  ).copyWithInter(),
  tronButtonTextStyle: const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: InvalidColor(),
  ).copyWithInter(),
  bodyMediumTextStyle: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: InvalidColor(),
  ).copyWithInter(),
  bodySmallTextStyle: const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: InvalidColor(),
  ).copyWithInter(),
  body2MediumTextStyle: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: InvalidColor(),
  ).copyWithInter(),
  body2SmallTextStyle: const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: InvalidColor(),
  ).copyWithInter(),
  captionTextStyle: const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: InvalidColor(),
  ).copyWithInter(),
  inputTextStyle: const TextStyle(
    fontSize: 14,
    color: InvalidColor(),
  ).copyWithInter(),
  inputErrorTextStyle: const TextStyle(
    fontSize: 12,
    color: InvalidColor(),
  ).copyWithInter(),
);

extension on TextStyle {
  /// Applies the Inter font to the textTheme
  TextStyle copyWithInter() {
    return copyWith(
      package: 'wiredash',
      fontFamily: 'Inter',
    );
  }
}

/// A color that throws when it is used. The intention is that is will be
/// overridden and definitely not be used
class InvalidColor extends Color {
  const InvalidColor() : super(0);

  @override
  int get value => throw "No color defined, please set a valid Color";
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
