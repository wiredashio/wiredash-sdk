import 'wiredash_localizations.g.dart';

/// The translations for Spanish Castilian (`es`).
class WiredashLocalizationsEs extends WiredashLocalizations {
  WiredashLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get feedbackStep1MessageTitle => 'Envíenos sus comentarios';

  @override
  String get feedbackStep1MessageBreadcrumbTitle => 'Redacta un mensaje';

  @override
  String get feedbackStep1MessageDescription =>
      'Escribe una pequeña descripción de lo que ha ocurrido';

  @override
  String get feedbackStep1MessageHint =>
      'Ocurre un error desconocido cuando trato de cambiar mi foto de perfil...';

  @override
  String get feedbackStep1MessageErrorMissingMessage =>
      'Por favor escriba un mensaje';

  @override
  String get feedbackStep2LabelsTitle =>
      '¿Qué etiqueta representa mejor tus comentarios?';

  @override
  String get feedbackStep2LabelsBreadcrumbTitle => 'Etiqueta';

  @override
  String get feedbackStep2LabelsDescription =>
      'Seleccionar la categoría correcta nos ayuda a identificar el problema y a enviar tus comentarios al equipo correcto';

  @override
  String get feedbackStep3ScreenshotOverviewTitle =>
      'Añade capturas de pantalla';

  @override
  String get feedbackStep3ScreenshotOverviewBreadcrumbTitle =>
      'Capturas de pantalla';

  @override
  String get feedbackStep3ScreenshotOverviewDescription =>
      'Podrás navegar por la aplicación y elegir cuándo hacer la captura de pantalla';

  @override
  String get feedbackStep3ScreenshotOverviewSkipButton => 'Omitir';

  @override
  String get feedbackStep3ScreenshotOverviewAddScreenshotButton =>
      'Hacer captura';

  @override
  String get feedbackStep3ScreenshotBarNavigateTitle =>
      'Haz una captura de pantalla';

  @override
  String get feedbackStep3ScreenshotBottomBarTitle =>
      'Include a screenshot for more context';

  @override
  String get feedbackStep3ScreenshotBarDrawTitle =>
      'Marca los detalles importantes';

  @override
  String get feedbackStep3ScreenshotBarDrawUndoButton => 'Deshacer';

  @override
  String get feedbackStep3ScreenshotBarCaptureButton => 'Capturar';

  @override
  String get feedbackStep3ScreenshotBarSaveButton => 'Guardar';

  @override
  String get feedbackStep3ScreenshotBarOkButton => 'Ok';

  @override
  String get feedbackStep3GalleryTitle => 'Capturas de pantalla adjuntas';

  @override
  String get feedbackStep3GalleryBreadcrumbTitle => 'Capturas de pantalla';

  @override
  String get feedbackStep3GalleryDescription =>
      'Añadir más capturas de pantalla nos ayuda a entender mejor el problema.';

  @override
  String get feedbackStep4EmailTitle =>
      'Reciba actualizaciones por correo electrónico';

  @override
  String get feedbackStep4EmailBreadcrumbTitle => 'Contacto';

  @override
  String get feedbackStep4EmailDescription =>
      'Agregue su dirección de correo electrónico para recibir acutalizaciones sobre tu caso o déjelo sin rellenar';

  @override
  String get feedbackStep4EmailInvalidEmail =>
      'Esto no parece una dirección de correo electrónico válida. Puedes dejarlo sin rellenar.';

  @override
  String get feedbackStep4EmailInputHint => 'mail@ejemplo.com';

  @override
  String get feedbackStep6SubmitTitle => 'Enviar sugerencias';

  @override
  String get feedbackStep6SubmitBreadcrumbTitle => 'Enviar';

  @override
  String get feedbackStep6SubmitDescription =>
      'Por favor, revise toda la información antes de enviarla.\nPuedes navegar hacia atrás para editar sus comentarios en cualquier momento.';

  @override
  String get feedbackStep6SubmitSubmitButton => 'Enviar';

  @override
  String get feedbackStep6SubmitSubmitShowDetailsButton => 'Mostrar detalles';

  @override
  String get feedbackStep6SubmitSubmitHideDetailsButton => 'Ocultar detalles';

  @override
  String get feedbackStep6SubmitSubmitDetailsTitle => 'Comentarios';

  @override
  String get feedbackStep7SubmissionInFlightMessage =>
      'Enviando tus sugerencias';

  @override
  String get feedbackStep7SubmissionSuccessMessage =>
      '¡Gracias por tus sugerencias!';

  @override
  String get feedbackStep7SubmissionErrorMessage =>
      'El envío de tus sugerencias ha fallado';

  @override
  String get feedbackStep7SubmissionOpenErrorButton =>
      'Pulsa para ver más detalles sobre el error';

  @override
  String get feedbackStep7SubmissionRetryButton => 'Reintentar';

  @override
  String feedbackStepXOfY(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get feedbackDiscardButton => 'Eliminar comentario';

  @override
  String get feedbackDiscardConfirmButton => '¿De verdad? ¡Elimínalo!';

  @override
  String get feedbackNextButton => 'Siguiente';

  @override
  String get feedbackBackButton => 'Atrás';

  @override
  String get feedbackCloseButton => 'Cerrar';

  @override
  String get promoterScoreStep1Question =>
      'How likely are you to recommend us?';

  @override
  String get promoterScoreStep1Description =>
      '0 = Not likely, 10 = Most likely';

  @override
  String get promoterScoreStep2MessageTitle =>
      'How likely are you to recommend us to your friends and family?';

  @override
  String promoterScoreStep2MessageDescription(int rating) {
    return 'Could you tell us a bit more about why you chose $rating? This step is optional.';
  }

  @override
  String get promoterScoreStep2MessageHint =>
      'It would be great if you could improve...';

  @override
  String get promoterScoreStep3ThanksMessagePromoters =>
      'Thanks for your rating!';

  @override
  String get promoterScoreStep3ThanksMessagePassives =>
      'Thanks for your rating!';

  @override
  String get promoterScoreStep3ThanksMessageDetractors =>
      'Thanks for your rating!';

  @override
  String get promoterScoreNextButton => 'Next';

  @override
  String get promoterScoreBackButton => 'Back';

  @override
  String get promoterScoreSubmitButton => 'Submit';

  @override
  String get backdropReturnToApp => 'Volver a la aplicación';
}
