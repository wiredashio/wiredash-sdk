import 'dart:async';

import 'package:wiredash/src/feedback/data/label.dart';
import 'package:wiredash/src/metadata/build_info/build_info.dart';

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

  /// When `true` a step asking the user for their email address is shown
  ///
  /// Defaults to false, does not show the email address step.
  final bool? askForUserEmail;

  /// Whether to display the screenshot and drawing step or not.
  ///
  /// Defaults to true, allows the user to add screenshots
  ///
  /// The Flutter Web beta does not currently support screenshots. Therefore,
  /// the screenshot and drawing step is never shown and this option is ignored.
  final bool? screenshotStep;

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
    this.askForUserEmail,
    this.collectMetaData,
    this.screenshotStep,
  });

  @override
  String toString() {
    return 'WiredashFeedbackOptions{'
        'labels: $labels, '
        'askForUserEmail: $askForUserEmail'
        'screenshotStep: $screenshotStep'
        '}';
  }
}

/// MetaData that will be sent along the user feedback to the Wiredash console
///
/// This object is intended to be mutable, making it trivial to change
/// properties.
class CustomizableWiredashMetaData {
  CustomizableWiredashMetaData();

  /// Returns a new [CustomizableWiredashMetaData] with prefilled [buildVersion],
  /// [buildNumber], [buildCommit] from dart-define. See [EnvBuildInfo] for more
  /// info
  factory CustomizableWiredashMetaData.populated() {
    final metaData = CustomizableWiredashMetaData();
    metaData.buildVersion = buildInfo.buildVersion;
    metaData.buildNumber = buildInfo.buildNumber;
    metaData.buildCommit = buildInfo.buildCommit;
    return metaData;
  }

  /// The id of the user, allowing you to match the feedback with the userIds
  /// of you application
  ///
  /// Might be a nickname, a uuid, or an email-address
  String? userId;

  /// The email address auto-fills the email address step
  ///
  /// This is the best way to contact the user and can be different from
  /// [userId]
  String? userEmail;

  /// The "name" of the version, i.e. a semantic version 1.5.10-debug
  ///
  /// This field is prefilled with the environment variable `BUILD_VERSION`
  String? buildVersion;

  /// The build number of this version, usually an int
  ///
  /// This field is prefilled with the environment variable `BUILD_NUMBER`
  String? buildNumber;

  /// The commit that was used to build this app
  ///
  /// This field is prefilled with the environment variable `BUILD_COMMIT`
  String? buildCommit;

  /// Supported data types are String, int, double, bool, List, Map.
  ///
  /// Values that can't be encoded using `jsonEncode` will be omitted.
  Map<String, Object?> custom = {};

  @override
  String toString() {
    return 'FeedbackMetaData{'
        'userId: $userId, '
        'userEmail: $userEmail, '
        'buildVersion: $buildVersion, '
        'buildNumber: $buildNumber, '
        'custom: $custom'
        '}';
  }
}
