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
