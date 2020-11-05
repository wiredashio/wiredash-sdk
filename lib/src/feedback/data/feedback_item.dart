import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:wiredash/src/common/device_info/device_info.dart';

/// Contains all relevant feedback information, both user-provided and automatically
/// inferred, that will be eventually sent to the Wiredash console.
class FeedbackItem {
  const FeedbackItem({
    @required this.deviceInfo,
    this.email,
    @required this.message,
    @required this.type,
    this.user,
  })  : assert(deviceInfo != null),
        assert(message != null),
        assert(type != null);

  final DeviceInfo deviceInfo;
  final String email;
  final String message;
  final String type;
  final String user;

  FeedbackItem.fromJson(Map<String, dynamic> json)
      : deviceInfo =
            DeviceInfo.fromJson(json['deviceInfo'] as Map<String, dynamic>),
        email = json['email'] as String,
        message = json['message'] as String,
        type = json['type'] as String,
        user = json['user'] as String;

  Map<String, dynamic> toJson() {
    return {
      'deviceInfo': deviceInfo.toJson(),
      'email': email,
      'message': message,
      'type': type,
      'user': user,
    };
  }

  Map<String, String> toMultipartFormFields() {
    return {
      'deviceInfo': json.encode(deviceInfo.toJson()),
      'email': email,
      'message': message,
      'type': type,
      'user': user,
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
          user == other.user;

  @override
  int get hashCode =>
      deviceInfo.hashCode ^
      email.hashCode ^
      message.hashCode ^
      type.hashCode ^
      user.hashCode;
}
