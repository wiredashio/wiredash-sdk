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
      Future.sync(() => _CustomTranslationsEn());

  @override
  bool shouldReload(CustomWiredashTranslationsDelegate old) => false;
}

/// This english translation extends the default english Wiredash translations.
/// This makes is robost to changes when new terms are added.
class _CustomTranslationsEn extends WiredashLocalizationsEn {
  @override
  String get feedbackStep1MessageTitle => 'feedback_step1_message_title';
}
