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
  String get npsStep1Question => 'How likely are you to recommend us?';

  @override
  String get npsStep1Description => '0 = Not likely, 10 = most likely';

  @override
  String get npsStep2MessageTitle =>
      'How likely are you to recommend us to your friends and family?';

  @override
  String npsStep2MessageDescription(int rating) {
    return 'Could you tell us a bit more about why you chose $rating. This step is optional.';
  }

  @override
  String get npsStep2MessageHint => 'It would be great if you could improve...';

  @override
  String get npsStep3ThanksMessagePromoters => 'Thanks for your rating!';

  @override
  String get npsStep3ThanksMessagePassives => 'Thanks for your rating!';

  @override
  String get npsStep3ThanksMessageDetractors => 'Thanks for your rating!';

  @override
  String get npsNextButton => 'Next';

  @override
  String get npsBackButton => 'Back';

  @override
  String get npsSubmitButton => 'Submit';

  @override
  String get backdropReturnToApp => 'Wróć do aplikacji';
}
