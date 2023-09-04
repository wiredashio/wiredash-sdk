import 'wiredash_localizations.g.dart';

/// The translations for Czech (`cs`).
class WiredashLocalizationsCs extends WiredashLocalizations {
  WiredashLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get feedbackStep1MessageTitle => 'Pošlete nám svůj názor';

  @override
  String get feedbackStep1MessageBreadcrumbTitle => 'Sestavení zprávy';

  @override
  String get feedbackStep1MessageDescription =>
      'Přidejte krátký popis toho, s čím jste se setkali';

  @override
  String get feedbackStep1MessageHint =>
      'Při pokusu o změnu avataru se objeví neznámá chyba...';

  @override
  String get feedbackStep1MessageErrorMissingMessage =>
      'Přidejte prosím zprávu';

  @override
  String get feedbackStep2LabelsTitle =>
      'Které označení nejlépe vystihuje vaši zpětnou vazbu?';

  @override
  String get feedbackStep2LabelsBreadcrumbTitle => 'Štítky';

  @override
  String get feedbackStep2LabelsDescription =>
      'Výběr správné kategorie nám pomůže identifikovat problém a předat vaši zpětnou vazbu správné zainteresované straně.';

  @override
  String get feedbackStep3ScreenshotOverviewTitle =>
      'Přidat snímky obrazovky pro lepší kontext?';

  @override
  String get feedbackStep3ScreenshotOverviewBreadcrumbTitle =>
      'Snímky obrazovky';

  @override
  String get feedbackStep3ScreenshotOverviewDescription =>
      'Budete moci procházet aplikací a vybrat si, kdy chcete pořídit snímek obrazovky.';

  @override
  String get feedbackStep3ScreenshotOverviewSkipButton => 'Přeskočit';

  @override
  String get feedbackStep3ScreenshotOverviewAddScreenshotButton =>
      'Přidat snímek obrazovky';

  @override
  String get feedbackStep3ScreenshotBarNavigateTitle =>
      'Pořiďte snímek obrazovky';

  @override
  String get feedbackStep3ScreenshotBottomBarTitle =>
      'Include a screenshot for more context';

  @override
  String get feedbackStep3ScreenshotBarDrawTitle =>
      'Kreslení na obrazovce pro přidání zvýraznění';

  @override
  String get feedbackStep3ScreenshotBarDrawUndoButton => 'Zrušit';

  @override
  String get feedbackStep3ScreenshotBarCaptureButton => 'Zachycení';

  @override
  String get feedbackStep3ScreenshotBarSaveButton => 'Uložit';

  @override
  String get feedbackStep3ScreenshotBarOkButton => 'Ok';

  @override
  String get feedbackStep3GalleryTitle => 'Přiložené snímky obrazovky';

  @override
  String get feedbackStep3GalleryBreadcrumbTitle => 'Snímky obrazovky';

  @override
  String get feedbackStep3GalleryDescription =>
      'Můžete přidat další snímky obrazovky, které nám pomohou ještě lépe pochopit váš problém.';

  @override
  String get feedbackStep4EmailTitle =>
      'Získávání e-mailových aktualizací o vašem problému';

  @override
  String get feedbackStep4EmailBreadcrumbTitle => 'Kontakt';

  @override
  String get feedbackStep4EmailDescription =>
      'Níže přidejte svou e-mailovou adresu nebo ji nechte prázdnou';

  @override
  String get feedbackStep4EmailInvalidEmail =>
      'Nevypadá to jako platná e-mailová adresa. Můžete ji nechat prázdnou.';

  @override
  String get feedbackStep4EmailInputHint => 'mail@example.com';

  @override
  String get feedbackStep6SubmitTitle => 'Odeslat zpětnou vazbu';

  @override
  String get feedbackStep6SubmitBreadcrumbTitle => 'Odeslat';

  @override
  String get feedbackStep6SubmitDescription =>
      'Před odesláním si prosím zkontrolujte všechny informace.\nKdykoli se můžete vrátit a upravit svoji zpětnou vazbu.';

  @override
  String get feedbackStep6SubmitSubmitButton => 'Odeslat';

  @override
  String get feedbackStep6SubmitSubmitShowDetailsButton =>
      'Zobrazit podrobnosti';

  @override
  String get feedbackStep6SubmitSubmitHideDetailsButton => 'Skrýt podrobnosti';

  @override
  String get feedbackStep6SubmitSubmitDetailsTitle =>
      'Podrobnosti o zpětné vazbě';

  @override
  String get feedbackStep7SubmissionInFlightMessage => 'Odeslání zpětné vazby';

  @override
  String get feedbackStep7SubmissionSuccessMessage =>
      'Děkujeme za vaši zpětnou vazbu!';

  @override
  String get feedbackStep7SubmissionErrorMessage =>
      'Odeslání zpětné vazby se nezdařilo';

  @override
  String get feedbackStep7SubmissionOpenErrorButton =>
      'Kliknutím zobrazíte podrobnosti o chybě';

  @override
  String get feedbackStep7SubmissionRetryButton => 'Opakování';

  @override
  String feedbackStepXOfY(int current, int total) {
    return 'Krok $current z $total';
  }

  @override
  String get feedbackDiscardButton => 'Vyřazení zpětné vazby';

  @override
  String get feedbackDiscardConfirmButton => 'Opravdu? Vyhodit!';

  @override
  String get feedbackNextButton => 'Další';

  @override
  String get feedbackBackButton => 'Zpět';

  @override
  String get feedbackCloseButton => 'Zavřít';

  @override
  String get promoterScoreStep1Question =>
      'Jaká je pravděpodobnost, že nás doporučíte?';

  @override
  String get promoterScoreStep1Description =>
      '0 = nepravděpodobné, 10 = velmi pravděpodobné';

  @override
  String get promoterScoreStep2MessageTitle =>
      'Jaká je pravděpodobnost, že nás doporučíte svým přátelům a rodině?';

  @override
  String promoterScoreStep2MessageDescription(int rating) {
    return 'Mohl byste nám říct něco víc o tom, proč jste si vybral $rating? Tento krok je nepovinný.';
  }

  @override
  String get promoterScoreStep2MessageHint =>
      'Bylo by skvělé, kdybyste mohli vylepšit...';

  @override
  String get promoterScoreStep3ThanksMessagePromoters =>
      'Děkujeme za vaše hodnocení!';

  @override
  String get promoterScoreStep3ThanksMessagePassives =>
      'Děkujeme za vaše hodnocení!';

  @override
  String get promoterScoreStep3ThanksMessageDetractors =>
      'Děkujeme za vaše hodnocení!';

  @override
  String get promoterScoreNextButton => 'Další';

  @override
  String get promoterScoreBackButton => 'Zpět';

  @override
  String get promoterScoreSubmitButton => 'Odeslat';

  @override
  String get backdropReturnToApp => 'Zpět na aplikaci';
}
