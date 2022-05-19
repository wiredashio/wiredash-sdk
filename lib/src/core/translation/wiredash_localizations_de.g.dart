import 'wiredash_localizations.g.dart';

/// The translations for German (`de`).
class WiredashLocalizationsDe extends WiredashLocalizations {
  WiredashLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get feedbackStep1MessageTitle => 'Gib uns dein Feedback';

  @override
  String get feedbackStep1MessageBreadcrumbTitle => 'Nachricht verfassen';

  @override
  String get feedbackStep1MessageDescription =>
      'Beschreibe kurz was dir aufgefallen ist';

  @override
  String get feedbackStep1MessageHint =>
      'Wenn ich mein Avatar ändern möchte bekomme ich einen Fehler angezeigt...';

  @override
  String get feedbackStep1MessageErrorMissingMessage =>
      'Schreibe uns bitte dein Feedback';

  @override
  String get feedbackStep2LabelsTitle =>
      'Kannst du dein feedback Labels zuordnen?';

  @override
  String get feedbackStep2LabelsBreadcrumbTitle => 'Labels';

  @override
  String get feedbackStep2LabelsDescription =>
      'Wenn dein Feedback richtig kategorisiert ist, wird es schnell an die richtige Person weitergleitet';

  @override
  String get feedbackStep3ScreenshotOverviewTitle =>
      'Include a screenshot for more context?';

  @override
  String get feedbackStep3ScreenshotOverviewBreadcrumbTitle => 'Screenshots';

  @override
  String get feedbackStep3ScreenshotOverviewDescription =>
      'You’ll be able to navigate the app and choose when to take a screenshot';

  @override
  String get feedbackStep3ScreenshotOverviewSkipButton => 'Skip';

  @override
  String get feedbackStep3ScreenshotOverviewAddScreenshotButton =>
      'Add screenshot';

  @override
  String get feedbackStep3ScreenshotBarNavigateTitle =>
      'Take a screenshot for more context';

  @override
  String get feedbackStep3ScreenshotBarDrawTitle =>
      'Draw to highlight what\'s important';

  @override
  String get feedbackStep3ScreenshotBarDrawUndoButton => 'Undo';

  @override
  String get feedbackStep3ScreenshotBarCaptureButton => 'Capture';

  @override
  String get feedbackStep3ScreenshotBarSaveButton => 'Save';

  @override
  String get feedbackStep3ScreenshotBarOkButton => 'Ok';

  @override
  String get feedbackStep3GalleryTitle => 'Attached screenshots';

  @override
  String get feedbackStep3GalleryBreadcrumbTitle => 'Screenshots';

  @override
  String get feedbackStep3GalleryDescription =>
      'Add more screenshots to help us understand your issue';

  @override
  String get feedbackStep4EmailTitle => 'Get email updates for your issue';

  @override
  String get feedbackStep4EmailBreadcrumbTitle => 'Contact';

  @override
  String get feedbackStep4EmailDescription =>
      'Add your email address below or leave empty';

  @override
  String get feedbackStep4EmailInvalidEmail =>
      'This doesn\'t look like a vlaid email. You can leave it empty';

  @override
  String get feedbackStep4EmailInputHint => 'mail@example.com';

  @override
  String get feedbackStep6SubmitTitle => 'Submit your feedback';

  @override
  String get feedbackStep6SubmitBreadcrumbTitle => 'Submit';

  @override
  String get feedbackStep6SubmitDescription =>
      'Please review your data before submission.\nYou can navigate back to adjust your feedback';

  @override
  String get feedbackStep6SubmitSubmitButton => 'Submit';

  @override
  String get feedbackStep6SubmitSubmitShowDetailsButton => 'Show details';

  @override
  String get feedbackStep6SubmitSubmitHideDetailsButton => 'Hide details';

  @override
  String get feedbackStep6SubmitSubmitDetailsTitle => 'Feedback Details';

  @override
  String get feedbackStep7SubmissionInFlightMessage =>
      'Submitting your feedback';

  @override
  String get feedbackStep7SubmissionSuccessMessage =>
      'Thanks for your feedback!';

  @override
  String get feedbackStep7SubmissionErrorMessage =>
      'Feedback submission failed';

  @override
  String get feedbackStep7SubmissionOpenErrorButton =>
      'Click to open error details';

  @override
  String get feedbackStep7SubmissionRetryButton => 'Retry';

  @override
  String feedbackStepXOfY(int current, int total) {
    return 'Schritt $current von $total';
  }

  @override
  String get feedbackDiscardButton => 'Feedback verwerfen';

  @override
  String get feedbackDiscardConfirmButton => 'Sicher? Löschen!';

  @override
  String get feedbackNextButton => 'Weiter';

  @override
  String get feedbackBackButton => 'Zurück';

  @override
  String get feedbackCloseButton => 'Schließen';
}
