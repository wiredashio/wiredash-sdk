import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'wiredash_localizations_de.g.dart';
import 'wiredash_localizations_en.g.dart';
import 'wiredash_localizations_es.g.dart';
import 'wiredash_localizations_pt.g.dart';
import 'wiredash_localizations_tr.g.dart';

/// Callers can lookup localized strings with an instance of WiredashLocalizations
/// returned by `WiredashLocalizations.of(context)`.
///
/// Applications need to include `WiredashLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/wiredash_localizations.g.dart';
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
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
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
    Locale('en'),
    Locale('es'),
    Locale('pt'),
    Locale('tr')
  ];

  /// No description provided for @feedbackStep1MessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Send us your feedback'**
  String get feedbackStep1MessageTitle;

  /// No description provided for @feedbackStep1MessageBreadcrumbTitle.
  ///
  /// In en, this message translates to:
  /// **'Compose message'**
  String get feedbackStep1MessageBreadcrumbTitle;

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
  /// **'Please add a message'**
  String get feedbackStep1MessageErrorMissingMessage;

  /// No description provided for @feedbackStep2LabelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Which label best represents your feedback?'**
  String get feedbackStep2LabelsTitle;

  /// No description provided for @feedbackStep2LabelsBreadcrumbTitle.
  ///
  /// In en, this message translates to:
  /// **'Labels'**
  String get feedbackStep2LabelsBreadcrumbTitle;

  /// No description provided for @feedbackStep2LabelsDescription.
  ///
  /// In en, this message translates to:
  /// **'Selecting the right category helps us identify the issue and route your feedback to the correct stakeholder'**
  String get feedbackStep2LabelsDescription;

  /// No description provided for @feedbackStep3ScreenshotOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Add screenshots for better context?'**
  String get feedbackStep3ScreenshotOverviewTitle;

  /// No description provided for @feedbackStep3ScreenshotOverviewBreadcrumbTitle.
  ///
  /// In en, this message translates to:
  /// **'Screenshots'**
  String get feedbackStep3ScreenshotOverviewBreadcrumbTitle;

  /// No description provided for @feedbackStep3ScreenshotOverviewDescription.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be able to navigate the app and choose when to take a screenshot'**
  String get feedbackStep3ScreenshotOverviewDescription;

  /// No description provided for @feedbackStep3ScreenshotOverviewSkipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get feedbackStep3ScreenshotOverviewSkipButton;

  /// No description provided for @feedbackStep3ScreenshotOverviewAddScreenshotButton.
  ///
  /// In en, this message translates to:
  /// **'Add screenshot'**
  String get feedbackStep3ScreenshotOverviewAddScreenshotButton;

  /// No description provided for @feedbackStep3ScreenshotBarNavigateTitle.
  ///
  /// In en, this message translates to:
  /// **'Take a screenshot'**
  String get feedbackStep3ScreenshotBarNavigateTitle;

  /// No description provided for @feedbackStep3ScreenshotBarDrawTitle.
  ///
  /// In en, this message translates to:
  /// **'Draw on screen to add highlights'**
  String get feedbackStep3ScreenshotBarDrawTitle;

  /// No description provided for @feedbackStep3ScreenshotBarDrawUndoButton.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get feedbackStep3ScreenshotBarDrawUndoButton;

  /// No description provided for @feedbackStep3ScreenshotBarCaptureButton.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get feedbackStep3ScreenshotBarCaptureButton;

  /// No description provided for @feedbackStep3ScreenshotBarSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get feedbackStep3ScreenshotBarSaveButton;

  /// No description provided for @feedbackStep3ScreenshotBarOkButton.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get feedbackStep3ScreenshotBarOkButton;

  /// No description provided for @feedbackStep3GalleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Attached screenshots'**
  String get feedbackStep3GalleryTitle;

  /// No description provided for @feedbackStep3GalleryBreadcrumbTitle.
  ///
  /// In en, this message translates to:
  /// **'Screenshots'**
  String get feedbackStep3GalleryBreadcrumbTitle;

  /// No description provided for @feedbackStep3GalleryDescription.
  ///
  /// In en, this message translates to:
  /// **'You can add more screenshots to help us understand your issue even better.'**
  String get feedbackStep3GalleryDescription;

  /// No description provided for @feedbackStep4EmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Get email updates on your issue'**
  String get feedbackStep4EmailTitle;

  /// No description provided for @feedbackStep4EmailBreadcrumbTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get feedbackStep4EmailBreadcrumbTitle;

  /// No description provided for @feedbackStep4EmailDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your email address below or leave empty'**
  String get feedbackStep4EmailDescription;

  /// No description provided for @feedbackStep4EmailInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'This doesn\'t look like a valid email address. You can leave it empty.'**
  String get feedbackStep4EmailInvalidEmail;

  /// No description provided for @feedbackStep4EmailInputHint.
  ///
  /// In en, this message translates to:
  /// **'mail@example.com'**
  String get feedbackStep4EmailInputHint;

  /// No description provided for @feedbackStep6SubmitTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit feedback'**
  String get feedbackStep6SubmitTitle;

  /// No description provided for @feedbackStep6SubmitBreadcrumbTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get feedbackStep6SubmitBreadcrumbTitle;

  /// No description provided for @feedbackStep6SubmitDescription.
  ///
  /// In en, this message translates to:
  /// **'Please review all info before submission.\nYou can navigate back to adjust your feedback any time.'**
  String get feedbackStep6SubmitDescription;

  /// No description provided for @feedbackStep6SubmitSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get feedbackStep6SubmitSubmitButton;

  /// No description provided for @feedbackStep6SubmitSubmitShowDetailsButton.
  ///
  /// In en, this message translates to:
  /// **'Show details'**
  String get feedbackStep6SubmitSubmitShowDetailsButton;

  /// No description provided for @feedbackStep6SubmitSubmitHideDetailsButton.
  ///
  /// In en, this message translates to:
  /// **'Hide details'**
  String get feedbackStep6SubmitSubmitHideDetailsButton;

  /// No description provided for @feedbackStep6SubmitSubmitDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback details'**
  String get feedbackStep6SubmitSubmitDetailsTitle;

  /// No description provided for @feedbackStep7SubmissionInFlightMessage.
  ///
  /// In en, this message translates to:
  /// **'Submitting your feedback'**
  String get feedbackStep7SubmissionInFlightMessage;

  /// No description provided for @feedbackStep7SubmissionSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your feedback!'**
  String get feedbackStep7SubmissionSuccessMessage;

  /// No description provided for @feedbackStep7SubmissionErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Feedback submission failed'**
  String get feedbackStep7SubmissionErrorMessage;

  /// No description provided for @feedbackStep7SubmissionOpenErrorButton.
  ///
  /// In en, this message translates to:
  /// **'Click to see error details'**
  String get feedbackStep7SubmissionOpenErrorButton;

  /// No description provided for @feedbackStep7SubmissionRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get feedbackStep7SubmissionRetryButton;

  /// No description provided for @feedbackStepXOfY.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String feedbackStepXOfY(int current, int total);

  /// No description provided for @feedbackDiscardButton.
  ///
  /// In en, this message translates to:
  /// **'Discard feedback'**
  String get feedbackDiscardButton;

  /// No description provided for @feedbackDiscardConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Really? Discard!'**
  String get feedbackDiscardConfirmButton;

  /// No description provided for @feedbackNextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get feedbackNextButton;

  /// No description provided for @feedbackBackButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get feedbackBackButton;

  /// No description provided for @feedbackCloseButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get feedbackCloseButton;

  /// No description provided for @backdropReturnToApp.
  ///
  /// In en, this message translates to:
  /// **'Return to app'**
  String get backdropReturnToApp;
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
      <String>['de', 'en', 'es', 'pt', 'tr'].contains(locale.languageCode);

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
    case 'es':
      return WiredashLocalizationsEs();
    case 'pt':
      return WiredashLocalizationsPt();
    case 'tr':
      return WiredashLocalizationsTr();
  }

  throw FlutterError(
      'WiredashLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
