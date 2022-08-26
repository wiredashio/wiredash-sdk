import 'wiredash_localizations.g.dart';

/// The translations for Hungarian (`hu`).
class WiredashLocalizationsHu extends WiredashLocalizations {
  WiredashLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get feedbackStep1MessageTitle => 'Mondd el a véleményed';

  @override
  String get feedbackStep1MessageBreadcrumbTitle => 'Fogalmazd meg az üzeneted';

  @override
  String get feedbackStep1MessageDescription =>
      'Írd le röviden hogy mit tapasztaltál';

  @override
  String get feedbackStep1MessageHint =>
      'Amikor megpróbálom megváltoztatni a profilképemet hiba lép fel...';

  @override
  String get feedbackStep1MessageErrorMissingMessage =>
      'Kérlek írj egy üzenetet';

  @override
  String get feedbackStep2LabelsTitle =>
      'Melyik címke jellemzi legjobban a visszajelzést?';

  @override
  String get feedbackStep2LabelsBreadcrumbTitle => 'Címkék';

  @override
  String get feedbackStep2LabelsDescription =>
      'A megfelelő kategória kiválasztásával segítesz azonosítani a hibát és eljuttatni az üzenetedet az alkalmas személyhez';

  @override
  String get feedbackStep3ScreenshotOverviewTitle =>
      'Csatolj képernyőképeket jobb tájékoztatás érdekében?';

  @override
  String get feedbackStep3ScreenshotOverviewBreadcrumbTitle => 'Képernyőképek';

  @override
  String get feedbackStep3ScreenshotOverviewDescription =>
      'Navigálhatsz az alkalmazásban, eldöntheted mikor készítesz képernyőképet';

  @override
  String get feedbackStep3ScreenshotOverviewSkipButton => 'Átugrás';

  @override
  String get feedbackStep3ScreenshotOverviewAddScreenshotButton =>
      'Képernyőkép csatolása';

  @override
  String get feedbackStep3ScreenshotBarNavigateTitle => 'Készíts képernyőképet';

  @override
  String get feedbackStep3ScreenshotBarDrawTitle =>
      'Rajzolj a képernyőre hogy emeld ki a lényeget';

  @override
  String get feedbackStep3ScreenshotBarDrawUndoButton => 'Visszavonás';

  @override
  String get feedbackStep3ScreenshotBarCaptureButton => 'Rögzítés';

  @override
  String get feedbackStep3ScreenshotBarSaveButton => 'Mentés';

  @override
  String get feedbackStep3ScreenshotBarOkButton => 'OK';

  @override
  String get feedbackStep3GalleryTitle => 'Csatolt képernyőképek';

  @override
  String get feedbackStep3GalleryBreadcrumbTitle => 'Képernyőképek';

  @override
  String get feedbackStep3GalleryDescription =>
      'Adj hozzá több képernyőképet hogy jobban megérthessük a hibát.';

  @override
  String get feedbackStep4EmailTitle => 'Kapj e-mail értesítéseket a hibáról';

  @override
  String get feedbackStep4EmailBreadcrumbTitle => 'Kapcsolat';

  @override
  String get feedbackStep4EmailDescription =>
      'Add meg az e-mail címed vagy hagyd üresen';

  @override
  String get feedbackStep4EmailInvalidEmail =>
      'Nem tűnik érvényes e-mail címnek. Üresen hagyhatod.';

  @override
  String get feedbackStep4EmailInputHint => 'postafiok@pelda.hu';

  @override
  String get feedbackStep6SubmitTitle => 'Visszajelzés elküldése';

  @override
  String get feedbackStep6SubmitBreadcrumbTitle => 'Elküldés';

  @override
  String get feedbackStep6SubmitDescription =>
      'Kérlek nézz át minden információt beküldés előtt.\nBármikor visszamehetsz és módosíthatod a visszajelzést.';

  @override
  String get feedbackStep6SubmitSubmitButton => 'Elküldés';

  @override
  String get feedbackStep6SubmitSubmitShowDetailsButton =>
      'Részletek megtekintése';

  @override
  String get feedbackStep6SubmitSubmitHideDetailsButton =>
      'Részletek elrejtése';

  @override
  String get feedbackStep6SubmitSubmitDetailsTitle =>
      'A visszajelzés részletei';

  @override
  String get feedbackStep7SubmissionInFlightMessage =>
      'Visszajelzés küldése folyamatban';

  @override
  String get feedbackStep7SubmissionSuccessMessage =>
      'Köszönjük a visszajelzést!';

  @override
  String get feedbackStep7SubmissionErrorMessage =>
      'Hiba történt a visszajelzés küldése során';

  @override
  String get feedbackStep7SubmissionOpenErrorButton =>
      'Kattints ide hogy megtekintsd a hibát';

  @override
  String get feedbackStep7SubmissionRetryButton => 'Próbáld újra';

  @override
  String feedbackStepXOfY(int current, int total) {
    return '$current/$total. lépés';
  }

  @override
  String get feedbackDiscardButton => 'Visszajelzés törlése';

  @override
  String get feedbackDiscardConfirmButton => 'Biztos? Törlés!';

  @override
  String get feedbackNextButton => 'Következő';

  @override
  String get feedbackBackButton => 'Vissza';

  @override
  String get feedbackCloseButton => 'Bezárás';

  @override
  String get promoterScoreStep1Question =>
      'Mennyire valószínű hogy ajnálani fogsz minket?';

  @override
  String get promoterScoreStep1Description =>
      '0 = Nem valószínű, 10 = Nagyon valószínű';

  @override
  String get promoterScoreStep2MessageTitle =>
      'Mennyire valószínű hogy ajánlani fogsz minket a családodnak és barátaidnak?';

  @override
  String promoterScoreStep2MessageDescription(int rating) {
    return 'Mesélnél egy kicsit arról, hogy miért választottál $rating-t? Ez a lépés nem kötelező.';
  }

  @override
  String get promoterScoreStep2MessageHint => 'Jó lenne ha javítanátok...';

  @override
  String get promoterScoreStep3ThanksMessagePromoters =>
      'Köszönjük az értékelést!';

  @override
  String get promoterScoreStep3ThanksMessagePassives =>
      'Köszönjük az értékelést!';

  @override
  String get promoterScoreStep3ThanksMessageDetractors =>
      'Köszönjük az értékelést!';

  @override
  String get promoterScoreNextButton => 'Következő';

  @override
  String get promoterScoreBackButton => 'Vissza';

  @override
  String get promoterScoreSubmitButton => 'Elküldés';

  @override
  String get backdropReturnToApp => 'Vissza az appba';
}
