import 'package:wiredash/src/common/device_info/device_info.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item.dart';
import 'package:wiredash/src/version.dart';

/// Contains all relevant feedback information, both user-provided and automatically
/// inferred, that will be eventually sent to the Wiredash console and are in
/// the meantime persisted on disk inside [PendingFeedbackItem].
///
/// Offers [toJson], [PersistedFeedbackItem.fromJson] to serialize the feedback
class PersistedFeedbackItem {
  const PersistedFeedbackItem({
    required this.deviceInfo,
    this.email,
    required this.message,
    required this.type,
    this.user,
    this.sdkVersion = wiredashSdkVersion,
  });

  final DeviceInfo deviceInfo;
  final String? email;
  final String message;
  final String type;
  final String? user;
  final int sdkVersion;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersistedFeedbackItem &&
          runtimeType == other.runtimeType &&
          deviceInfo == other.deviceInfo &&
          email == other.email &&
          message == other.message &&
          type == other.type &&
          user == other.user &&
          sdkVersion == other.sdkVersion;

  @override
  int get hashCode =>
      deviceInfo.hashCode ^
      email.hashCode ^
      message.hashCode ^
      type.hashCode ^
      user.hashCode ^
      sdkVersion.hashCode;

  @override
  String toString() {
    return 'FeedbackItem{'
        'deviceInfo: $deviceInfo, '
        'email: $email, '
        'message: $message, '
        'type: $type, '
        'user: $user, '
        'sdkVersion: $sdkVersion, '
        '}';
  }
}
