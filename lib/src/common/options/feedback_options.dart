import 'package:wiredash/src/feedback/data/label.dart';

class WiredashFeedbackOptions {
  final List<Label>? labels;
  final bool askForUserEmail;

  const WiredashFeedbackOptions({
    this.labels,
    this.askForUserEmail = false,
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
class CustomizableWiredashMetaData {
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
