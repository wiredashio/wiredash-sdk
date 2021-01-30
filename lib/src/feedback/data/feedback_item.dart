import 'dart:convert';

import 'package:wiredash/src/common/device_info/device_info.dart';
import 'package:wiredash/src/version.dart';

/// Contains all relevant feedback information, both user-provided and automatically
/// inferred, that will be eventually sent to the Wiredash console.
class FeedbackItem {
  const FeedbackItem({
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

  FeedbackItem.fromJson(Map<String, dynamic> json)
      : deviceInfo =
            DeviceInfo.fromJson(json['deviceInfo'] as Map<String, dynamic>),
        email = json['email'] as String?,
        message = json['message'] as String,
        type = json['type'] as String,
        user = json['user'] as String?,
        sdkVersion = json['sdkVersion'] as int;

  Map<String, dynamic> toJson() {
    return {
      'deviceInfo': deviceInfo.toJson(),
      'email': email,
      'message': message,
      'type': type,
      'user': user,
      'sdkVersion': sdkVersion,
    };
  }

  /// Encodes the fields for a multipart/form-data request
  Map<String, String?> toMultipartFormFields() {
    return {
      'deviceInfo': json.encode(deviceInfo.toJson()),
      'email': email,
      'message': message,
      'type': type,
      'user': user,
      'sdkVersion': sdkVersion.toString(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedbackItem &&
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
