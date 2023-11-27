import 'dart:async';

import 'package:wiredash/src/feedback/data/label.dart';
import 'package:wiredash/src/metadata/user_meta_data.dart';

/// Options that adjust the flow a user has to take when giving feedback
class WiredashFeedbackOptions {
  /// The labels a user can select
  ///
  /// Please visit the Wiredash Console to get your label ids
  /// https://console.wiredash.io/
  /// Settings -> Labels
  ///
  /// When `null` the label selection step isn't shown at all
  ///
  /// Localization is the responsibility of wiredash. Please localize the
  /// labels yourself, you know best if and how they should be translated.
  final List<Label>? labels;

  /// Define if and how users get asked for their email address.
  ///
  /// Defaults to [EmailPrompt.optional]
  final EmailPrompt? email;

  /// Define whether users can attach screenshots
  ///
  /// Defaults to [ScreenshotPrompt.optional]
  ///
  /// Screenshots are not supported on Flutter Web when using the html renderer.
  /// The screenshot step will therefore not be shown on Flutter Web when using
  /// the html renderer.
  /// https://github.com/flutter/flutter/issues/59072
  /// https://github.com/flutter/flutter/issues/49857
  final ScreenshotPrompt? screenshot;

  /// Enrich the user feedback with custom metadata
  ///
  /// This function is called by Wiredash when the user (optional) takes a
  /// screenshot or right before submitting feedback.
  ///
  /// Mutate the incoming `metaData` object and add or override values
  ///
  /// ```dart
  /// feedbackOptions: WiredashFeedbackOptions(
  ///   collectMetaData: (metaData) => metaData
  ///     ..userEmail = 'dash@wiredash.io'
  ///     ..custom['isPremium'] = false
  ///     ..custom['nested'] = {'wire': 'dash'},
  /// ```
  final FutureOr<CustomizableWiredashMetaData> Function(
    CustomizableWiredashMetaData metaData,
  )? collectMetaData;

  const WiredashFeedbackOptions({
    this.labels,
    @Deprecated('Use `email` instead') bool? askForUserEmail,
    EmailPrompt? email,
    this.collectMetaData,
    @Deprecated('Use `screenshot` instead') bool? screenshotStep,
    ScreenshotPrompt? screenshot,
  })  : screenshot = screenshot ??
            (screenshotStep == true
                ? ScreenshotPrompt.optional
                : screenshotStep == false
                    ? ScreenshotPrompt.hidden
                    : null),
        email = email ??
            (askForUserEmail == true
                ? EmailPrompt.optional
                : askForUserEmail == false
                    ? EmailPrompt.hidden
                    : null);

  @override
  String toString() {
    return 'WiredashFeedbackOptions{'
        'labels: $labels, '
        'email: $email'
        'screenshot: $screenshot'
        '}';
  }
}

enum EmailPrompt {
  /// Email step is not shown
  hidden,

  /// User is optionally asked for their email address
  optional,

  /// The email address is mandatory
  // TODO implement
  //mandatory,
}

enum ScreenshotPrompt {
  /// Screenshot step is not shown
  hidden,

  /// User is asked to optionally to attach screenshots
  optional,
}
