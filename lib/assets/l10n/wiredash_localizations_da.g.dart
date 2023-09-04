import 'wiredash_localizations.g.dart';

/// The translations for Danish (`da`).
class WiredashLocalizationsDa extends WiredashLocalizations {
  WiredashLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get feedbackStep1MessageTitle => 'Send os din feedback';

  @override
  String get feedbackStep1MessageBreadcrumbTitle => 'Skriv besked';

  @override
  String get feedbackStep1MessageDescription =>
      'Tilføj en kort beskrivelse af, hvad du stødte på';

  @override
  String get feedbackStep1MessageHint =>
      'Der er en ukendt fejl, når jeg prøver at ændre min avatar...';

  @override
  String get feedbackStep1MessageErrorMissingMessage =>
      'Tilføj venligst en besked';

  @override
  String get feedbackStep2LabelsTitle =>
      'Hvilken etiket repræsenterer bedst din feedback?';

  @override
  String get feedbackStep2LabelsBreadcrumbTitle => 'Etiketter';

  @override
  String get feedbackStep2LabelsDescription =>
      'At vælge den rigtige kategori hjælper os med at identificere problemet og sende din feedback til den rigtige interessent';

  @override
  String get feedbackStep3ScreenshotOverviewTitle =>
      'Tilføj skærmbilleder for bedre kontekst?';

  @override
  String get feedbackStep3ScreenshotOverviewBreadcrumbTitle => 'Skærmbilleder';

  @override
  String get feedbackStep3ScreenshotOverviewDescription =>
      'Du vil være i stand til at navigere i appen og vælge, hvornår du vil tage et skærmbillede';

  @override
  String get feedbackStep3ScreenshotOverviewSkipButton => 'Næste';

  @override
  String get feedbackStep3ScreenshotOverviewAddScreenshotButton =>
      'Tilføj skærmbillede';

  @override
  String get feedbackStep3ScreenshotBarNavigateTitle => 'Tag et skærmbillede';

  @override
  String get feedbackStep3ScreenshotBottomBarTitle =>
      'Include a screenshot for more context';

  @override
  String get feedbackStep3ScreenshotBarDrawTitle =>
      'Tegn på skærmen for at tilføje højdepunkter';

  @override
  String get feedbackStep3ScreenshotBarDrawUndoButton => 'Fortryd';

  @override
  String get feedbackStep3ScreenshotBarCaptureButton => 'Tag skærmkopi';

  @override
  String get feedbackStep3ScreenshotBarSaveButton => 'Gem';

  @override
  String get feedbackStep3ScreenshotBarOkButton => 'Ok';

  @override
  String get feedbackStep3GalleryTitle => 'Vedhæftede skærmbilleder';

  @override
  String get feedbackStep3GalleryBreadcrumbTitle => 'Skærmbilleder';

  @override
  String get feedbackStep3GalleryDescription =>
      'Du kan tilføje flere skærmbilleder for bedre at hjælpe os med at forstå dit problem.';

  @override
  String get feedbackStep4EmailTitle => 'Få e-mailopdateringer om dit problem';

  @override
  String get feedbackStep4EmailBreadcrumbTitle => 'Kontakt';

  @override
  String get feedbackStep4EmailDescription =>
      'Tilføj din e-mailadresse nedenfor, eller udelad den';

  @override
  String get feedbackStep4EmailInvalidEmail =>
      'Dette ligner ikke en gyldig e-mailadresse. Du kan lade den stå tom.';

  @override
  String get feedbackStep4EmailInputHint => 'mail@eksempel.dk';

  @override
  String get feedbackStep6SubmitTitle => 'Send feedback';

  @override
  String get feedbackStep6SubmitBreadcrumbTitle => 'Indsend';

  @override
  String get feedbackStep6SubmitDescription =>
      'Gennemgå venligst alle oplysninger før indsendelse.\nDu kan til enhver tid navigere tilbage for at justere din feedback.';

  @override
  String get feedbackStep6SubmitSubmitButton => 'Indsend';

  @override
  String get feedbackStep6SubmitSubmitShowDetailsButton => 'Vis detaljer';

  @override
  String get feedbackStep6SubmitSubmitHideDetailsButton => 'Skjul detaljer';

  @override
  String get feedbackStep6SubmitSubmitDetailsTitle => 'Feedback detaljer';

  @override
  String get feedbackStep7SubmissionInFlightMessage => 'Indsender din feedback';

  @override
  String get feedbackStep7SubmissionSuccessMessage =>
      'Tak for din tilbagemelding!';

  @override
  String get feedbackStep7SubmissionErrorMessage =>
      'Feedbackindsendelse mislykkedes';

  @override
  String get feedbackStep7SubmissionOpenErrorButton =>
      'Klik for at se fejloplysninger';

  @override
  String get feedbackStep7SubmissionRetryButton => 'Prøv igen';

  @override
  String feedbackStepXOfY(int current, int total) {
    return 'Trin $current af $total';
  }

  @override
  String get feedbackDiscardButton => 'Kassér feedback';

  @override
  String get feedbackDiscardConfirmButton => 'Sikker på du ønsker at Kassér?';

  @override
  String get feedbackNextButton => 'Næste';

  @override
  String get feedbackBackButton => 'Tilbage';

  @override
  String get feedbackCloseButton => 'Luk';

  @override
  String get promoterScoreStep1Question =>
      'Hvor sandsynligt er det, at du vil anbefale os?';

  @override
  String get promoterScoreStep1Description =>
      '0 = Ikke sandsynligt, 10 = Højst sandsynlig';

  @override
  String get promoterScoreStep2MessageTitle =>
      'Hvor sandsynligt er det, at du vil anbefale os til dine venner og familie?';

  @override
  String promoterScoreStep2MessageDescription(int rating) {
    return 'Kan du fortælle os lidt mere om, hvorfor du valgte $rating? Dette trin er valgfrit.';
  }

  @override
  String get promoterScoreStep2MessageHint =>
      'Det ville være dejligt, hvis i kunne forbedre...';

  @override
  String get promoterScoreStep3ThanksMessagePromoters =>
      'Tak for din vurdering!';

  @override
  String get promoterScoreStep3ThanksMessagePassives =>
      'Thanks for your rating!';

  @override
  String get promoterScoreStep3ThanksMessageDetractors =>
      'Tak for din vurdering!';

  @override
  String get promoterScoreNextButton => 'Næste';

  @override
  String get promoterScoreBackButton => 'Tilbage';

  @override
  String get promoterScoreSubmitButton => 'Indsend';

  @override
  String get backdropReturnToApp => 'Vend tilbage til app';
}
