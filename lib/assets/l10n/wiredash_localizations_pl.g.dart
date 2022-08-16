import 'wiredash_localizations.g.dart';

/// The translations for Polish (`pl`).
class WiredashLocalizationsPl extends WiredashLocalizations {
  WiredashLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get feedbackStep1MessageTitle => 'Podziel się swoją opinią';

  @override
  String get feedbackStep1MessageBreadcrumbTitle => 'Wpisz wiadomość';

  @override
  String get feedbackStep1MessageDescription =>
      'Opisz krótko problem, który widzisz';

  @override
  String get feedbackStep1MessageHint =>
      'Pojawia się nieznany błąd, gdy próbuję zmienić mój avatar...';

  @override
  String get feedbackStep1MessageErrorMissingMessage =>
      'Prosimy wpisz wiadomość';

  @override
  String get feedbackStep2LabelsTitle =>
      'Która opcja najlepiej pasuje do twojej opinii?';

  @override
  String get feedbackStep2LabelsBreadcrumbTitle => 'Etykiety';

  @override
  String get feedbackStep2LabelsDescription =>
      'Wybranie prawidłowej etykiety pomoże nam skierować opinię do odpowiedniej osoby';

  @override
  String get feedbackStep3ScreenshotOverviewTitle =>
      'Czy chcesz dodać zrzut ekranu?';

  @override
  String get feedbackStep3ScreenshotOverviewBreadcrumbTitle => 'Zrzuty ekranu';

  @override
  String get feedbackStep3ScreenshotOverviewDescription =>
      'Możesz nawigować po aplikacji, by wykonać zrzut ekranu';

  @override
  String get feedbackStep3ScreenshotOverviewSkipButton => 'Pomiń';

  @override
  String get feedbackStep3ScreenshotOverviewAddScreenshotButton =>
      'Dodaj zrzut ekranu';

  @override
  String get feedbackStep3ScreenshotBarNavigateTitle => 'Wykonaj zrzut ekranu';

  @override
  String get feedbackStep3ScreenshotBarDrawTitle =>
      'Zaznacz rysując po ekranie';

  @override
  String get feedbackStep3ScreenshotBarDrawUndoButton => 'Cofnij';

  @override
  String get feedbackStep3ScreenshotBarCaptureButton => 'Wykonaj';

  @override
  String get feedbackStep3ScreenshotBarSaveButton => 'Zapisz';

  @override
  String get feedbackStep3ScreenshotBarOkButton => 'Ok';

  @override
  String get feedbackStep3GalleryTitle => 'Dodane zrzuty ekranu';

  @override
  String get feedbackStep3GalleryBreadcrumbTitle => 'Zrzuty ekranu';

  @override
  String get feedbackStep3GalleryDescription =>
      'Możesz dodać więcej zrzutów, byśmy lepiej zrozumieli zgłoszenie.';

  @override
  String get feedbackStep4EmailTitle =>
      'Otrzymuj powiadomienia e-mail na temat zgłoszenia';

  @override
  String get feedbackStep4EmailBreadcrumbTitle => 'Kontakt';

  @override
  String get feedbackStep4EmailDescription =>
      'Podaj swój adres e-mail lub pozostaw puste';

  @override
  String get feedbackStep4EmailInvalidEmail =>
      'Adres nie wygląda na prawidłowy. Możesz zostawić pole puste.';

  @override
  String get feedbackStep4EmailInputHint => 'mail@example.com';

  @override
  String get feedbackStep6SubmitTitle => 'Wyślij opinię';

  @override
  String get feedbackStep6SubmitBreadcrumbTitle => 'Wyślij';

  @override
  String get feedbackStep6SubmitDescription =>
      'Sprawdź, czy wszystko się zgadza.\nW każdej chwili możesz wrócić do poprzedniego kroku, by poprawić zgłoszenie.';

  @override
  String get feedbackStep6SubmitSubmitButton => 'Wyślij';

  @override
  String get feedbackStep6SubmitSubmitShowDetailsButton => 'Pokaż szczegóły';

  @override
  String get feedbackStep6SubmitSubmitHideDetailsButton => 'Ukryj szczegóły';

  @override
  String get feedbackStep6SubmitSubmitDetailsTitle => 'Szczegóły opinii';

  @override
  String get feedbackStep7SubmissionInFlightMessage => 'Wysyłanie opinii';

  @override
  String get feedbackStep7SubmissionSuccessMessage =>
      'Dziękujemy za przesłanie opinii!';

  @override
  String get feedbackStep7SubmissionErrorMessage =>
      'Nie udało się wysłać opinii';

  @override
  String get feedbackStep7SubmissionOpenErrorButton =>
      'Kliknij, by zobaczyć szczegóły';

  @override
  String get feedbackStep7SubmissionRetryButton => 'Ponów';

  @override
  String feedbackStepXOfY(int current, int total) {
    return 'Krok $current z $total';
  }

  @override
  String get feedbackDiscardButton => 'Odrzuć zgłoszenie';

  @override
  String get feedbackDiscardConfirmButton => 'Na pewno? Odrzuć!';

  @override
  String get feedbackNextButton => 'Dalej';

  @override
  String get feedbackBackButton => 'Wstecz';

  @override
  String get feedbackCloseButton => 'Zamknij';

  @override
  String get backdropReturnToApp => 'Wróć do aplikacji';
}
