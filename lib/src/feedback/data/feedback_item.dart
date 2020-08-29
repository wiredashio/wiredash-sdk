import 'package:flutter/foundation.dart';

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

  final String deviceInfo;
  final String email;
  final String message;
  final String type;
  final String user;

  FeedbackItem.fromJson(Map<String, dynamic> json)
      : deviceInfo = json['deviceInfo'] as String,
        email = json['email'] as String,
        message = json['message'] as String,
        type = json['type'] as String,
        user = json['user'] as String;

  Map<String, String> toJson() {
    return {
      'deviceInfo': deviceInfo,
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
