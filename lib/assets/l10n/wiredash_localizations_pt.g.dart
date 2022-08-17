import 'wiredash_localizations.g.dart';

/// The translations for Portuguese (`pt`).
class WiredashLocalizationsPt extends WiredashLocalizations {
  WiredashLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get feedbackStep1MessageTitle => 'Envie-nos seu feedback';

  @override
  String get feedbackStep1MessageBreadcrumbTitle => 'Escrever mensagem';

  @override
  String get feedbackStep1MessageDescription =>
      'Adicione uma curta descrição sobre o problema que você encontrou';

  @override
  String get feedbackStep1MessageHint =>
      'Acontece um erro desconhecido quando tento trocar minha foto de perfil...';

  @override
  String get feedbackStep1MessageErrorMissingMessage =>
      'Por favor digite sua mensagem';

  @override
  String get feedbackStep2LabelsTitle =>
      'Qual categoria representa melhor seus comentários?';

  @override
  String get feedbackStep2LabelsBreadcrumbTitle => 'Categorias';

  @override
  String get feedbackStep2LabelsDescription =>
      'Selecionar uma categoria apropriada nos ajuda a identificar seu problema e enviar seus comentários à equipe responsável';

  @override
  String get feedbackStep3ScreenshotOverviewTitle =>
      'Deseja adicionar imagens da tela para dar maiores informações?';

  @override
  String get feedbackStep3ScreenshotOverviewBreadcrumbTitle =>
      'Capturas de tela';

  @override
  String get feedbackStep3ScreenshotOverviewDescription =>
      'Você será capaz de navegar pelo app e escolher quando capturar a tela';

  @override
  String get feedbackStep3ScreenshotOverviewSkipButton => 'Pular';

  @override
  String get feedbackStep3ScreenshotOverviewAddScreenshotButton =>
      'Adicionar Captura de Tela';

  @override
  String get feedbackStep3ScreenshotBarNavigateTitle =>
      'Faça uma captura de tela';

  @override
  String get feedbackStep3ScreenshotBarDrawTitle =>
      'Indique os detalhes relevantes';

  @override
  String get feedbackStep3ScreenshotBarDrawUndoButton => 'Desfazer';

  @override
  String get feedbackStep3ScreenshotBarCaptureButton => 'Capturar';

  @override
  String get feedbackStep3ScreenshotBarSaveButton => 'Salvar';

  @override
  String get feedbackStep3ScreenshotBarOkButton => 'Ok';

  @override
  String get feedbackStep3GalleryTitle => 'Capturas de tela em anexo';

  @override
  String get feedbackStep3GalleryBreadcrumbTitle => 'Capturas de tela';

  @override
  String get feedbackStep3GalleryDescription =>
      'Você pode adicionar mais capturas de tela para nos ajudar a entender melhor seu problema.';

  @override
  String get feedbackStep4EmailTitle => 'Receba atualizações por email';

  @override
  String get feedbackStep4EmailBreadcrumbTitle => 'Contato';

  @override
  String get feedbackStep4EmailDescription =>
      'Adicione seu endereço de email abaixo ou deixe em branco';

  @override
  String get feedbackStep4EmailInvalidEmail =>
      'Este endereço de email não parece válido. Você pode deixar este campo vazio.';

  @override
  String get feedbackStep4EmailInputHint => 'email@exemplo.com';

  @override
  String get feedbackStep6SubmitTitle => 'Enviar feedback';

  @override
  String get feedbackStep6SubmitBreadcrumbTitle => 'Enviar';

  @override
  String get feedbackStep6SubmitDescription =>
      'Por favor revise todas as informações antes de enviar.\nVocê pode voltar para ajustar seus comentários a qualquer momento.';

  @override
  String get feedbackStep6SubmitSubmitButton => 'Enviar';

  @override
  String get feedbackStep6SubmitSubmitShowDetailsButton => 'Ver detalhes';

  @override
  String get feedbackStep6SubmitSubmitHideDetailsButton => 'Ocultar detalhes';

  @override
  String get feedbackStep6SubmitSubmitDetailsTitle => 'Comentários';

  @override
  String get feedbackStep7SubmissionInFlightMessage =>
      'Enviando seus comentários';

  @override
  String get feedbackStep7SubmissionSuccessMessage =>
      'Obrigado pelo seu feedback!';

  @override
  String get feedbackStep7SubmissionErrorMessage =>
      'O envio dos seus comentários falhou';

  @override
  String get feedbackStep7SubmissionOpenErrorButton =>
      'Toque para ver os detalhes do erro';

  @override
  String get feedbackStep7SubmissionRetryButton => 'Tentar novamente';

  @override
  String feedbackStepXOfY(int current, int total) {
    return 'Passo $current de $total';
  }

  @override
  String get feedbackDiscardButton => 'Descartar comentários';

  @override
  String get feedbackDiscardConfirmButton => 'Tem certeza? Apagar!';

  @override
  String get feedbackNextButton => 'Próximo';

  @override
  String get feedbackBackButton => 'Voltar';

  @override
  String get feedbackCloseButton => 'Fechar';

  @override
  String get npsStep1Question => 'How likely are you to recommend us?';

  @override
  String get npsStep1Description => '0 = Not likely, 10 = Most likely';

  @override
  String get npsStep2MessageTitle =>
      'How likely are you to recommend us to your friends and family?';

  @override
  String npsStep2MessageDescription(int rating) {
    return 'Could you tell us a bit more about why you chose $rating? This step is optional.';
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
  String get backdropReturnToApp => 'Voltar ao app';
}
