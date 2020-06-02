import 'package:flutter/material.dart';
import 'package:wiredash/src/common/options/wiredash_options.dart';
import 'package:wiredash/wiredash.dart';

import 'l10n/messages_de.dart' as de;
import 'l10n/messages_en.dart' as en;
import 'l10n/messages_es.dart' as es;
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

// class _LocalizationsHandler extends WiredashTranslations {
//   const _LocalizationsHandler() : super();

//   static const WiredashTranslations _defaultEnglishTranslations =
//       WiredashEnglishTranslations();

//   static WiredashTranslations of(BuildContext context) {
//     final options = WiredashOptions.of(context);
//     final translation = WiredashLocalizations.of(context);

//     final customTranslations = options.customTranslations;
//     final customOverride =
//         customTranslations.keys.contains(options.currentLocale);
//     // If locale is default or one of supported by Wiredash,
//     // and not overriden by user
//     // then return instance of this class
//     if (isSupported(options.currentLocale) && !customOverride) {
//       return translation;
//     }

//     final allTranslations = <Locale, WiredashTranslations>{};
//     if (customTranslations != null) {
//       return customTranslations[options.currentLocale];
//     }

//     if (currentTranslations == null) {
//       return _defaultEnglishTranslations;
//     }
//     return currentTranslations;
//   }

//   @override
//   String get inputHintFeedback {
//     return Intl.message(
//       'Your feedback',
//       name: 'inputHintFeedback',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get inputHintEmail {
//     return Intl.message(
//       'Your email',
//       name: 'inputHintEmail',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get validationHintFeedbackEmpty {
//     return Intl.message(
//       'Please provide your feedback.',
//       name: 'validationHintFeedbackEmpty',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get validationHintFeedbackLength {
//     return Intl.message(
//       'Your feedback is too long.',
//       name: 'validationHintFeedbackLength',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get validationHintEmail {
//     return Intl.message(
//       'Please enter a valid email or leave this field blank.',
//       name: 'validationHintEmail',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get feedbackStateFeedbackTitle {
//     return Intl.message(
//       'Your feedback ✍️',
//       name: 'feedbackStateFeedbackTitle',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get feedbackStateSuccessCloseMsg {
//     return Intl.message(
//       'Thanks for submitting your feedback!',
//       name: 'feedbackStateSuccessCloseMsg',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get feedbackStateSuccessCloseTitle {
//     return Intl.message(
//       'Close this Dialog',
//       name: 'feedbackStateSuccessCloseTitle',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get feedbackStateSuccessMsg {
//     return Intl.message(
//       "That's it. Thank you so much for helping us building a better app!",
//       name: 'feedbackStateSuccessMsg',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get feedbackStateSuccessTitle {
//     return Intl.message(
//       'Thank you ✌️',
//       name: 'feedbackStateSuccessTitle',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get feedbackStateEmailMsg {
//     return Intl.message(
//       'If you want to get updates regarding your feedback, enter your email down below.',
//       name: 'feedbackStateEmailMsg',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get feedbackStateEmailTitle {
//     return Intl.message(
//       'Stay in the loop 👇',
//       name: 'feedbackStateEmailTitle',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get feedbackStateFeedbackMsg {
//     return Intl.message(
//       'We are listening. Please provide as much info as needed so we can help you.',
//       name: 'feedbackStateFeedbackMsg',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get feedbackStateIntroMsg {
//     return Intl.message(
//       'We can’t wait to get your thoughts on our app. What would you like to do?',
//       name: 'feedbackStateIntroMsg',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get feedbackStateIntroTitle {
//     return Intl.message(
//       'Hi there 👋',
//       name: 'feedbackStateIntroTitle',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get feedbackSend {
//     return Intl.message(
//       'Send feedback',
//       name: 'feedbackSend',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get feedbackSave {
//     return Intl.message(
//       'Save',
//       name: 'feedbackSave',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get feedbackCancel {
//     return Intl.message(
//       'Cancel',
//       name: 'feedbackCancel',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get feedbackBack {
//     return Intl.message(
//       'Go back',
//       name: 'feedbackBack',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get feedbackModePraiseMsg {
//     return Intl.message(
//       'Let us know what you really like about our app, maybe we can make it even better?',
//       name: 'feedbackModePraiseMsg',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get feedbackModePraiseTitle {
//     return Intl.message(
//       'Send Applause',
//       name: 'feedbackModePraiseTitle',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get feedbackModeImprovementMsg {
//     return Intl.message(
//       'Do you have an idea that would make our app better? We would love to know!',
//       name: 'feedbackModeImprovementMsg',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get feedbackModeImprovementTitle {
//     return Intl.message(
//       'Request a Feature',
//       name: 'feedbackModeImprovementTitle',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get feedbackModeBugMsg {
//     return Intl.message(
//       'Let us know so we can forward this to our bug control.',
//       name: 'feedbackModeBugMsg',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get feedbackModeBugTitle {
//     return Intl.message(
//       'Report a Bug',
//       name: 'feedbackModeBugTitle',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get captureSpotlightScreenCapturedMsg {
//     return Intl.message(
//       'Screen captured! Feel free to draw on the screen to highlight areas affected by your capture.',
//       name: 'captureSpotlightScreenCapturedMsg',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get captureSpotlightScreenCapturedTitle {
//     return Intl.message(
//       'draw',
//       name: 'captureSpotlightScreenCapturedTitle',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get captureSpotlightNavigateMsg {
//     return Intl.message(
//       'Navigate to the screen which you would like to attach to your capture.',
//       name: 'captureSpotlightNavigateMsg',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get captureSpotlightNavigateTitle {
//     return Intl.message(
//       'navigate',
//       name: 'captureSpotlightNavigateTitle',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get captureSaveScreenshot {
//     return Intl.message(
//       'Save screenshot',
//       name: 'captureSaveScreenshot',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get captureTakeScreenshot {
//     return Intl.message(
//       'Take screenshot',
//       name: 'captureTakeScreenshot',
//       desc: '',
//       args: [],
//     );
//   }

//   @override
//   String get captureSkip {
//     return Intl.message(
//       'Skip screenshot',
//       name: 'captureSkip',
//       desc: '',
//       args: [],
//     );
//   }
// }
