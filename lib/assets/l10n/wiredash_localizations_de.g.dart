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
  String get feedbackStep3ScreenshotOverviewTitle => 'Screenshot anhängen';

  @override
  String get feedbackStep3ScreenshotOverviewBreadcrumbTitle => 'Screenshots';

  @override
  String get feedbackStep3ScreenshotOverviewDescription =>
      'Du kannst dabei die App weiter bedienen bevor du den Screenshot erstellst';

  @override
  String get feedbackStep3ScreenshotOverviewSkipButton => 'Überspringen';

  @override
  String get feedbackStep3ScreenshotOverviewAddScreenshotButton => 'Screenshot';

  @override
  String get feedbackStep3ScreenshotBarNavigateTitle =>
      'Erstelle einene Screenshot für weiteren Kontext';

  @override
  String get feedbackStep3ScreenshotBarDrawTitle =>
      'Zeichne auf den Screenshot';

  @override
  String get feedbackStep3ScreenshotBarDrawUndoButton => 'Rückgängig';

  @override
  String get feedbackStep3ScreenshotBarCaptureButton => 'Aufnehmen';

  @override
  String get feedbackStep3ScreenshotBarSaveButton => 'Speichern';

  @override
  String get feedbackStep3ScreenshotBarOkButton => 'Ok';

  @override
  String get feedbackStep3GalleryTitle => 'Angehängte Screenshots';

  @override
  String get feedbackStep3GalleryBreadcrumbTitle => 'Screenshots';

  @override
  String get feedbackStep3GalleryDescription =>
      'Füge weitere Screenshots hinzu um dein Problem besser zu beschreiben';

  @override
  String get feedbackStep4EmailTitle =>
      'Werde bei Rückfragen per Email benachrichtigt';

  @override
  String get feedbackStep4EmailBreadcrumbTitle => 'Kontakt';

  @override
  String get feedbackStep4EmailDescription =>
      'Füge deine Email adresse hinzu oder lasse das Feld leer.';

  @override
  String get feedbackStep4EmailInvalidEmail =>
      'Invalide email adresse. Du kannst das Feld auch leer lassen';

  @override
  String get feedbackStep4EmailInputHint => 'mail@example.com';

  @override
  String get feedbackStep6SubmitTitle => 'Feedback absenden';

  @override
  String get feedbackStep6SubmitBreadcrumbTitle => 'Absenden';

  @override
  String get feedbackStep6SubmitDescription =>
      'Bitte kontrolliere dein Feedback vor dem absenden.\nDu kannst auch noch einmal zurück gehen um dein Feedback anzupassen';

  @override
  String get feedbackStep6SubmitSubmitButton => 'Absenden';

  @override
  String get feedbackStep6SubmitSubmitShowDetailsButton => 'Details anzeigen';

  @override
  String get feedbackStep6SubmitSubmitHideDetailsButton => 'Details ausblenden';

  @override
  String get feedbackStep6SubmitSubmitDetailsTitle => 'Feedback Details';

  @override
  String get feedbackStep7SubmissionInFlightMessage => 'Feddback wird gesendet';

  @override
  String get feedbackStep7SubmissionSuccessMessage =>
      'Danke für dein Feedback!';

  @override
  String get feedbackStep7SubmissionErrorMessage => 'Absenden fehlgeschlagen';

  @override
  String get feedbackStep7SubmissionOpenErrorButton =>
      'Klicke um weitere Error Details zu sehen';

  @override
  String get feedbackStep7SubmissionRetryButton => 'Wiederholen';

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

  @override
  String get backdropReturnToApp => 'Zurück zur App';
}
