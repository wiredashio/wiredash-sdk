import 'dart:collection';
import 'dart:convert';

import 'package:wiredash/src/common/build_info/app_info.dart';
import 'package:wiredash/src/common/build_info/build_info.dart';
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

/// Deserializes feedbacks from json
///
/// Crashes hard when parsing fails
PendingFeedbackItem deserializePendingFeedbackItem(String json) {
  final map = jsonDecode(json) as Map;
  final version = map['version'] as int?;
  if (version == null) {
    // initial version, which doesn't contain all required values.
    throw "Can't parse feedback without version";
  }
  if (version == 1) {
    return PendingFeedbackItemParserV1.fromJson(map);
  }
  throw 'Unknown version "$version" of PendingFeedbackItem';
}

String serializePendingFeedbackItem(PendingFeedbackItem item) {
  final json = item.toJson();
  return jsonEncode(json);
}

class PendingFeedbackItemParserV1 {
  static PendingFeedbackItem fromJson(Map json) {
    final feedbackItemJson = json['feedbackItem'] as Map<dynamic, dynamic>;

    final deviceInfoJson =
        feedbackItemJson['deviceInfo'] as Map<dynamic, dynamic>;
    final deviceInfo = DeviceInfo(
      gestureInsets: (deviceInfoJson['gestureInsets'] as List<dynamic>?)
          ?.cast<num>()
          .map((i) => i.toDouble())
          .toList(growable: false),
      platformLocale: deviceInfoJson['platformLocale'] as String,
      platformSupportedLocales:
          (deviceInfoJson['platformSupportedLocales'] as List<dynamic>)
              .cast<String>(),
      padding: (deviceInfoJson['padding'] as List<dynamic>?)
          ?.cast<num>()
          .map((i) => i.toDouble())
          .toList(growable: false),
      platformBrightness: () {
        final value = deviceInfoJson['platformBrightness'];
        if (value == 'light') return Brightness.light;
        if (value == 'dark') return Brightness.dark;
        throw 'Unknown brightness value $value';
      }(),
      physicalSize: (deviceInfoJson['physicalSize'] as List<dynamic>)
          .cast<num>()
          .map((i) => i.toDouble())
          .toList(growable: false),
      pixelRatio: (deviceInfoJson['pixelRatio'] as num).toDouble(),
      platformOS: deviceInfoJson['platformOS'] as String?,
      platformOSVersion: deviceInfoJson['platformOSBuild'] as String?,
      platformVersion: deviceInfoJson['platformVersion'] as String?,
      textScaleFactor: (deviceInfoJson['textScaleFactor'] as num).toDouble(),
      viewInsets: (deviceInfoJson['viewInsets'] as List<dynamic>?)
          ?.cast<num>()
          .map((i) => i.toDouble())
          .toList(growable: false),
      userAgent: deviceInfoJson['userAgent'] as String?,
    );

    final buildInfoJson =
        feedbackItemJson['buildInfo'] as Map<dynamic, dynamic>? ?? {};
    final buildInfo = BuildInfo(
      buildCommit: buildInfoJson['buildCommit'] as String?,
      buildNumber: buildInfoJson['buildNumber'] as String?,
      buildVersion: buildInfoJson['buildVersion'] as String?,
    );

    final appInfoJson = feedbackItemJson['appInfo'] as Map<dynamic, dynamic>;
    final appInfo = AppInfo(
      appIsDebug: appInfoJson['appIsDebug'] as bool,
      appLocale: appInfoJson['appLocale'] as String,
    );
    final feedbackItem = PersistedFeedbackItem(
      appInfo: appInfo,
      buildInfo: buildInfo,
      deviceInfo: deviceInfo,
      deviceId: feedbackItemJson['deviceId'] as String,
      email: feedbackItemJson['email'] as String?,
      message: feedbackItemJson['message'] as String,
      sdkVersion: feedbackItemJson['sdkVersion'] as int,
      type: feedbackItemJson['type'] as String,
      user: feedbackItemJson['user'] as String?,
    );

    return PendingFeedbackItem(
      id: json['id'] as String,
      feedbackItem: feedbackItem,
      screenshotPath: json['screenshotPath'] as String?,
    );
  }
}

/// Visible for testing
extension SerializePendingFeedbackItem on PendingFeedbackItem {
  Map<String, dynamic> toJson() {
    return SplayTreeMap.from({
      'id': id,
      'feedbackItem': feedbackItem.toJson(),
      if (screenshotPath != null) 'screenshotPath': screenshotPath,
      'version': _serializationVersion,
    });
  }
}

/// Visible for testing
extension SerializePersistedFeedbackItem on PersistedFeedbackItem {
  Map<String, dynamic> toJson() {
    return SplayTreeMap.from({
      'deviceInfo': deviceInfo.toJson(),
      'appInfo': SplayTreeMap.from({
        'appIsDebug': appInfo.appIsDebug,
        'appLocale': appInfo.appLocale,
      }),
      'buildInfo': SplayTreeMap.from({
        if (buildInfo.buildVersion != null)
          'buildVersion': buildInfo.buildVersion,
        if (buildInfo.buildNumber != null) 'buildNumber': buildInfo.buildNumber,
        if (buildInfo.buildCommit != null) 'buildCommit': buildInfo.buildCommit,
      }),
      'deviceId': deviceId,
      if (email != null) 'email': email,
      'message': message,
      'type': type,
      if (user != null) 'user': user,
      'sdkVersion': sdkVersion,
    });
  }
}

/// Visible for testing
extension SerializeDeviceInfo on DeviceInfo {
  Map<String, dynamic> toJson() {
    final values = SplayTreeMap<String, dynamic>.from({});

    values['platformLocale'] = platformLocale;

    values['platformSupportedLocales'] = platformSupportedLocales;

    if (padding != null && padding!.isNotEmpty) {
      values['padding'] = padding;
    }

    if (physicalSize.isNotEmpty) {
      values['physicalSize'] = physicalSize;
    }

    values['pixelRatio'] = pixelRatio;

    if (platformOS != null) {
      values['platformOS'] = platformOS;
    }

    if (platformOSVersion != null) {
      values['platformOSBuild'] = platformOSVersion;
    }

    if (platformVersion != null) {
      values['platformVersion'] = platformVersion;
    }

    values['textScaleFactor'] = textScaleFactor;

    if (viewInsets != null && viewInsets!.isNotEmpty) {
      values['viewInsets'] = viewInsets;
    }

    if (gestureInsets != null && gestureInsets!.isNotEmpty) {
      values['gestureInsets'] = gestureInsets;
    }

    if (userAgent != null) {
      values['userAgent'] = userAgent;
    }

    values['platformBrightness'] = () {
      if (platformBrightness == Brightness.dark) return 'dark';
      if (platformBrightness == Brightness.light) return 'light';
      throw 'Unknown brightness value $platformBrightness';
    }();

    return values;
  }
}
