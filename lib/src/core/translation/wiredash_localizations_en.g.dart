import 'wiredash_localizations.g.dart';

/// The translations for English (`en`).
class WiredashLocalizationsEn extends WiredashLocalizations {
  WiredashLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get feedbackStep1MessageTitle => 'Send us your feedback';

  @override
  String get feedbackStep1MessageBreadcrumbTitle => 'Compose message';

  @override
  String get feedbackStep1MessageDescription =>
      'Add a short description of what you encountered';

  @override
  String get feedbackStep1MessageHint =>
      'There\'s an unknown error when I try to change my avatar...';

  @override
  String get feedbackStep1MessageErrorMissingMessage =>
      'Please enter a feedback message';

  @override
  String get feedbackStep2LabelsTitle =>
      'Which label represents your feedback?';

  @override
  String get feedbackStep2LabelsBreadcrumbTitle => 'Labels';

  @override
  String get feedbackStep2LabelsDescription =>
      'Selecting the correct category helps forwarding your feedback to the best person to resolve your issue';

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
    return 'Step $current of $total';
  }

  @override
  String get feedbackDiscardButton => 'Discard Feedback';

  @override
  String get feedbackDiscardConfirmButton => 'Really? Discard!';

  @override
  String get feedbackNextButton => 'Next';

  @override
  String get feedbackBackButton => 'Back';

  @override
  String get feedbackCloseButton => 'Close';
}
