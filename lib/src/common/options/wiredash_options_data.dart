import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:wiredash/wiredash.dart';

class WiredashOptionsData {
  WiredashOptionsData({
    Locale locale,
    TextDirection textDirection,
    this.bugReportButton = true,
    this.praiseButton = true,
    this.featureRequestButton = true,
    this.screenshotStep = true,
    this.buildColorPickerHeader,
    this.buildIntroFooter,
    this.customTranslations,
  })  : textDirection = textDirection ?? TextDirection.ltr,
        _currentLocale = locale ?? window.locale,
        assert(
          bugReportButton || praiseButton || featureRequestButton,
          'WiredashOptionsData Configuration Error: Show at least one button',
        );

  /// Replace desired texts in Wiredash and localize it for you audience
  ///
  /// You can also use Wiredash delegate in your MaterialApp
  /// if default translations are sufficient for you
  final Map<Locale, WiredashTranslations> customTranslations;

  /// Builds a Widget displayed at the top of the Color Picker drawer.
  ///
  /// The color picker header is a square Widget displayed at the top of the
  /// Color Picker Drawer during the "Draw" step. It is constrained to 40x40
  /// logical pixels in size.
  ///
  /// By default, builds a square Wiredash Image Widget.
  final WidgetBuilder buildColorPickerHeader;

  /// Builds a Widget displayed at the bottom of the Introduction Screen.
  ///
  /// The introduction screen is displayed when the user first enters the
  /// Wiredash feedback flow.
  ///
  /// By default, builds a Widget with the Wiredash logo.
  final WidgetBuilder buildIntroFooter;

  /// Whether to display the screenshot and drawing step or not.
  ///
  /// The Flutter Web beta does not currently support screenshots. Therefore,
  /// the screenshot and drawing step is never shown and this option is ignored.
  final bool screenshotStep;

  /// Whether to display the Bug Report button or not.
  final bool bugReportButton;

  /// Whether to display the Send Praise button or not.
  final bool praiseButton;

  /// Whether to display the Feature Request button or not.
  final bool featureRequestButton;

  /// Current [TextDirection] used by Wiredash widget
  TextDirection textDirection;

  Locale _currentLocale;

  /// Current locale used by Wiredash widget
  Locale get currentLocale => _currentLocale;

  /// Allows to set desired locale of Wiredash widget.
  ///
  /// The [locale] will be used if Wiredash built-in translations
  /// or [customTranslations] contain translations for this [locale].
  /// Otherwise device default locale will be used.
  ///
  /// If device default locale is not supported by Wiredash then English
  /// will be used instead.
  void setCurrentLocale(Locale locale) {
    if (WiredashLocalizations.isSupported(locale)) {
      _currentLocale = locale;
    } else {
      _currentLocale = window.locale;
    }
  }
}
