// ignore_for_file: deprecated_member_use_from_same_package

import 'package:collection/collection.dart';
import 'package:wiredash/src/utils/object_util.dart';

/// Information about the user/ app with will be sent along feedback or
/// promoter score to the Wiredash console
///
/// This object is intended to be mutable, making it trivial to change
/// properties.
class CustomizableWiredashMetaData {
  /// This constructor returns a 100% clean version with no prefilled data
  CustomizableWiredashMetaData();

  @Deprecated(
    'Use the default constructor CustomizableWiredashMetaData() instead.',
  )
  CustomizableWiredashMetaData.populated();

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
  @Deprecated(
    'The buildVersion is now read directly from the native platform. '
    'Alternatively, provide it at compile time with env.BUILD_VERSION. '
    'See https://docs.wiredash.io/sdk/custom-properties/#during-compile-time',
  )
  String? buildVersion;

  /// The build number of this version, usually an int
  ///
  /// This field is prefilled with the environment variable `BUILD_NUMBER`
  @Deprecated(
    'The buildNumber is now read directly from the native platform. '
    'Alternatively, provide it at compile time with env.BUILD_NUMBER. '
    'See https://docs.wiredash.io/sdk/custom-properties/#during-compile-time',
  )
  String? buildNumber;

  /// The commit that was used to build this app
  ///
  /// This field is prefilled with the environment variable `BUILD_COMMIT`
  @Deprecated(
    'Provide the buildCommit at compile time with env.BUILD_NUMBER. '
    'See https://docs.wiredash.io/sdk/custom-properties/#during-compile-time',
  )
  String? buildCommit;

  /// Supported data types are String, int, double, bool, List, Map.
  ///
  /// Values that can't be encoded using `jsonEncode` will be omitted.
  Map<String, Object?> custom = {};

  @override
  String toString() {
    return 'CustomizableWiredashMetaData{'
        'userId: $userId, '
        'userEmail: $userEmail, '
        'custom: $custom'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomizableWiredashMetaData &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          userEmail == other.userEmail &&
          buildVersion == other.buildVersion &&
          buildNumber == other.buildNumber &&
          buildCommit == other.buildCommit &&
          const DeepCollectionEquality.unordered().equals(custom, other.custom);

  @override
  int get hashCode =>
      userId.hashCode ^
      userEmail.hashCode ^
      buildVersion.hashCode ^
      buildNumber.hashCode ^
      buildCommit.hashCode ^
      const DeepCollectionEquality.unordered().hash(custom);

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
