import 'dart:async';
import 'dart:convert';

import 'package:wiredash/src/feedback/data/label.dart';

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
  final bool askForUserEmail;

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
    this.askForUserEmail = false,
    this.collectMetaData,
  });

  @override
  String toString() {
    return 'WiredashFeedbackOptions{'
        'labels: $labels, '
        'askForUserEmail: $askForUserEmail'
        '}';
  }
}

/// MetaData that will be sent along the user feedback to the Wiredash console
///
/// This object is intended to be mutable, making it trivial to change
/// properties.
class CustomizableWiredashMetaData {
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
