import 'wiredash_localizations.g.dart';

/// The translations for English (`en`).
class WiredashLocalizationsEn extends WiredashLocalizations {
  WiredashLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get feedbackStep1MessageTitle => 'Send us your feedback';

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
  String get feedbackStep1MessageBreadcrumbTitle => 'Compose message';

  @override
  String feedbackStepXOfY(Object x, Object y) {
    return 'Step $x of $y';
  }

  @override
  String get feedbackDiscardButton => 'Discard Feedback';

  @override
  String get feedbackDiscardConfirmButton => 'Really? Discard!';

  @override
  String get feedbackCloseButton => 'Close';

  @override
  String get feedbackNextButton => 'Next';
}
