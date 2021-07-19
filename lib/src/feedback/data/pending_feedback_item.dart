import 'dart:convert';

import 'package:wiredash/src/common/device_info/device_info.dart';
import 'package:wiredash/src/feedback/data/persisted_feedback_item.dart';

const int _serializationVersion = 1;

/// Represents a [PersistedFeedbackItem] that has not yet been submitted, and that has
/// been saved in the persistent storage.
class PendingFeedbackItem {
  const PendingFeedbackItem({
    required this.id,
    required this.feedbackItem,
    this.screenshotPath,
  });

  final String id;
  final PersistedFeedbackItem feedbackItem;
  final String? screenshotPath;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingFeedbackItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          feedbackItem == other.feedbackItem &&
          screenshotPath == other.screenshotPath;

  @override
  int get hashCode =>
      id.hashCode ^ feedbackItem.hashCode ^ screenshotPath.hashCode;

  @override
  String toString() {
    return 'PendingFeedbackItem{'
        'id: $id, '
        'feedbackItem: $feedbackItem, '
        'screenshotPath: $screenshotPath, '
        '}';
  }
}

PendingFeedbackItem deserializePendingFeedbackItem(String json) {
  final map = jsonDecode(json) as Map;
  final version = map['version'] as int?;
  if (version == null || version == 1) {
    // V1 is the initial version, where 'version' did not yet exist
    return PendingFeedbackItemParserV1.fromJson(map as Map<String, dynamic>);
  }
  throw 'Unkown version "$version" of PendingFeedbackItem';
}

String serializePendingFeedbackItem(PendingFeedbackItem item) {
  final json = item.toJson();
  return jsonEncode(json);
}

class PendingFeedbackItemParserV1 {
  static PendingFeedbackItem fromJson(Map<String, dynamic> json) {
    return PendingFeedbackItem(
      id: json['id'] as String,
      feedbackItem: PersistedFeedbackItemParserV1.fromJson(
          json['feedbackItem'] as Map<String, dynamic>),
      screenshotPath: json['screenshotPath'] as String?,
    );
  }
}

class PersistedFeedbackItemParserV1 {
  static PersistedFeedbackItem fromJson(Map<String, dynamic> json) {
    return PersistedFeedbackItem(
      deviceInfo: DeviceInfoParserV1.fromJson(
          json['deviceInfo'] as Map<String, dynamic>),
      message: json['message'] as String,
      type: json['type'] as String,
      email: json['email'] as String?,
      user: json['user'] as String?,
      sdkVersion: json['sdkVersion'] as int,
    );
  }
}

class DeviceInfoParserV1 {
  static DeviceInfo fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      appIsDebug: json['appIsDebug'] as bool?,
      appVersion: json['appVersion'] as String?,
      buildNumber: json['buildNumber'] as String?,
      buildCommit: json['buildCommit'] as String?,
      deviceId: json['deviceId'] as String?,
      locale: json['locale'] as String?,
      padding: (json['padding'] as List<dynamic>?)
              ?.cast<num>()
              .map((i) => i.toDouble())
              .toList(growable: false) ??
          [],
      physicalSize: (json['physicalSize'] as List<dynamic>?)
              ?.cast<num>()
              .map((i) => i.toDouble())
              .toList(growable: false) ??
          [],
      pixelRatio: (json['pixelRatio'] as num?)?.toDouble(),
      platformOS: json['platformOS'] as String?,
      platformOSBuild: json['platformOSBuild'] as String?,
      platformVersion: json['platformVersion'] as String?,
      textScaleFactor: (json['textScaleFactor'] as num?)?.toDouble(),
      viewInsets: (json['viewInsets'] as List<dynamic>?)
              ?.cast<num>()
              .map((i) => i.toDouble())
              .toList(growable: false) ??
          [],
      userAgent: json['userAgent'] as String?,
    );
  }
}

/// Visible for testing
extension SerializePendingFeedbackItem on PendingFeedbackItem {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'feedbackItem': feedbackItem.toJson(),
      'screenshotPath': screenshotPath,
      'version': _serializationVersion,
    };
  }
}

/// Visible for testing
extension SerializePersistedFeedbackItem on PersistedFeedbackItem {
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
}

/// Visible for testing
extension SerializeDeviceInfo on DeviceInfo {
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> uiValues = {};

    if (appIsDebug != null) {
      uiValues['appIsDebug'] = appIsDebug;
    }

    if (appVersion != null) {
      uiValues['appVersion'] = appVersion;
    }

    if (buildNumber != null) {
      uiValues['buildNumber'] = buildNumber;
    }

    if (buildCommit != null) {
      uiValues['buildCommit'] = buildCommit;
    }
    if (deviceId != null) {
      uiValues['deviceId'] = deviceId;
    }

    if (locale != null) {
      uiValues['locale'] = locale.toString();
    }

    if (padding != null && padding!.isNotEmpty) {
      uiValues['padding'] = padding;
    }

    if (physicalSize != null && physicalSize!.isNotEmpty) {
      uiValues['physicalSize'] = physicalSize;
    }

    if (pixelRatio != null) {
      uiValues['pixelRatio'] = pixelRatio;
    }

    if (platformOS != null) {
      uiValues['platformOS'] = platformOS;
    }

    if (platformOSBuild != null) {
      uiValues['platformOSBuild'] = platformOSBuild;
    }

    if (platformVersion != null) {
      uiValues['platformVersion'] = platformVersion;
    }

    if (textScaleFactor != null) {
      uiValues['textScaleFactor'] = textScaleFactor;
    }

    if (viewInsets != null && viewInsets!.isNotEmpty) {
      uiValues['viewInsets'] = viewInsets;
    }

    if (userAgent != null) {
      uiValues['userAgent'] = userAgent;
    }

    return uiValues;
  }
}
