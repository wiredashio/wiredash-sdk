import 'package:flutter/material.dart';
import 'package:wiredash/src/common/options/wiredash_options.dart';
import 'package:wiredash/wiredash.dart';

import 'l10n/messages_de.dart' as de;
import 'l10n/messages_en.dart' as en;
import 'l10n/messages_es.dart' as es;
import 'l10n/messages_fr.dart' as fr;
import 'l10n/messages_nl.dart' as nl;
import 'l10n/messages_pl.dart' as pl;

class WiredashLocalizations extends StatelessWidget {
  const WiredashLocalizations({@required this.child, Key key})
      : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final options = WiredashOptions.of(context);
    return _InheritedWiredashTranslation(
      customTranslations: options.customTranslations,
      child: child,
    );
  }

  static WiredashTranslations of(BuildContext context) {
    final options = WiredashOptions.of(context);
    final _InheritedWiredashTranslation inheritedTranslation = context
        .dependOnInheritedWidgetOfExactType<_InheritedWiredashTranslation>();
    return inheritedTranslation.translation(options.currentLocale);
  }

  /// Checks if given [locale] is supported by its langaugeCode
  static bool isSupported(Locale locale) => _isSupported(locale);

  static bool _isSupported(Locale locale) {
    if (locale != null) {
      for (final supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }

  /// List of currently supported locales by Wiredash
  static List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'pl'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'nl'),
      Locale.fromSubtags(languageCode: 'fr'),
    ];
  }
}

class _InheritedWiredashTranslation extends InheritedWidget {
  _InheritedWiredashTranslation({
    Key key,
    @required Map<Locale, WiredashTranslations> customTranslations,
    @required Widget child,
  }) : super(key: key, child: child) {
    final defaultTranslations = <Locale, WiredashTranslations>{
      const Locale.fromSubtags(languageCode: 'en'):
          const en.WiredashLocalizedTranslations(),
      const Locale.fromSubtags(languageCode: 'de'):
          const de.WiredashLocalizedTranslations(),
      const Locale.fromSubtags(languageCode: 'pl'):
          const pl.WiredashLocalizedTranslations(),
      const Locale.fromSubtags(languageCode: 'es'):
          const es.WiredashLocalizedTranslations(),
      const Locale.fromSubtags(languageCode: 'nl'):
          const nl.WiredashLocalizedTranslations(),
      const Locale.fromSubtags(languageCode: 'fr'):
        const fr.WiredashLocalizedTranslations(),
    };
    _translations.addAll(defaultTranslations);

    if (customTranslations != null) {
      _translations.addAll(customTranslations);
    }
  }

  final Map<Locale, WiredashTranslations> _translations =
      <Locale, WiredashTranslations>{};

  WiredashTranslations translation(Locale locale) {
    if (_translations.containsKey(locale)) {
      return _translations[locale];
    } else if (WiredashLocalizations.isSupported(locale)) {
      return _translations[
          Locale.fromSubtags(languageCode: locale.languageCode)];
    } else {
      return _translations[const Locale.fromSubtags(languageCode: 'en')];
    }
  }

  @override
  bool updateShouldNotify(_InheritedWiredashTranslation oldWidget) =>
      _translations != oldWidget._translations;
}
