import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:wiredash/wiredash.dart';

class WiredashOptionsData {
  WiredashOptionsData({
    Locale locale,
    TextDirection textDirection,
    this.customTranslations,
  })  : textDirection = textDirection ?? TextDirection.ltr,
        _currentLocale = locale ?? window.locale;

  /// Replace desired texts in Wiredash and localize it for you audience
  ///
  /// You can also use Wiredash delegate in your MaterialApp
  /// if default translations are sufficient for you
  final Map<Locale, WiredashTranslations> customTranslations;

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
