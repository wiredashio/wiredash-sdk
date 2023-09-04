import 'wiredash_localizations.g.dart';

/// The translations for Turkish (`tr`).
class WiredashLocalizationsTr extends WiredashLocalizations {
  WiredashLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get feedbackStep1MessageTitle => 'Bize geri bildirim gönder';

  @override
  String get feedbackStep1MessageBreadcrumbTitle => 'Mesaj oluştur';

  @override
  String get feedbackStep1MessageDescription =>
      'Karşılaştığın olayın kısa bir açıklamasını ekle';

  @override
  String get feedbackStep1MessageHint =>
      'Avatarımı değiştirmeye çalıştığımda bilinmeyen bir hata alıyorum...';

  @override
  String get feedbackStep1MessageErrorMissingMessage => 'Lütfen mesaj ekleyin';

  @override
  String get feedbackStep2LabelsTitle =>
      'Hangi etiket geri bildiriminizi en iyi şekilde açıklıyor?';

  @override
  String get feedbackStep2LabelsBreadcrumbTitle => 'Etiketler';

  @override
  String get feedbackStep2LabelsDescription =>
      'Doğru kategoriyi seçmeniz, hatayı tespit etmemize ve sorumlu kişiye iletmemize yardımcı oluyor.';

  @override
  String get feedbackStep3ScreenshotOverviewTitle =>
      'Daha iyi anlaşılmak için ekran görüntüsü ekle?';

  @override
  String get feedbackStep3ScreenshotOverviewBreadcrumbTitle =>
      'Ekran görüntüleri';

  @override
  String get feedbackStep3ScreenshotOverviewDescription =>
      'Uygulamada dolanabilecek ve ne zaman ekran görüntüsü alacağınızı seçebileceksiniz';

  @override
  String get feedbackStep3ScreenshotOverviewSkipButton => 'Geç';

  @override
  String get feedbackStep3ScreenshotOverviewAddScreenshotButton =>
      'Ekran görüntüsü ekle';

  @override
  String get feedbackStep3ScreenshotBarNavigateTitle => 'Ekran görüntüsü al';

  @override
  String get feedbackStep3ScreenshotBottomBarTitle =>
      'Include a screenshot for more context';

  @override
  String get feedbackStep3ScreenshotBarDrawTitle =>
      'Bir şeyler göstermek için ekranın üzerine çiz';

  @override
  String get feedbackStep3ScreenshotBarDrawUndoButton => 'Geri al';

  @override
  String get feedbackStep3ScreenshotBarCaptureButton => 'Çek';

  @override
  String get feedbackStep3ScreenshotBarSaveButton => 'Kaydet';

  @override
  String get feedbackStep3ScreenshotBarOkButton => 'Tamam';

  @override
  String get feedbackStep3GalleryTitle => 'Eklenen ekran görüntüleri';

  @override
  String get feedbackStep3GalleryBreadcrumbTitle => 'Ekran görüntüleri';

  @override
  String get feedbackStep3GalleryDescription =>
      'Hatayı daha iyi anlamamız için daha fazla ekran görüntüsü ekleyebilirsin.';

  @override
  String get feedbackStep4EmailTitle =>
      'Hatanız hakkında e-mail ile haberdar edilin';

  @override
  String get feedbackStep4EmailBreadcrumbTitle => 'İletişim';

  @override
  String get feedbackStep4EmailDescription =>
      'Aşağıya e-mail adresinizi girin ya da boş bırakın';

  @override
  String get feedbackStep4EmailInvalidEmail =>
      'Bu geçerli bir e-mail adresine benzemiyor, isterseniz boş da bırakabilirsiniz.';

  @override
  String get feedbackStep4EmailInputHint => 'mail@ornek.com';

  @override
  String get feedbackStep6SubmitTitle => 'Geri bildirimi yolla';

  @override
  String get feedbackStep6SubmitBreadcrumbTitle => 'Onayla';

  @override
  String get feedbackStep6SubmitDescription =>
      'Lütfen onaylamadan önce tüm bilgileri gözden geçirin.\nİstediğinizde geriye dönüp geri bildiriminizi değiştirebilirsiniz.';

  @override
  String get feedbackStep6SubmitSubmitButton => 'Onayla';

  @override
  String get feedbackStep6SubmitSubmitShowDetailsButton => 'Detayları göster';

  @override
  String get feedbackStep6SubmitSubmitHideDetailsButton => 'Detayları sakla';

  @override
  String get feedbackStep6SubmitSubmitDetailsTitle => 'Geri bildirim detayları';

  @override
  String get feedbackStep7SubmissionInFlightMessage =>
      'Geri bildiriminiz yollanıyor';

  @override
  String get feedbackStep7SubmissionSuccessMessage =>
      'Geri bildiriminiz için teşekkürler!';

  @override
  String get feedbackStep7SubmissionErrorMessage =>
      'Geri bildirim yollanması başarısız';

  @override
  String get feedbackStep7SubmissionOpenErrorButton =>
      'Hatanın detaylarını görmek için tıklayın';

  @override
  String get feedbackStep7SubmissionRetryButton => 'Yeniden dene';

  @override
  String feedbackStepXOfY(int current, int total) {
    return '$total adımın $current. adımı';
  }

  @override
  String get feedbackDiscardButton => 'Geri bildirimi iptal et';

  @override
  String get feedbackDiscardConfirmButton => 'Ciddi misin? İptal mi!';

  @override
  String get feedbackNextButton => 'İleri';

  @override
  String get feedbackBackButton => 'Geri';

  @override
  String get feedbackCloseButton => 'Kapat';

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
  String get backdropReturnToApp => 'Uygulamaya dön';
}
