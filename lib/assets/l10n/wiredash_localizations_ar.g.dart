import 'wiredash_localizations.g.dart';

/// The translations for Arabic (`ar`).
class WiredashLocalizationsAr extends WiredashLocalizations {
  WiredashLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get feedbackStep1MessageTitle => 'أرسل لنا مراجعتك';

  @override
  String get feedbackStep1MessageBreadcrumbTitle => 'كتابة رسالة';

  @override
  String get feedbackStep1MessageDescription => 'أذكر لنا ملخص عن ما واجهته';

  @override
  String get feedbackStep1MessageHint =>
      'هنالك مشكلة غريبة عندما أحاول تغيير صورتي...';

  @override
  String get feedbackStep1MessageErrorMissingMessage => 'رجاءاً أضف رسالة';

  @override
  String get feedbackStep2LabelsTitle => 'اي تنصيف يمثل مراجعتك';

  @override
  String get feedbackStep2LabelsBreadcrumbTitle => 'التصنيفات';

  @override
  String get feedbackStep2LabelsDescription =>
      'أختيار التنصيف الملائم يسهل علينا توجيه الأقتراح للشخص المناسب.';

  @override
  String get feedbackStep3ScreenshotOverviewTitle => 'إضافة لقطة للشاشة؟';

  @override
  String get feedbackStep3ScreenshotOverviewBreadcrumbTitle => 'لقطات الشاشة';

  @override
  String get feedbackStep3ScreenshotOverviewDescription =>
      'يمكنك تصفح التطبيق وأختيار لقطة الشاشة التي ترغب بها';

  @override
  String get feedbackStep3ScreenshotOverviewSkipButton => 'تخطي';

  @override
  String get feedbackStep3ScreenshotOverviewAddScreenshotButton =>
      'إضافة لقطة للشاشة';

  @override
  String get feedbackStep3ScreenshotBarNavigateTitle => 'أخذ لقطة للشاشة';

  @override
  String get feedbackStep3ScreenshotBottomBarTitle =>
      'Include a screenshot for more context';

  @override
  String get feedbackStep3ScreenshotBarDrawTitle =>
      'أرسم على الشاشة لإضافة تأشيرة';

  @override
  String get feedbackStep3ScreenshotBarDrawUndoButton => 'رجوع';

  @override
  String get feedbackStep3ScreenshotBarCaptureButton => 'التقاط';

  @override
  String get feedbackStep3ScreenshotBarSaveButton => 'حفظ';

  @override
  String get feedbackStep3ScreenshotBarOkButton => 'تم';

  @override
  String get feedbackStep3GalleryTitle => 'لقطات الشاشة المرفقة';

  @override
  String get feedbackStep3GalleryBreadcrumbTitle => 'لقطات الشاشة';

  @override
  String get feedbackStep3GalleryDescription =>
      'يمكنك إضافة لقطة للشاشة لكي نستطيع فهم المشكلة أكثر.';

  @override
  String get feedbackStep4EmailTitle =>
      'أحصل على تحديثات عبر البريد الإلكتروني لمشكلتك';

  @override
  String get feedbackStep4EmailBreadcrumbTitle => 'التواصل';

  @override
  String get feedbackStep4EmailDescription =>
      'ضع بريدك الإلكتروني بالأسفل أو اتركه فارغ';

  @override
  String get feedbackStep4EmailInvalidEmail =>
      'هذا لا يبدو بريد إلكتروني صالح، يمكنك تركه فارغ.';

  @override
  String get feedbackStep4EmailInputHint => 'mail@example.com';

  @override
  String get feedbackStep6SubmitTitle => 'تقديم المراجعة';

  @override
  String get feedbackStep6SubmitBreadcrumbTitle => 'تقديم';

  @override
  String get feedbackStep6SubmitDescription =>
      'رجاءاً راجع جميع المعلومات قبل أن ترسلها.\nبوسعك الوصول إلى مراجعاتك بأي وقت.';

  @override
  String get feedbackStep6SubmitSubmitButton => 'تقديم';

  @override
  String get feedbackStep6SubmitSubmitShowDetailsButton => 'عرض التفاصيل';

  @override
  String get feedbackStep6SubmitSubmitHideDetailsButton => 'أخفاء التفاصيل';

  @override
  String get feedbackStep6SubmitSubmitDetailsTitle => 'تفاصيل المراجعة';

  @override
  String get feedbackStep7SubmissionInFlightMessage => 'جاري تقديم مراجعتك';

  @override
  String get feedbackStep7SubmissionSuccessMessage => 'شكراً لمراجعتك!';

  @override
  String get feedbackStep7SubmissionErrorMessage => 'أرسال المراجعة فشل';

  @override
  String get feedbackStep7SubmissionOpenErrorButton =>
      'أضغط لرؤية تفاصيل الخطأ';

  @override
  String get feedbackStep7SubmissionRetryButton => 'حاول مجدداً';

  @override
  String feedbackStepXOfY(int current, int total) {
    return 'الخطوة $current من $total';
  }

  @override
  String get feedbackDiscardButton => 'أهمال المراجعة';

  @override
  String get feedbackDiscardConfirmButton => 'هل ترغب فعلاً بأهماله؟';

  @override
  String get feedbackNextButton => 'التالي';

  @override
  String get feedbackBackButton => 'رجوع';

  @override
  String get feedbackCloseButton => 'أغلاق';

  @override
  String get promoterScoreStep1Question => 'كم نسبة توصيتك بنا؟';

  @override
  String get promoterScoreStep1Description =>
      'غير محتمل أطلاقاً = 0, محتمل جداً = 10';

  @override
  String get promoterScoreStep2MessageTitle =>
      'كم نسبة توصيتك بنا للاصدقاء والعائلة؟';

  @override
  String promoterScoreStep2MessageDescription(int rating) {
    return 'هل بوسعك أخبارنا لماذا أخترت $rating؟ هذه الخطوة أختيارية.';
  }

  @override
  String get promoterScoreStep2MessageHint => 'سيكون عظيماً جداً لو حسنت....';

  @override
  String get promoterScoreStep3ThanksMessagePromoters => 'شكراً لتقييمك!';

  @override
  String get promoterScoreStep3ThanksMessagePassives => 'شكراً لتقييمك!';

  @override
  String get promoterScoreStep3ThanksMessageDetractors => 'شكراً لتقييمك!';

  @override
  String get promoterScoreNextButton => 'التالي';

  @override
  String get promoterScoreBackButton => 'رجوع';

  @override
  String get promoterScoreSubmitButton => 'تقديم';

  @override
  String get backdropReturnToApp => 'الرجوع للتطبيق';
}
