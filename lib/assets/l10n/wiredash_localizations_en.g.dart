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
  String get feedbackStep1MessageErrorMissingMessage => 'Please add a message';

  @override
  String get feedbackStep2LabelsTitle =>
      'Which label best represents your feedback?';

  @override
  String get feedbackStep2LabelsBreadcrumbTitle => 'Labels';

  @override
  String get feedbackStep2LabelsDescription =>
      'Selecting the right category helps us identify the issue and route your feedback to the correct stakeholder';

  @override
  String get feedbackStep3ScreenshotOverviewTitle =>
      'Add screenshots for better context?';

  @override
  String get feedbackStep3ScreenshotOverviewBreadcrumbTitle => 'Screenshots';

  @override
  String get feedbackStep3ScreenshotOverviewDescription =>
      'You\'ll be able to navigate the app and choose when to take a screenshot';

  @override
  String get feedbackStep3ScreenshotOverviewSkipButton => 'Skip';

  @override
  String get feedbackStep3ScreenshotOverviewAddScreenshotButton =>
      'Add screenshot';

  @override
  String get feedbackStep3ScreenshotBarNavigateTitle => 'Take a screenshot';

  @override
  String get feedbackStep3ScreenshotBarDrawTitle =>
      'Draw on screen to add highlights';

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
      'You can add more screenshots to help us understand your issue even better.';

  @override
  String get feedbackStep4EmailTitle => 'Get email updates on your issue';

  @override
  String get feedbackStep4EmailBreadcrumbTitle => 'Contact';

  @override
  String get feedbackStep4EmailDescription =>
      'Add your email address below or leave empty';

  @override
  String get feedbackStep4EmailInvalidEmail =>
      'This doesn\'t look like a valid email address. You can leave it empty.';

  @override
  String get feedbackStep4EmailInputHint => 'mail@example.com';

  @override
  String get feedbackStep6SubmitTitle => 'Submit feedback';

  @override
  String get feedbackStep6SubmitBreadcrumbTitle => 'Submit';

  @override
  String get feedbackStep6SubmitDescription =>
      'Please review all info before submission.\nYou can navigate back to adjust your feedback any time.';

  @override
  String get feedbackStep6SubmitSubmitButton => 'Submit';

  @override
  String get feedbackStep6SubmitSubmitShowDetailsButton => 'Show details';

  @override
  String get feedbackStep6SubmitSubmitHideDetailsButton => 'Hide details';

  @override
  String get feedbackStep6SubmitSubmitDetailsTitle => 'Feedback details';

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
      'Click to see error details';

  @override
  String get feedbackStep7SubmissionRetryButton => 'Retry';

  @override
  String feedbackStepXOfY(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get feedbackDiscardButton => 'Discard feedback';

  @override
  String get feedbackDiscardConfirmButton => 'Really? Discard!';

  @override
  String get feedbackNextButton => 'Next';

  @override
  String get feedbackBackButton => 'Back';

  @override
  String get feedbackCloseButton => 'Close';

  @override
  String get backdropReturnToApp => 'Return to app';
}
