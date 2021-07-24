import 'package:wiredash/src/common/build_info/app_info.dart';
import 'package:wiredash/src/common/build_info/build_info.dart';
import 'package:wiredash/src/common/device_info/device_info.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item.dart';
import 'package:wiredash/src/version.dart';

export 'package:wiredash/src/common/build_info/app_info.dart';
export 'package:wiredash/src/common/build_info/build_info.dart';
export 'package:wiredash/src/common/device_info/device_info.dart';

/// Contains all relevant feedback information, both user-provided and automatically
/// inferred, that will be eventually sent to the Wiredash console and are in
/// the meantime persisted on disk inside [PendingFeedbackItem].
///
/// Actual serialization happens in [PendingFeedbackItem]
class PersistedFeedbackItem {
  const PersistedFeedbackItem({
    required this.deviceInfo,
    required this.appInfo,
    required this.buildInfo,
    required this.deviceId,
    this.email,
    required this.message,
    required this.type,
    this.userId,
    this.sdkVersion = wiredashSdkVersion,
  });

  final DeviceInfo deviceInfo;
  final AppInfo appInfo;
  final BuildInfo buildInfo;
  final String deviceId;
  final String? email;
  final String message;
  final String type;
  final String? userId;
  final int sdkVersion;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersistedFeedbackItem &&
          runtimeType == other.runtimeType &&
          deviceInfo == other.deviceInfo &&
          appInfo == other.appInfo &&
          email == other.email &&
          message == other.message &&
          type == other.type &&
          userId == other.userId &&
          sdkVersion == other.sdkVersion;

  @override
  int get hashCode =>
      deviceInfo.hashCode ^
      appInfo.hashCode ^
      email.hashCode ^
      message.hashCode ^
      type.hashCode ^
      userId.hashCode ^
      sdkVersion.hashCode;

  @override
  String toString() {
    return 'FeedbackItem{'
        'deviceInfo: $deviceInfo, '
        'appInfo: $appInfo, '
        'email: $email, '
        'message: $message, '
        'type: $type, '
        'userId: $userId, '
        'sdkVersion: $sdkVersion, '
        '}';
  }
}
