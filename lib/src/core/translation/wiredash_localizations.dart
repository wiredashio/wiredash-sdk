import 'package:flutter/material.dart';
import 'package:wiredash/src/core/options/wiredash_options.dart';
import 'package:wiredash/src/core/translation/l10n/messages_ar.dart' as ar;
import 'package:wiredash/src/core/translation/l10n/messages_da.dart' as da;
import 'package:wiredash/src/core/translation/l10n/messages_de.dart' as de;
import 'package:wiredash/src/core/translation/l10n/messages_en.dart' as en;
import 'package:wiredash/src/core/translation/l10n/messages_es.dart' as es;
import 'package:wiredash/src/core/translation/l10n/messages_fr.dart' as fr;
import 'package:wiredash/src/core/translation/l10n/messages_hu.dart' as hu;
import 'package:wiredash/src/core/translation/l10n/messages_ko.dart' as ko;
import 'package:wiredash/src/core/translation/l10n/messages_nl.dart' as nl;
import 'package:wiredash/src/core/translation/l10n/messages_pl.dart' as pl;
import 'package:wiredash/src/core/translation/l10n/messages_pt.dart' as pt;
import 'package:wiredash/src/core/translation/l10n/messages_ru.dart' as ru;
import 'package:wiredash/src/core/translation/l10n/messages_tr.dart' as tr;
import 'package:wiredash/src/core/translation/l10n/messages_zh_cn.dart' as zhcn;
import 'package:wiredash/src/core/translation/wiredash_translations.dart';
import 'package:wiredash/wiredash.dart';

class WiredashLocalizations extends StatelessWidget {
  const WiredashLocalizations({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final options = WiredashOptions.of(context);
    return _InheritedWiredashTranslation(
      customTranslations: options?.customTranslations,
      child: child,
    );
  }

  static WiredashTranslations? of(BuildContext context) {
    final options = WiredashOptions.of(context);
    final _InheritedWiredashTranslation? inheritedTranslation = context
        .dependOnInheritedWidgetOfExactType<_InheritedWiredashTranslation>();
    return inheritedTranslation?.translation(options?.currentLocale);
  }

  /// Checks if given [locale] is supported by its langaugeCode
  static bool isSupported(Locale locale) => _isSupported(locale);

  static bool _isSupported(Locale locale) {
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }

  /// List of currently supported locales by Wiredash
  static List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'da'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'pl'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'nl'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'hu'),
      Locale.fromSubtags(languageCode: 'ko'),
      Locale.fromSubtags(languageCode: 'pt'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'tr'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'cn'),
    ];
  }
}

class _InheritedWiredashTranslation extends InheritedWidget {
  _InheritedWiredashTranslation({
    Key? key,
    required Map<Locale, WiredashTranslations>? customTranslations,
    required Widget child,
  }) : super(key: key, child: child) {
    final defaultTranslations = <Locale, WiredashTranslations>{
      const Locale.fromSubtags(languageCode: 'ar'):
          const ar.WiredashLocalizedTranslations(),
      const Locale.fromSubtags(languageCode: 'en'):
          const en.WiredashLocalizedTranslations(),
      const Locale.fromSubtags(languageCode: 'da'):
          const da.WiredashLocalizedTranslations(),
      const Locale.fromSubtags(languageCode: 'de'):
          const de.WiredashLocalizedTranslations(),
      const Locale.fromSubtags(languageCode: 'es'):
          const es.WiredashLocalizedTranslations(),
      const Locale.fromSubtags(languageCode: 'fr'):
          const fr.WiredashLocalizedTranslations(),
      const Locale.fromSubtags(languageCode: 'hu'):
          const hu.WiredashLocalizedTranslations(),
      const Locale.fromSubtags(languageCode: 'ko'):
          const ko.WiredashLocalizedTranslations(),
      const Locale.fromSubtags(languageCode: 'nl'):
          const nl.WiredashLocalizedTranslations(),
      const Locale.fromSubtags(languageCode: 'pl'):
          const pl.WiredashLocalizedTranslations(),
      const Locale.fromSubtags(languageCode: 'pt'):
          const pt.WiredashLocalizedTranslations(),
      const Locale.fromSubtags(languageCode: 'ru'):
          const ru.WiredashLocalizedTranslations(),
      const Locale.fromSubtags(languageCode: 'tr'):
          const tr.WiredashLocalizedTranslations(),
      const Locale.fromSubtags(languageCode: 'zh'):
          const zhcn.WiredashLocalizedTranslations(),
      const Locale.fromSubtags(languageCode: 'zh', countryCode: 'cn'):
          const zhcn.WiredashLocalizedTranslations(),
    };
    _translations.addAll(defaultTranslations);

    if (customTranslations != null) {
      _translations.addAll(customTranslations);
    }
  }

  final Map<Locale, WiredashTranslations> _translations =
      <Locale, WiredashTranslations>{};

  WiredashTranslations translation(Locale? locale) {
    if (locale != null) {
      if (_translations.containsKey(locale)) {
        return _translations[locale]!;
      } else if (WiredashLocalizations.isSupported(locale)) {
        final translation = _translations[
            Locale.fromSubtags(languageCode: locale.languageCode)];
        if (translation != null) {
          return translation;
        }
      }
    }
    return _translations[const Locale.fromSubtags(languageCode: 'en')]!;
  }

  @override
  bool updateShouldNotify(_InheritedWiredashTranslation oldWidget) =>
      _translations != oldWidget._translations;
}
