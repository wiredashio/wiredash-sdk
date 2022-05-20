import 'package:flutter/widgets.dart';
import 'package:wiredash/wiredash.dart';

class WiredashOptionsData {
  const WiredashOptionsData({
    this.locale,
    this.localizationDelegate,
  });

  /// The locale to be used for wiredash
  ///
  /// By default, wiredash will pick the locale of the phone or fallback to
  /// en-US. This locale always overrides it.
  ///
  /// When your app only support a limited number of locales, you might want to
  /// inject it here to match the locale and fallback for your app.
  ///
  /// For custom localtions and new locales see [localizationDelegate]
  final Locale? locale;

  /// This [LocalizationsDelegate] overrides wiredash's default. Your delegate
  /// can provide as many localizations as you want.
  ///
  /// Use this to provide your own texts that match the style of your app.
  ///
  /// When you provide a localization it fully replaces the one provided by
  /// wiredash. But all other languages are still provided by wiredash.
  ///
  /// If you add support for a complete new language, please consider
  /// contributing it to the project. Thanks in advance!
  ///
  /// See [https://github.com/wiredashio/wiredash-sdk/blob/stable/example/lib/custom_demo_translations.dart]
  /// for an example of how to use this.
  final LocalizationsDelegate<WiredashLocalizations>? localizationDelegate;
}
