import 'package:wiredash/wiredash.dart';

class WiredashLocalizedTranslations extends WiredashTranslations {
  const WiredashLocalizedTranslations() : super();
  @override
  String get captureSaveScreenshot => "Save screenshot";
  @override
  String get captureSkip => "Skip screenshot";
  @override
  String get captureSpotlightNavigateMsg =>
      "Navigate to the screen which you would like to attach to your capture.";
  @override
  String get captureSpotlightNavigateTitle => "navigate";
  @override
  String get captureSpotlightScreenCapturedMsg =>
      "Screen captured! Feel free to draw on the screen to highlight areas affected by your capture.";
  @override
  String get captureSpotlightScreenCapturedTitle => "draw";
  @override
  String get captureTakeScreenshot => "Take screenshot";
  @override
  String get feedbackBack => "Go back";
  @override
  String get feedbackCancel => "Cancel";
  @override
  String get feedbackModeBugMsg =>
      "Let us know so we can forward this to our bug control.";
  @override
  String get feedbackModeBugTitle => "Report a Bug";
  @override
  String get feedbackModeImprovementMsg =>
      "Do you have an idea that would make our app better? We would love to know!";
  @override
  String get feedbackModeImprovementTitle => "Request a Feature";
  @override
  String get feedbackModePraiseMsg =>
      "Let us know what you really like about our app, maybe we can make it even better?";
  @override
  String get feedbackModePraiseTitle => "Send Applause";
  @override
  String get feedbackSave => "Save";
  @override
  String get feedbackSend => "Send feedback";
  @override
  String get feedbackStateEmailMsg =>
      "If you want to get updates regarding your feedback, enter your email down below.";
  @override
  String get feedbackStateEmailTitle => "Stay in the loop 👇";
  @override
  String get feedbackStateFeedbackMsg =>
      "We are listening. Please provide as much info as needed so we can help you.";
  @override
  String get feedbackStateIntroMsg =>
      "We can’t wait to get your thoughts on our app. What would you like to do?";
  @override
  String get feedbackStateIntroTitle => "Hi there 👋";
  @override
  String get feedbackStateSuccessCloseMsg =>
      "Thanks for submitting your feedback!";
  @override
  String get feedbackStateSuccessCloseTitle => "Close this Dialog";
  @override
  String get feedbackStateSuccessMsg =>
      "That's it. Thank you so much for helping us build a better app!";
  @override
  String get feedbackStateSuccessTitle => "Thank you ✌️";
  @override
  String get inputHintEmail => "Your email";
  @override
  String get inputHintFeedback => "Your feedback";
  @override
  String get validationHintEmail =>
      "Please enter a valid email or leave this field blank.";
  @override
  String get validationHintFeedbackEmpty => "Please provide your feedback.";
  @override
  String get validationHintFeedbackLength => "Your feedback is too long.";
  @override
  String get feedbackStateFeedbackTitle => "Your feedback ✍️";
}
