import 'dart:ui';

import 'package:wiredash/wiredash.dart';

class WiredashOptionsData {
  const WiredashOptionsData({
    Locale? locale,
    TextDirection? textDirection,
    this.bugReportButton = true,
    this.praiseButton = true,
    this.featureRequestButton = true,
    this.screenshotStep = true,
    this.customTranslations,
  })  : textDirection = textDirection ?? TextDirection.ltr,
        _currentLocale = locale,
        assert(
          bugReportButton || praiseButton || featureRequestButton,
          'WiredashOptionsData Configuration Error: Show at least one button',
        );

  /// Replace desired texts in Wiredash and localize it for you audience
  ///
  /// You can also use Wiredash delegate in your MaterialApp
  /// if default translations are sufficient for you
  final Map<Locale, WiredashTranslations>? customTranslations;

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
  final TextDirection textDirection;

  final Locale? _currentLocale;

  /// Current locale used by Wiredash widget
  Locale get currentLocale {
    final locale = _currentLocale;
    if (locale != null && WiredashLocalizations.isSupported(locale)) {
      return locale;
    }
    return _defaultLocale;
  }
}

Locale get _defaultLocale {
  // Flutter 1.26 (2.0.1) returns `Locale?`, 1.27 `Locale`
  // ignore: unnecessary_nullable_for_final_variable_declarations
  final Locale? locale = window.locale;
  return locale ?? const Locale('en', 'US');
}
