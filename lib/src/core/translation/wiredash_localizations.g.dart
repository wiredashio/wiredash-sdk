import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'wiredash_localizations_de.g.dart';
import 'wiredash_localizations_en.g.dart';

/// Callers can lookup localized strings with an instance of WiredashLocalizations returned
/// by `WiredashLocalizations.of(context)`.
///
/// Applications need to include `WiredashLocalizations.delegate()` in their app's
/// localizationDelegates list, and the locales they support in the app's
/// supportedLocales list. For example:
///
/// ```
/// import 'translation/wiredash_localizations.g.dart';
///
/// return MaterialApp(
///   localizationsDelegates: WiredashLocalizations.localizationsDelegates,
///   supportedLocales: WiredashLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the WiredashLocalizations.supportedLocales
/// property.
abstract class WiredashLocalizations {
  WiredashLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static WiredashLocalizations of(BuildContext context) {
    return Localizations.of<WiredashLocalizations>(
        context, WiredashLocalizations)!;
  }

  static const LocalizationsDelegate<WiredashLocalizations> delegate =
      _WiredashLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// No description provided for @feedbackStep1MessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Send us your feedback'**
  String get feedbackStep1MessageTitle;

  /// No description provided for @feedbackStep1MessageDescription.
  ///
  /// In en, this message translates to:
  /// **'Add a short description of what you encountered'**
  String get feedbackStep1MessageDescription;

  /// No description provided for @feedbackStep1MessageHint.
  ///
  /// In en, this message translates to:
  /// **'There\'s an unknown error when I try to change my avatar...'**
  String get feedbackStep1MessageHint;

  /// No description provided for @feedbackStep1MessageErrorMissingMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter a feedback message'**
  String get feedbackStep1MessageErrorMissingMessage;

  /// No description provided for @feedbackStep1MessageBreadcrumbTitle.
  ///
  /// In en, this message translates to:
  /// **'Compose message'**
  String get feedbackStep1MessageBreadcrumbTitle;

  /// No description provided for @feedbackStepXOfY.
  ///
  /// In en, this message translates to:
  /// **'Step {x} of {y}'**
  String feedbackStepXOfY(Object x, Object y);

  /// No description provided for @feedbackDiscardButton.
  ///
  /// In en, this message translates to:
  /// **'Discard Feedback'**
  String get feedbackDiscardButton;

  /// No description provided for @feedbackDiscardConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Really? Discard!'**
  String get feedbackDiscardConfirmButton;

  /// No description provided for @feedbackCloseButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get feedbackCloseButton;

  /// No description provided for @feedbackNextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get feedbackNextButton;
}

class _WiredashLocalizationsDelegate
    extends LocalizationsDelegate<WiredashLocalizations> {
  const _WiredashLocalizationsDelegate();

  @override
  Future<WiredashLocalizations> load(Locale locale) {
    return SynchronousFuture<WiredashLocalizations>(
        lookupWiredashLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_WiredashLocalizationsDelegate old) => false;
}

WiredashLocalizations lookupWiredashLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return WiredashLocalizationsDe();
    case 'en':
      return WiredashLocalizationsEn();
  }

  throw FlutterError(
      'WiredashLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
