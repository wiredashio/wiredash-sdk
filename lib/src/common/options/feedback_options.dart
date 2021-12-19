import 'dart:async';

import 'package:wiredash/src/feedback/data/label.dart';

class WiredashFeedbackOptions {
  final List<Label>? labels;
  final bool askForUserEmail;
  final FutureOr<void> Function(FeedbackMetaData)? collectMetaData;

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

class FeedbackMetaData {
  String? userId;
  String? userEmail;
  String? buildVersion;
  String? buildNumber;
  String? buildCommit;
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
