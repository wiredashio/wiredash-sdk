import 'wiredash_localizations.g.dart';

/// The translations for Italian (`it`).
class WiredashLocalizationsIt extends WiredashLocalizations {
  WiredashLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get feedbackStep1MessageTitle => 'Inviaci il tuo feedback';

  @override
  String get feedbackStep1MessageBreadcrumbTitle => 'Componi il messaggio';

  @override
  String get feedbackStep1MessageDescription =>
      'Aggiungi una breve descrizione di ciò che hai riscontrato';

  @override
  String get feedbackStep1MessageHint =>
      'Si verificato un errore sconosciuto quando provo a cambiare il mio avatar...';

  @override
  String get feedbackStep1MessageErrorMissingMessage =>
      'Per favore aggiungi un messaggio';

  @override
  String get feedbackStep2LabelsTitle =>
      'Quale label rappresenta al meglio il tuo feedback?';

  @override
  String get feedbackStep2LabelsBreadcrumbTitle => 'Label';

  @override
  String get feedbackStep2LabelsDescription =>
      'Selezionando la giusta categoria ci aiuterai a identificare il problema e a indirizzare il tuo feedback alle parti interessate';

  @override
  String get feedbackStep3ScreenshotOverviewTitle =>
      'Vuoi aggiungere uno screenshot per contestualizzare meglio?';

  @override
  String get feedbackStep3ScreenshotOverviewBreadcrumbTitle => 'Screenshot';

  @override
  String get feedbackStep3ScreenshotOverviewDescription =>
      'Potrai navigare nell\'app e scegliere quando acquisire uno screenshot';

  @override
  String get feedbackStep3ScreenshotOverviewSkipButton => 'Salta';

  @override
  String get feedbackStep3ScreenshotOverviewAddScreenshotButton =>
      'Aggiungi screenshot';

  @override
  String get feedbackStep3ScreenshotBarNavigateTitle => 'Fai uno screenshot';

  @override
  String get feedbackStep3ScreenshotBottomBarTitle =>
      'Includi uno screenshot per contestualizzare meglio';

  @override
  String get feedbackStep3ScreenshotBarDrawTitle =>
      'Disegna sullo schermo per evidenziare';

  @override
  String get feedbackStep3ScreenshotBarDrawUndoButton => 'Undo';

  @override
  String get feedbackStep3ScreenshotBarCaptureButton => 'Cattura';

  @override
  String get feedbackStep3ScreenshotBarSaveButton => 'Salva';

  @override
  String get feedbackStep3ScreenshotBarOkButton => 'Ok';

  @override
  String get feedbackStep3GalleryTitle => 'Screenshot allegati';

  @override
  String get feedbackStep3GalleryBreadcrumbTitle => 'Screenshot';

  @override
  String get feedbackStep3GalleryDescription =>
      'Puoi aggiungere altri screenshot per aiutarci a comprendere meglio il tuo problema.';

  @override
  String get feedbackStep4EmailTitle =>
      'Ricevi aggiornamenti via email riguardo il problema riscontrato';

  @override
  String get feedbackStep4EmailBreadcrumbTitle => 'Contato';

  @override
  String get feedbackStep4EmailDescription =>
      'Opzionalmente aggiungi il tuo indirizzo email qui sotto';

  @override
  String get feedbackStep4EmailInvalidEmail =>
      'Questo non sembra un indirizzo email valido. Puoi lasciarlo vuoto.';

  @override
  String get feedbackStep4EmailInputHint => 'mail@esempio.com';

  @override
  String get feedbackStep6SubmitTitle => 'Invia feedback';

  @override
  String get feedbackStep6SubmitBreadcrumbTitle => 'Invia';

  @override
  String get feedbackStep6SubmitDescription =>
      'Si prega di rivedere tutte le informazioni prima dell\'invio.\nPuoi tornare indietro per modificare il tuo feedback in qualsiasi momento.';

  @override
  String get feedbackStep6SubmitSubmitButton => 'Invia';

  @override
  String get feedbackStep6SubmitSubmitShowDetailsButton => 'Mostra dettagli';

  @override
  String get feedbackStep6SubmitSubmitHideDetailsButton => 'Nascondi dettagli';

  @override
  String get feedbackStep6SubmitSubmitDetailsTitle => 'Dettagli feedback';

  @override
  String get feedbackStep7SubmissionInFlightMessage => 'Invio del tuo feedback';

  @override
  String get feedbackStep7SubmissionSuccessMessage =>
      'Grazie per il tuo feedback!';

  @override
  String get feedbackStep7SubmissionErrorMessage =>
      'Invio del feedback non riuscito';

  @override
  String get feedbackStep7SubmissionOpenErrorButton =>
      'Fai clic per visualizzare i dettagli dell\'errore';

  @override
  String get feedbackStep7SubmissionRetryButton => 'Riprova';

  @override
  String feedbackStepXOfY(int current, int total) {
    return 'Passo $current di $total';
  }

  @override
  String get feedbackDiscardButton => 'Annulla il feedback';

  @override
  String get feedbackDiscardConfirmButton => 'Sei sicuro? Annullo!';

  @override
  String get feedbackNextButton => 'Avanti';

  @override
  String get feedbackBackButton => 'Indietro';

  @override
  String get feedbackCloseButton => 'Chiudi';

  @override
  String get promoterScoreStep1Question =>
      'Quanto è probabile che tu ci consigli?';

  @override
  String get promoterScoreStep1Description =>
      '0 = Non molto, 10 = Molto probabile';

  @override
  String get promoterScoreStep2MessageTitle =>
      'Quanto è probabile che ci raccomanderesti ai tuoi amici e familiari?';

  @override
  String promoterScoreStep2MessageDescription(int rating) {
    return 'Potresti dirci qualcosa in più sul motivo per cui hai scelto $rating? Questo passaggio è facoltativo.';
  }

  @override
  String get promoterScoreStep2MessageHint =>
      'Sarebbe fantastico se si potesse migliorare...';

  @override
  String get promoterScoreStep3ThanksMessagePromoters =>
      'Grazie per la tua valutazione!';

  @override
  String get promoterScoreStep3ThanksMessagePassives =>
      'Grazie per la tua valutazione!';

  @override
  String get promoterScoreStep3ThanksMessageDetractors =>
      'Grazie per la tua valutazione!';

  @override
  String get promoterScoreNextButton => 'Avanti';

  @override
  String get promoterScoreBackButton => 'Indietro';

  @override
  String get promoterScoreSubmitButton => 'Invia';

  @override
  String get backdropReturnToApp => 'Ritorna all\'app';
}
