import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/wiredash.dart';

class CustomWiredashTranslationsDelegate
    extends LocalizationsDelegate<WiredashLocalizations> {
  const CustomWiredashTranslationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<WiredashLocalizations> load(Locale locale) =>
      SynchronousFuture(_CustomTranslationsEn());

  @override
  bool shouldReload(CustomWiredashTranslationsDelegate old) => false;
}

/// This english translation extends the default english Wiredash translations.
/// This makes is robost to changes when new terms are added.
class _CustomTranslationsEn extends WiredashLocalizationsEn {
  @override
  String get feedbackStep1MessageTitle => 'feedbackStep1MessageTitle';

  @override
  String get feedbackStep1MessageDescription =>
      'feedbackStep1MessageDescription';

  @override
  String get feedbackStep1MessageHint => 'feedbackStep1MessageHint';
}
