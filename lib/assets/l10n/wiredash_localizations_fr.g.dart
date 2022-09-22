import 'wiredash_localizations.g.dart';

/// The translations for French (`fr`).
class WiredashLocalizationsFr extends WiredashLocalizations {
  WiredashLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get feedbackStep1MessageTitle => 'Envoyer des commentaires';

  @override
  String get feedbackStep1MessageBreadcrumbTitle => 'Votre message';

  @override
  String get feedbackStep1MessageDescription =>
      'Décrivez brièvement ce que vous avez constaté';

  @override
  String get feedbackStep1MessageHint =>
      'Il y a un message d\'erreur quand j\'essaie de changer mon avatar...';

  @override
  String get feedbackStep1MessageErrorMissingMessage =>
      'Merci de détailler la requête';

  @override
  String get feedbackStep2LabelsTitle =>
      'Quel tag décrit le mieux votre commentaire ?';

  @override
  String get feedbackStep2LabelsBreadcrumbTitle => 'Tags';

  @override
  String get feedbackStep2LabelsDescription =>
      'Choisir la bonne catégorie aidera à l\'analyse et au routage de la demande';

  @override
  String get feedbackStep3ScreenshotOverviewTitle =>
      'Voulez-vous ajouter une capture d\'écran pour aider à la résolution ?';

  @override
  String get feedbackStep3ScreenshotOverviewBreadcrumbTitle =>
      'Captures d\'écran';

  @override
  String get feedbackStep3ScreenshotOverviewDescription =>
      'Vous pourrez naviguer dans l\'application et choisir l\'écran à capturer';

  @override
  String get feedbackStep3ScreenshotOverviewSkipButton => 'Passer';

  @override
  String get feedbackStep3ScreenshotOverviewAddScreenshotButton =>
      'Capturer l\'écran';

  @override
  String get feedbackStep3ScreenshotBarNavigateTitle =>
      'Prendre une capture d\'écran';

  @override
  String get feedbackStep3ScreenshotBarDrawTitle =>
      'Dessiner sur l\'écran pour en mettre en avant une partie';

  @override
  String get feedbackStep3ScreenshotBarDrawUndoButton => 'Annuler';

  @override
  String get feedbackStep3ScreenshotBarCaptureButton => 'Capturer';

  @override
  String get feedbackStep3ScreenshotBarSaveButton => 'Sauvegarder';

  @override
  String get feedbackStep3ScreenshotBarOkButton => 'Ok';

  @override
  String get feedbackStep3GalleryTitle => 'Captures d\'écran jointes';

  @override
  String get feedbackStep3GalleryBreadcrumbTitle => 'Captures d\'écran';

  @override
  String get feedbackStep3GalleryDescription =>
      'Vous pouvez ajouter d\'autres captures pour nous aider à comprendre plus précisément la requête.';

  @override
  String get feedbackStep4EmailTitle =>
      'Recevoir un e-mail de suivi de votre commentaire';

  @override
  String get feedbackStep4EmailBreadcrumbTitle => 'Contact';

  @override
  String get feedbackStep4EmailDescription =>
      'Ajoutez votre adresse e-mail ci-dessous ou laissez le champ vide';

  @override
  String get feedbackStep4EmailInvalidEmail =>
      'Cette adresse e-mail n\'est pas valide. Vous pouvez aussi laisser ce champ vide.';

  @override
  String get feedbackStep4EmailInputHint => 'mon_nom@mail.fr';

  @override
  String get feedbackStep6SubmitTitle => 'Envoyer les commentaires';

  @override
  String get feedbackStep6SubmitBreadcrumbTitle => 'Envoyer';

  @override
  String get feedbackStep6SubmitDescription =>
      'Merci de vérifier les informations avant l\'envoi.\nVous pouvez revenir en arrière pour ajuster si besoin.';

  @override
  String get feedbackStep6SubmitSubmitButton => 'Envoyer';

  @override
  String get feedbackStep6SubmitSubmitShowDetailsButton =>
      'Afficher les détails';

  @override
  String get feedbackStep6SubmitSubmitHideDetailsButton => 'Cacher les détails';

  @override
  String get feedbackStep6SubmitSubmitDetailsTitle =>
      'Détails des commentaires';

  @override
  String get feedbackStep7SubmissionInFlightMessage =>
      'Envoi en cours de vos commentaires';

  @override
  String get feedbackStep7SubmissionSuccessMessage =>
      'Merci pour vos commentaires !';

  @override
  String get feedbackStep7SubmissionErrorMessage =>
      'L\'envoi des commentaires a échoué';

  @override
  String get feedbackStep7SubmissionOpenErrorButton =>
      'Cliquer ici pour voir le détail de l\'erreur';

  @override
  String get feedbackStep7SubmissionRetryButton => 'Réessayer';

  @override
  String feedbackStepXOfY(int current, int total) {
    return 'Etape $current sur $total';
  }

  @override
  String get feedbackDiscardButton => 'Annuler';

  @override
  String get feedbackDiscardConfirmButton => 'Annuler, vraiment ?';

  @override
  String get feedbackNextButton => 'Suivant';

  @override
  String get feedbackBackButton => 'Précédent';

  @override
  String get feedbackCloseButton => 'Fermer';

  @override
  String get promoterScoreStep1Question =>
      'Est-ce que vous recommanderiez l\'application ?';

  @override
  String get promoterScoreStep1Description =>
      '0 = Peu probable, 10 = Très probable';

  @override
  String get promoterScoreStep2MessageTitle =>
      'Quelle est la probabilité que vous nous recommandiez à vos amis ou à votre famille ?';

  @override
  String promoterScoreStep2MessageDescription(int rating) {
    return 'Pouvez-vous nous en dire plus sur le choix de ce score ? (optionnel)';
  }

  @override
  String get promoterScoreStep2MessageHint =>
      'Il serait génial de pouvoir améliorer ...';

  @override
  String get promoterScoreStep3ThanksMessagePromoters =>
      'Merci pour votre évalution !';

  @override
  String get promoterScoreStep3ThanksMessagePassives =>
      'Merci pour votre évalution !';

  @override
  String get promoterScoreStep3ThanksMessageDetractors =>
      'Merci pour votre évalution !';

  @override
  String get promoterScoreNextButton => 'Suivant';

  @override
  String get promoterScoreBackButton => 'Précédent';

  @override
  String get promoterScoreSubmitButton => 'Envoyer';

  @override
  String get backdropReturnToApp => 'Retourner dans l\'application';
}
