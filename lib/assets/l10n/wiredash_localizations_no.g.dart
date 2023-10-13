import 'wiredash_localizations.g.dart';

/// The translations for Norwegian (`no`).
class WiredashLocalizationsNo extends WiredashLocalizations {
  WiredashLocalizationsNo([String locale = 'no']) : super(locale);

  @override
  String get feedbackStep1MessageTitle => 'Send oss tilbakemeldingen din';

  @override
  String get feedbackStep1MessageBreadcrumbTitle => 'Skriv melding';

  @override
  String get feedbackStep1MessageDescription =>
      'Legg til en kort beskrivelse av hva du opplevde';

  @override
  String get feedbackStep1MessageHint =>
      'Det er en ukjent feil når jeg prøver å endre avataren min...';

  @override
  String get feedbackStep1MessageErrorMissingMessage =>
      'Vennligst legg til en melding';

  @override
  String get feedbackStep2LabelsTitle =>
      'Hvilken etikett representerer best tilbakemeldingen din?';

  @override
  String get feedbackStep2LabelsBreadcrumbTitle => 'Etiketter';

  @override
  String get feedbackStep2LabelsDescription =>
      'Å velge riktig kategori hjelper oss med å identifisere problemet og sende tilbakemeldingen din til riktig person';

  @override
  String get feedbackStep3ScreenshotOverviewTitle =>
      'Legge til skjermbilder for å vise bedre?';

  @override
  String get feedbackStep3ScreenshotOverviewBreadcrumbTitle => 'Skjermbilder';

  @override
  String get feedbackStep3ScreenshotOverviewDescription =>
      'Du vil kunne navigere i appen og velge når du skal ta et skjermbilde';

  @override
  String get feedbackStep3ScreenshotOverviewSkipButton => 'Hopp over';

  @override
  String get feedbackStep3ScreenshotOverviewAddScreenshotButton =>
      'Legg til skjermbilde';

  @override
  String get feedbackStep3ScreenshotBarNavigateTitle => 'Ta et skjermbilde';

  @override
  String get feedbackStep3ScreenshotBottomBarTitle =>
      'Inkluder et skjermbilde for mer kontekst';

  @override
  String get feedbackStep3ScreenshotBarDrawTitle =>
      'Tegn på skjermen for å legge til høydepunkter';

  @override
  String get feedbackStep3ScreenshotBarDrawUndoButton => 'Angre';

  @override
  String get feedbackStep3ScreenshotBarCaptureButton => 'Ta bilde';

  @override
  String get feedbackStep3ScreenshotBarSaveButton => 'Lagre';

  @override
  String get feedbackStep3ScreenshotBarOkButton => 'OK';

  @override
  String get feedbackStep3GalleryTitle => 'Vedlagte skjermbilder';

  @override
  String get feedbackStep3GalleryBreadcrumbTitle => 'Skjermbilder';

  @override
  String get feedbackStep3GalleryDescription =>
      'Du kan legge til flere skjermbilder for å hjelpe oss med å forstå problemet ditt enda bedre.';

  @override
  String get feedbackStep4EmailTitle => 'Vil du bli fulgt opp om dette?';

  @override
  String get feedbackStep4EmailBreadcrumbTitle => 'Kontakt';

  @override
  String get feedbackStep4EmailDescription =>
      'Legg til e-postadressen din dersom du ønsker å bli fulgt opp.';

  @override
  String get feedbackStep4EmailInvalidEmail =>
      'Dette ser ikke ut som en gyldig e-postadresse. Du kan la den være tom.';

  @override
  String get feedbackStep4EmailInputHint => 'mail@eksempel.com';

  @override
  String get feedbackStep6SubmitTitle => 'Send inn tilbakemelding';

  @override
  String get feedbackStep6SubmitBreadcrumbTitle => 'Send inn';

  @override
  String get feedbackStep6SubmitDescription =>
      'Vennligst gjennomgå all informasjon før innsending.\nDu kan navigere tilbake for å justere tilbakemeldingen din når som helst.';

  @override
  String get feedbackStep6SubmitSubmitButton => 'Send inn';

  @override
  String get feedbackStep6SubmitSubmitShowDetailsButton => 'Vis detaljer';

  @override
  String get feedbackStep6SubmitSubmitHideDetailsButton => 'Skjul detaljer';

  @override
  String get feedbackStep6SubmitSubmitDetailsTitle =>
      'Detaljer om tilbakemelding';

  @override
  String get feedbackStep7SubmissionInFlightMessage =>
      'Sender inn tilbakemeldingen din';

  @override
  String get feedbackStep7SubmissionSuccessMessage =>
      'Takk for tilbakemeldingen!';

  @override
  String get feedbackStep7SubmissionErrorMessage =>
      'Innsending av tilbakemelding mislyktes';

  @override
  String get feedbackStep7SubmissionOpenErrorButton =>
      'Klikk for å se detaljer';

  @override
  String get feedbackStep7SubmissionRetryButton => 'Prøv igjen';

  @override
  String feedbackStepXOfY(int current, int total) {
    return 'Trinn $current av $total';
  }

  @override
  String get feedbackDiscardButton => 'Avbryt';

  @override
  String get feedbackDiscardConfirmButton => 'Helt sikker?';

  @override
  String get feedbackNextButton => 'Neste';

  @override
  String get feedbackBackButton => 'Tilbake';

  @override
  String get feedbackCloseButton => 'Lukk';

  @override
  String get promoterScoreStep1Question =>
      'Hvor sannsynlig er det at du vil anbefale oss?';

  @override
  String get promoterScoreStep1Description =>
      '0 = Ikke sannsynlig, 10 = Mest sannsynlig';

  @override
  String get promoterScoreStep2MessageTitle =>
      'Hvor sannsynlig er det at du vil anbefale oss til andre?';

  @override
  String promoterScoreStep2MessageDescription(int rating) {
    return 'Kunne du fortelle oss litt mer om hvorfor du valgte $rating? Dette trinnet er valgfritt.';
  }

  @override
  String get promoterScoreStep2MessageHint =>
      'Det ville vært flott om dere kunne forbedre...';

  @override
  String get promoterScoreStep3ThanksMessagePromoters =>
      'Takk for vurderingen din!';

  @override
  String get promoterScoreStep3ThanksMessagePassives =>
      'Takk for vurderingen din!';

  @override
  String get promoterScoreStep3ThanksMessageDetractors =>
      'Takk for vurderingen din!';

  @override
  String get promoterScoreNextButton => 'Neste';

  @override
  String get promoterScoreBackButton => 'Tilbake';

  @override
  String get promoterScoreSubmitButton => 'Send inn';

  @override
  String get backdropReturnToApp => 'Returner til appen';
}
