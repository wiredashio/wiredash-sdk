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
          const DeepCollectionEquality.unordered().equals(custom, other.custom);

  @override
  int get hashCode =>
      userId.hashCode ^
      userEmail.hashCode ^
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
    if (custom != defaultArgument && custom != null) {
      metaData.custom = custom as Map<String, Object?>;
    } else {
      metaData.custom = this.custom;
    }
    return metaData;
  }
}
