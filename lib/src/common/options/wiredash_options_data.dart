import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/wiredash.dart';

class WiredashOptionsData {
  WiredashOptionsData({
    bool showDebugFloatingEntryPoint,
    this.customTranslations,
  }) : showDebugFloatingEntryPoint = showDebugFloatingEntryPoint ?? kDebugMode;

  /// Show a floating button with the Wiredash logo to easily report issues
  /// while debugging the app
  final bool showDebugFloatingEntryPoint;

  /// Replace desired texts in Wiredash and localize it for you audience
  ///
  /// You can also use Wiredash delegate in your MaterialApp
  /// if default translations are sufficient for you
  final WiredashTranslations customTranslations;

  static Locale currentLocale = const Locale('en');

  void setCurrentLocale(String languageCode) {
    if (WiredashLocalizations.delegate.supportedLocales
        .map((e) => e.languageCode)
        .toList()
        .contains(languageCode)) {
      currentLocale = Locale.fromSubtags(languageCode: languageCode);
    } else {
      currentLocale = const Locale('en');
    }
  }
}
