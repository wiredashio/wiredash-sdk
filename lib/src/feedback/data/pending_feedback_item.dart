import 'dart:collection';
import 'dart:convert';
import 'dart:ui';

import 'package:wiredash/src/feedback/data/persisted_feedback_item.dart';

const int _serializationVersion = 1;

/// Represents a [PersistedFeedbackItem] that has not yet been submitted,
/// and that has been saved in the persistent storage.
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
    final physicalSize = deviceInfoJson['physicalSize'] as List<dynamic>;
    final physicalGeometry =
        deviceInfoJson['physicalGeometry'] as List<dynamic>;
    final deviceInfo = DeviceInfo(
      gestureInsets: WiredashWindowPadding.fromJson(
        deviceInfoJson['gestureInsets'] as List<dynamic>,
      ),
      platformLocale: deviceInfoJson['platformLocale'] as String,
      platformSupportedLocales:
          (deviceInfoJson['platformSupportedLocales'] as List<dynamic>)
              .cast<String>(),
      padding: WiredashWindowPadding.fromJson(
        deviceInfoJson['padding'] as List<dynamic>,
      ),
      platformBrightness: () {
        final value = deviceInfoJson['platformBrightness'];
        if (value == 'light') return Brightness.light;
        if (value == 'dark') return Brightness.dark;
        throw 'Unknown brightness value $value';
      }(),
      physicalSize: Size(
        (physicalSize[0] as num).toDouble(),
        (physicalSize[1] as num).toDouble(),
      ),
      pixelRatio: (deviceInfoJson['pixelRatio'] as num).toDouble(),
      platformOS: deviceInfoJson['platformOS'] as String?,
      platformOSVersion: deviceInfoJson['platformOSBuild'] as String?,
      platformVersion: deviceInfoJson['platformVersion'] as String?,
      textScaleFactor: (deviceInfoJson['textScaleFactor'] as num).toDouble(),
      viewInsets: WiredashWindowPadding.fromJson(
        deviceInfoJson['viewInsets'] as List<dynamic>,
      ),
      userAgent: deviceInfoJson['userAgent'] as String?,
      physicalGeometry: Rect.fromLTRB(
        (physicalGeometry[0] as num).toDouble(),
        (physicalGeometry[1] as num).toDouble(),
        (physicalGeometry[2] as num).toDouble(),
        (physicalGeometry[3] as num).toDouble(),
      ),
    );

    final buildInfoJson =
        feedbackItemJson['buildInfo'] as Map<dynamic, dynamic>? ?? {};
    final buildInfo = BuildInfo(
      compilationMode: () {
        final mode = buildInfoJson['compilationMode'] as String;
        if (mode == 'debug') return CompilationMode.debug;
        if (mode == 'profile') return CompilationMode.profile;
        return CompilationMode.release;
      }(),
      buildCommit: buildInfoJson['buildCommit'] as String?,
      buildNumber: buildInfoJson['buildNumber'] as String?,
      buildVersion: buildInfoJson['buildVersion'] as String?,
    );

    final appInfoJson = feedbackItemJson['appInfo'] as Map<dynamic, dynamic>;
    final appInfo = AppInfo(
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
      labels: (feedbackItemJson['labels'] as List<dynamic>?)
          ?.map((it) => it as String)
          .toList(),
      userId: feedbackItemJson['userId'] as String?,
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

extension _SerializePersistedFeedbackItem on PersistedFeedbackItem {
  Map<String, dynamic> toJson() {
    return SplayTreeMap.from({
      'deviceInfo': deviceInfo.toJson(),
      'appInfo': SplayTreeMap.from({
        'appLocale': appInfo.appLocale,
      }),
      'buildInfo': SplayTreeMap.from({
        'compilationMode': buildInfo.compilationMode.jsonEncode(),
        if (buildInfo.buildVersion != null)
          'buildVersion': buildInfo.buildVersion,
        if (buildInfo.buildNumber != null) 'buildNumber': buildInfo.buildNumber,
        if (buildInfo.buildCommit != null) 'buildCommit': buildInfo.buildCommit,
      }),
      'deviceId': deviceId,
      if (email != null) 'email': email,
      if (labels != null) 'labels': labels,
      'message': message,
      if (userId != null) 'userId': userId,
      'sdkVersion': sdkVersion,
    });
  }
}

extension _SerializeDeviceInfo on DeviceInfo {
  Map<String, dynamic> toJson() {
    final values = SplayTreeMap<String, dynamic>.from({});

    values['platformLocale'] = platformLocale;
    values['platformSupportedLocales'] = platformSupportedLocales;
    values['padding'] = padding.toJson();
    values['physicalSize'] = physicalSize.toJson();
    values['physicalGeometry'] = physicalGeometry.toJson();
    values['pixelRatio'] = pixelRatio;
    values['platformBrightness'] = platformBrightness.jsonEncode();
    values['textScaleFactor'] = textScaleFactor;

    if (platformOS != null) {
      values['platformOS'] = platformOS;
    }

    if (platformOSVersion != null) {
      values['platformOSBuild'] = platformOSVersion;
    }

    if (platformVersion != null) {
      values['platformVersion'] = platformVersion;
    }

    values['viewInsets'] = viewInsets.toJson();

    values['gestureInsets'] = gestureInsets.toJson();

    if (userAgent != null) {
      values['userAgent'] = userAgent;
    }

    return values;
  }
}

/// [WindowPadding] doesn't offer a public constructor
class WiredashWindowPadding implements WindowPadding {
  const WiredashWindowPadding({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  factory WiredashWindowPadding.fromJson(List json) {
    return WiredashWindowPadding(
      left: (json[0] as num).toDouble(),
      top: (json[1] as num).toDouble(),
      right: (json[2] as num).toDouble(),
      bottom: (json[3] as num).toDouble(),
    );
  }

  /// The distance from the left edge to the first unpadded pixel, in physical
  /// pixels.
  @override
  final double left;

  /// The distance from the top edge to the first unpadded pixel, in physical
  /// pixels.
  @override
  final double top;

  /// The distance from the right edge to the first unpadded pixel, in physical
  /// pixels.
  @override
  final double right;

  /// The distance from the bottom edge to the first unpadded pixel, in physical
  /// pixels.
  @override
  final double bottom;

  @override
  String toString() {
    return 'WiredashWindowPadding{'
        'left: $left, top: $top, right: $right, bottom: $bottom'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WiredashWindowPadding &&
          runtimeType == other.runtimeType &&
          left == other.left &&
          top == other.top &&
          right == other.right &&
          bottom == other.bottom;

  @override
  int get hashCode =>
      left.hashCode ^ top.hashCode ^ right.hashCode ^ bottom.hashCode;
}

extension on WindowPadding {
  List<double> toJson() {
    return [left, top, right, bottom];
  }
}

extension on Rect {
  List<double> toJson() {
    return [left, top, right, bottom];
  }
}

extension on Size {
  List<double> toJson() {
    return [width, height];
  }
}

extension on Brightness {
  String jsonEncode() {
    if (this == Brightness.dark) return 'dark';
    if (this == Brightness.light) return 'light';
    throw 'Unknown brightness value $this';
  }
}

extension on CompilationMode {
  String jsonEncode() {
    switch (this) {
      case CompilationMode.release:
        return 'release';
      case CompilationMode.profile:
        return 'profile';
      case CompilationMode.debug:
        return 'debug';
    }
  }
}
