import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wiredash/src/common/options/wiredash_options.dart';
import 'package:wiredash/wiredash.dart';

import 'l10n/messages_all.dart';

class WiredashLocalizations extends WiredashTranslations {
  WiredashLocalizations();

  static const WiredashLocalizationDelegate delegate =
      WiredashLocalizationDelegate();

  static const WiredashTranslations _defaultEnglishTranslations =
      WiredashEnglishTranslations();

  static Future<WiredashLocalizations> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return WiredashLocalizations();
    });
  }

  static WiredashTranslations of(BuildContext context) {
    final customTranslations = WiredashOptions.of(context).customTranslations;
    if (customTranslations != null) {
      return customTranslations;
    }
    final localization =
        Localizations.of<WiredashLocalizations>(context, WiredashLocalizations);
    if (localization == null) {
      return _defaultEnglishTranslations;
    }
    return localization;
  }

  @override
  String get inputHintFeedback {
    return Intl.message(
      'Your feedback',
      name: 'inputHintFeedback',
      desc: '',
      args: [],
    );
  }

  @override
  String get inputHintEmail {
    return Intl.message(
      'Your email',
      name: 'inputHintEmail',
      desc: '',
      args: [],
    );
  }

  @override
  String get validationHintFeedbackEmpty {
    return Intl.message(
      'Please provide your feedback.',
      name: 'validationHintFeedbackEmpty',
      desc: '',
      args: [],
    );
  }

  @override
  String get validationHintFeedbackLength {
    return Intl.message(
      'Your feedback is too long.',
      name: 'validationHintFeedbackLength',
      desc: '',
      args: [],
    );
  }

  @override
  String get validationHintEmail {
    return Intl.message(
      'Please enter a valid email or leave this field blank.',
      name: 'validationHintEmail',
      desc: '',
      args: [],
    );
  }

  @override
  String get feedbackStateFeedbackTitle {
    return Intl.message(
      'Your feedback ✍️',
      name: 'feedbackStateFeedbackTitle',
      desc: '',
      args: [],
    );
  }

  @override
  String get feedbackStateSuccessCloseMsg {
    return Intl.message(
      'Thanks for submitting your feedback!',
      name: 'feedbackStateSuccessCloseMsg',
      desc: '',
      args: [],
    );
  }

  @override
  String get feedbackStateSuccessCloseTitle {
    return Intl.message(
      'Close this Dialog',
      name: 'feedbackStateSuccessCloseTitle',
      desc: '',
      args: [],
    );
  }

  @override
  String get feedbackStateSuccessMsg {
    return Intl.message(
      "That's it. Thank you so much for helping us building a better app!",
      name: 'feedbackStateSuccessMsg',
      desc: '',
      args: [],
    );
  }

  @override
  String get feedbackStateSuccessTitle {
    return Intl.message(
      'Thank you ✌️',
      name: 'feedbackStateSuccessTitle',
      desc: '',
      args: [],
    );
  }

  @override
  String get feedbackStateEmailMsg {
    return Intl.message(
      'If you want to get updates regarding your feedback, enter your email down below.',
      name: 'feedbackStateEmailMsg',
      desc: '',
      args: [],
    );
  }

  @override
  String get feedbackStateEmailTitle {
    return Intl.message(
      'Stay in the loop 👇',
      name: 'feedbackStateEmailTitle',
      desc: '',
      args: [],
    );
  }

  @override
  String get feedbackStateFeedbackMsg {
    return Intl.message(
      'We are listening. Please provide as much info as needed so we can help you.',
      name: 'feedbackStateFeedbackMsg',
      desc: '',
      args: [],
    );
  }

  @override
  String get feedbackStateIntroMsg {
    return Intl.message(
      'We can’t wait to get your thoughts on our app. What would you like to do?',
      name: 'feedbackStateIntroMsg',
      desc: '',
      args: [],
    );
  }

  @override
  String get feedbackStateIntroTitle {
    return Intl.message(
      'Hi there 👋',
      name: 'feedbackStateIntroTitle',
      desc: '',
      args: [],
    );
  }

  @override
  String get feedbackSend {
    return Intl.message(
      'Send feedback',
      name: 'feedbackSend',
      desc: '',
      args: [],
    );
  }

  @override
  String get feedbackSave {
    return Intl.message(
      'Save',
      name: 'feedbackSave',
      desc: '',
      args: [],
    );
  }

  @override
  String get feedbackCancel {
    return Intl.message(
      'Cancel',
      name: 'feedbackCancel',
      desc: '',
      args: [],
    );
  }

  @override
  String get feedbackBack {
    return Intl.message(
      'Go back',
      name: 'feedbackBack',
      desc: '',
      args: [],
    );
  }

  @override
  String get feedbackModePraiseMsg {
    return Intl.message(
      'Let us know what you really like about our app, maybe we can make it even better?',
      name: 'feedbackModePraiseMsg',
      desc: '',
      args: [],
    );
  }

  @override
  String get feedbackModePraiseTitle {
    return Intl.message(
      'Send Applause',
      name: 'feedbackModePraiseTitle',
      desc: '',
      args: [],
    );
  }

  @override
  String get feedbackModeImprovementMsg {
    return Intl.message(
      'Do you have an idea that would make our app better? We would love to know!',
      name: 'feedbackModeImprovementMsg',
      desc: '',
      args: [],
    );
  }

  @override
  String get feedbackModeImprovementTitle {
    return Intl.message(
      'Request a Feature',
      name: 'feedbackModeImprovementTitle',
      desc: '',
      args: [],
    );
  }

  @override
  String get feedbackModeBugMsg {
    return Intl.message(
      'Let us know so we can forward this to our bug control.',
      name: 'feedbackModeBugMsg',
      desc: '',
      args: [],
    );
  }

  @override
  String get feedbackModeBugTitle {
    return Intl.message(
      'Report a Bug',
      name: 'feedbackModeBugTitle',
      desc: '',
      args: [],
    );
  }

  @override
  String get captureSpotlightScreenCapturedMsg {
    return Intl.message(
      'Screen captured! Feel free to draw on the screen to highlight areas affected by your capture.',
      name: 'captureSpotlightScreenCapturedMsg',
      desc: '',
      args: [],
    );
  }

  @override
  String get captureSpotlightScreenCapturedTitle {
    return Intl.message(
      'draw',
      name: 'captureSpotlightScreenCapturedTitle',
      desc: '',
      args: [],
    );
  }

  @override
  String get captureSpotlightNavigateMsg {
    return Intl.message(
      'Navigate to the screen which you would like to attach to your capture.',
      name: 'captureSpotlightNavigateMsg',
      desc: '',
      args: [],
    );
  }

  @override
  String get captureSpotlightNavigateTitle {
    return Intl.message(
      'navigate',
      name: 'captureSpotlightNavigateTitle',
      desc: '',
      args: [],
    );
  }

  @override
  String get captureSaveScreenshot {
    return Intl.message(
      'Save screenshot',
      name: 'captureSaveScreenshot',
      desc: '',
      args: [],
    );
  }

  @override
  String get captureTakeScreenshot {
    return Intl.message(
      'Take screenshot',
      name: 'captureTakeScreenshot',
      desc: '',
      args: [],
    );
  }

  @override
  String get captureSkip {
    return Intl.message(
      'Skip screenshot',
      name: 'captureSkip',
      desc: '',
      args: [],
    );
  }
}

class WiredashLocalizationDelegate
    extends LocalizationsDelegate<WiredashLocalizations> {
  const WiredashLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'pl'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<WiredashLocalizations> load(Locale locale) =>
      WiredashLocalizations.load(locale);
  @override
  bool shouldReload(WiredashLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (final supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}
