import 'dart:async';

import 'package:wiredash/src/feedback/data/label.dart';
import 'package:wiredash/src/metadata/build_info/build_info.dart';
import 'package:wiredash/src/utils/object_util.dart';

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

  /// User is asked to optionally attach screenshots
  optional,
}

/// Mutable version of [WiredashMetaData] that will be sent along the user
/// feedback to the Wiredash console
///
/// This object is intended to be mutable, making it trivial to change
/// properties.
class CustomizableWiredashMetaData implements WiredashMetaData {
  /// This constructor returns a 100% clean version with no prefilled data
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

  @override
  String? userId;

  @override
  String? userEmail;

  @override
  String? buildVersion;

  @override
  String? buildNumber;

  @override
  String? buildCommit;

  @override
  Map<String, Object?> custom = {};

  @override
  String toString() {
    return 'CustomizableWiredashMetaData{'
        'userId: $userId, '
        'userEmail: $userEmail, '
        'buildVersion: $buildVersion, '
        'buildNumber: $buildNumber, '
        'custom: $custom'
        '}';
  }

  CustomizableWiredashMetaData Function({
    String? userId,
    String? userEmail,
    String? buildVersion,
    String? buildNumber,
    String? buildCommit,
    Map<String, Object?>? custom,
  }) get copyWith => _copyWith;

  CustomizableWiredashMetaData _copyWith({
    Object? userId = defaultArgument,
    Object? userEmail = defaultArgument,
    Object? buildVersion = defaultArgument,
    Object? buildNumber = defaultArgument,
    Object? buildCommit = defaultArgument,
    Object? custom = defaultArgument,
  }) {
    final metaData = CustomizableWiredashMetaData();
    metaData.userId =
        userId != defaultArgument ? userId as String? : this.userId;
    metaData.userEmail =
        userEmail != defaultArgument ? userEmail as String? : this.userEmail;
    metaData.buildVersion = buildVersion != defaultArgument
        ? buildVersion as String?
        : this.buildVersion;
    metaData.buildNumber = buildNumber != defaultArgument
        ? buildNumber as String?
        : this.buildNumber;
    metaData.buildCommit = buildCommit != defaultArgument
        ? buildCommit as String?
        : this.buildCommit;
    if (custom != defaultArgument && custom != null) {
      metaData.custom = custom as Map<String, Object?>;
    } else {
      metaData.custom = this.custom;
    }
    return metaData;
  }
}

/// MetaData that will be sent along the user feedback to the Wiredash console
abstract class WiredashMetaData {
  /// The id of the user, allowing you to match the feedback with the userIds
  /// of you application
  ///
  /// Might be a nickname, a uuid, or an email-address
  String? get userId;

  /// The email address auto-fills the email address step
  ///
  /// This is the best way to contact the user and can be different from
  /// [userId]
  String? get userEmail;

  /// The "name" of the version, i.e. a semantic version 1.5.10-debug
  ///
  /// This field is prefilled with the environment variable `BUILD_VERSION`
  String? get buildVersion;

  /// The build number of this version, usually an int
  ///
  /// This field is prefilled with the environment variable `BUILD_NUMBER`
  String? get buildNumber;

  /// The commit that was used to build this app
  ///
  /// This field is prefilled with the environment variable `BUILD_COMMIT`
  String? get buildCommit;

  /// Supported data types are String, int, double, bool, List, Map.
  ///
  /// Values that can't be encoded using `jsonEncode` will be omitted.
  Map<String, Object?> get custom;

  @override
  String toString() {
    return 'WiredashMetaData{'
        'userId: $userId, '
        'userEmail: $userEmail, '
        'buildVersion: $buildVersion, '
        'buildNumber: $buildNumber, '
        'custom: $custom'
        '}';
  }
}
