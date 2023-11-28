import 'wiredash_localizations.g.dart';

/// The translations for Persian (`fa`).
class WiredashLocalizationsFa extends WiredashLocalizations {
  WiredashLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get feedbackStep1MessageTitle => 'ارسال بازخورد';

  @override
  String get feedbackStep1MessageBreadcrumbTitle => 'ثبت بازخورد';

  @override
  String get feedbackStep1MessageDescription =>
      'توضیح کوتاهی در مورد مشکلی که با آن مواجه شدید بنویس';

  @override
  String get feedbackStep1MessageHint =>
      'وقتی می‌خواهم آواتارم رو تغییر بدم یک خطای ناشناخته میبینم...';

  @override
  String get feedbackStep1MessageErrorMissingMessage => 'یک پیغام اضافه کن';

  @override
  String get feedbackStep2LabelsTitle => 'کدام برچسب متناسب با بازخورد شماست؟';

  @override
  String get feedbackStep2LabelsBreadcrumbTitle => 'برچسب ها';

  @override
  String get feedbackStep2LabelsDescription =>
      'انتخاب دسته مناسب به ما کمک می کند تا مشکل را شناسایی کرده و بازخورد شما را به واحد مرتبط هدایت کنیم';

  @override
  String get feedbackStep3ScreenshotOverviewTitle => 'اضافه کردن اسکرین-شات؟';

  @override
  String get feedbackStep3ScreenshotOverviewBreadcrumbTitle => 'اسکرین-شات ها';

  @override
  String get feedbackStep3ScreenshotOverviewDescription =>
      'می‌توانید برنامه را پیمایش کنید و انتخاب کنید چه زمانی اسکرین شات بگیرید';

  @override
  String get feedbackStep3ScreenshotOverviewSkipButton => 'رد شدن';

  @override
  String get feedbackStep3ScreenshotOverviewAddScreenshotButton =>
      'اسکرین-شات جدید';

  @override
  String get feedbackStep3ScreenshotBarNavigateTitle => 'اسکرین-شات بگیر';

  @override
  String get feedbackStep3ScreenshotBottomBarTitle =>
      'برای شفاف سازی مشکل اسکرین-شات اضافه کن';

  @override
  String get feedbackStep3ScreenshotBarDrawTitle =>
      'برای اشاره به محل دقیق مشکل میتونی روی اسکرین-شات نقاشی کنی';

  @override
  String get feedbackStep3ScreenshotBarDrawUndoButton => 'واگرد';

  @override
  String get feedbackStep3ScreenshotBarCaptureButton => 'اسکرین-شات بگیر';

  @override
  String get feedbackStep3ScreenshotBarSaveButton => 'ذخیره';

  @override
  String get feedbackStep3ScreenshotBarOkButton => 'خب!';

  @override
  String get feedbackStep3GalleryTitle => 'تصاویر پیوست';

  @override
  String get feedbackStep3GalleryBreadcrumbTitle => 'اسکرین-شات ها';

  @override
  String get feedbackStep3GalleryDescription =>
      'می‌توانید اسکرین‌شات‌های بیشتری اضافه کنید تا به ما در درک بهتر مشکل شما کمک کند.';

  @override
  String get feedbackStep4EmailTitle =>
      'ایمیل خود را برای دریافت اخبار مرتبط با مشکل وارد کنید';

  @override
  String get feedbackStep4EmailBreadcrumbTitle => 'تماس با ما';

  @override
  String get feedbackStep4EmailDescription =>
      'آدرس ایمیل خود را در زیر اضافه کنید یا خالی رها کنید';

  @override
  String get feedbackStep4EmailInvalidEmail =>
      'این آدرس ایمیل معتبری به نظر نمی رسد. می توانید آن را خالی رها کنید.';

  @override
  String get feedbackStep4EmailInputHint => 'mail@example.com';

  @override
  String get feedbackStep6SubmitTitle => 'ثبت بازخورد';

  @override
  String get feedbackStep6SubmitBreadcrumbTitle => 'ثبت';

  @override
  String get feedbackStep6SubmitDescription =>
      'لطفاً قبل از ارسال، همه اطلاعات را مرور کنید.\nهر زمان خواستید می‌توانید برای ایجاد تغییرات به عقب برگردید.';

  @override
  String get feedbackStep6SubmitSubmitButton => 'ثبت';

  @override
  String get feedbackStep6SubmitSubmitShowDetailsButton => 'نمایش جزئیات';

  @override
  String get feedbackStep6SubmitSubmitHideDetailsButton => 'مخفی کردن جزئیات';

  @override
  String get feedbackStep6SubmitSubmitDetailsTitle => 'جزئیات بازخورد';

  @override
  String get feedbackStep7SubmissionInFlightMessage => 'دریافت بارخورد شما';

  @override
  String get feedbackStep7SubmissionSuccessMessage =>
      'از همکاری شما متشکریم :)';

  @override
  String get feedbackStep7SubmissionErrorMessage => 'خطا در ثبت اطلاعات';

  @override
  String get feedbackStep7SubmissionOpenErrorButton =>
      'برای مشاهده خطا کلیک کنید';

  @override
  String get feedbackStep7SubmissionRetryButton => 'تلاش مجدد';

  @override
  String feedbackStepXOfY(int current, int total) {
    return 'مرحله $current از $total';
  }

  @override
  String get feedbackDiscardButton => 'بیخیال!';

  @override
  String get feedbackDiscardConfirmButton => 'واقعا بیخیال؟';

  @override
  String get feedbackNextButton => 'بعدی';

  @override
  String get feedbackBackButton => 'قبلی';

  @override
  String get feedbackCloseButton => 'بستن';

  @override
  String get promoterScoreStep1Question =>
      'چقدر احتمال داره ما رو به دیگران معرفی کنی؟';

  @override
  String get promoterScoreStep1Description => '0: اصلاً, 10: شدیداً';

  @override
  String get promoterScoreStep2MessageTitle =>
      'چقدر احتمال دارد که ما را به دوستان و خانواده خود معرفی کنید؟';

  @override
  String promoterScoreStep2MessageDescription(int rating) {
    return 'ممکن است کمی بیشتر در مورد دلیل انتخاب $rating به ما بگویید؟ (اختیاری).';
  }

  @override
  String get promoterScoreStep2MessageHint =>
      'خیلی خوبه اگه بتونی پیشرفت کنی...';

  @override
  String get promoterScoreStep3ThanksMessagePromoters =>
      'با تشکر از امتیازدهی شما!';

  @override
  String get promoterScoreStep3ThanksMessagePassives =>
      'با تشکر از امتیازدهی شما!';

  @override
  String get promoterScoreStep3ThanksMessageDetractors =>
      'با تشکر از امتیازدهی شما!';

  @override
  String get promoterScoreNextButton => 'بعدی';

  @override
  String get promoterScoreBackButton => 'قبلی';

  @override
  String get promoterScoreSubmitButton => 'ثبت';

  @override
  String get backdropReturnToApp => 'بازگشت به برنامه';
}
