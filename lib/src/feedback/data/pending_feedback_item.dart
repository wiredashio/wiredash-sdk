import 'dart:collection';
import 'dart:convert';
import 'dart:ui';

import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/feedback/_feedback.dart';
import 'package:wiredash/src/metadata/build_info/app_info.dart';
import 'package:wiredash/src/metadata/build_info/build_info.dart';
import 'package:wiredash/src/metadata/device_info/device_info.dart';

const int _serializationVersion = 2;

/// Represents a [PersistedFeedbackItem] that has not yet been submitted,
/// and that has been saved in the persistent storage.
class PendingFeedbackItem {
  const PendingFeedbackItem({
    required this.id,
    required this.feedbackItem,
  });

  final String id;
  final PersistedFeedbackItem feedbackItem;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingFeedbackItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          feedbackItem == other.feedbackItem;

  @override
  int get hashCode => id.hashCode ^ feedbackItem.hashCode;

  @override
  String toString() {
    return 'PendingFeedbackItem{\n'
        'id: $id,\n'
        'feedbackItem: $feedbackItem\n'
        '}';
  }

  PendingFeedbackItem copyWith({
    String? id,
    PersistedFeedbackItem? feedbackItem,
  }) {
    return PendingFeedbackItem(
      id: id ?? this.id,
      feedbackItem: feedbackItem ?? this.feedbackItem,
    );
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
  if (version <= 1) {
    throw 'Ignore outdated serialization version $version';
  }
  if (version == 2) {
    return PendingFeedbackItemParserV2.fromJson(map);
  }
  throw 'Unknown version "$version" of PendingFeedbackItem';
}

/// Serializes feedbacks to json
String serializePendingFeedbackItem(PendingFeedbackItem item) {
  final json = item.toJson();
  return jsonEncode(json);
}

class PendingFeedbackItemParserV2 {
  static FlutterDeviceInfo _parseDeviceInfo(Map deviceInfoJson) {
    final physicalSize = deviceInfoJson['physicalSize'] as List<dynamic>;
    final physicalGeometry =
        deviceInfoJson['physicalGeometry'] as List<dynamic>;
    return FlutterDeviceInfo(
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
  }

  static PendingFeedbackItem fromJson(Map json) {
    final feedbackItemJson = json['feedbackItem'] as Map<dynamic, dynamic>;

    final deviceInfoJson =
        feedbackItemJson['deviceInfo'] as Map<dynamic, dynamic>;
    final deviceInfo = _parseDeviceInfo(deviceInfoJson);

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
    final attachments =
        (feedbackItemJson['attachments'] as List<dynamic>?)?.map((item) {
      final map = item as Map<dynamic, dynamic>;
      final path = map['path'] as String?;
      final attachmentId = map['id'] as String?;
      final file = path != null
          ? FileDataEventuallyOnDisk.file(path)
          : FileDataEventuallyOnDisk.uploaded(
              AttachmentId(attachmentId!),
            );
      final deviceInfoJson = map['deviceInfo'] as Map;
      return PersistedAttachment.screenshot(
        file: file,
        deviceInfo: _parseDeviceInfo(deviceInfoJson),
      );
    }).toList();

    final feedbackItem = PersistedFeedbackItem(
      appInfo: appInfo,
      buildInfo: buildInfo,
      customMetaData: (feedbackItemJson['customMetaData'] as Map?)?.map(
        (key, value) => MapEntry(key.toString(), jsonDecode(value.toString())),
      ),
      deviceInfo: deviceInfo,
      deviceId: feedbackItemJson['deviceId'] as String,
      email: feedbackItemJson['email'] as String?,
      message: feedbackItemJson['message'] as String,
      sdkVersion: feedbackItemJson['sdkVersion'] as int,
      labels: (feedbackItemJson['labels'] as List<dynamic>?)
          ?.map((it) => it as String)
          .toList(),
      userId: feedbackItemJson['userId'] as String?,
      attachments: attachments ?? [],
    );

    return PendingFeedbackItem(
      id: json['id'] as String,
      feedbackItem: feedbackItem,
    );
  }
}

/// Visible for testing
extension SerializePendingFeedbackItem on PendingFeedbackItem {
  Map<String, dynamic> toJson() {
    return SplayTreeMap.from({
      'id': id,
      'feedbackItem': feedbackItem.toJson(),
      'version': _serializationVersion,
    });
  }
}

extension _SerializePersistedFeedbackItem on PersistedFeedbackItem {
  Map<String, dynamic> toJson() {
    return SplayTreeMap.from({
      if (attachments.isNotEmpty)
        'attachments': attachments.map((it) => it.toJson()).toList(),
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
      if (customMetaData != null)
        'customMetaData': _serializedMetaData(customMetaData!),
      'message': message,
      if (userId != null) 'userId': userId,
      'sdkVersion': sdkVersion,
    });
  }

  Map<String, Object> _serializedMetaData(Map<String, Object?> metaData) {
    final data = metaData.map((key, value) {
      try {
        return MapEntry(key, jsonEncode(value));
      } catch (e, stack) {
        reportWiredashError(
          e,
          stack,
          'Could not serialize customMetaData property '
          '$key=${value.toString()}',
        );
        return MapEntry(key, null);
      }
    });
    data.removeWhere((key, value) => value == null);
    return SplayTreeMap.from(data);
  }
}

extension _SerializePersistedAttachment on PersistedAttachment {
  Map<String, dynamic> toJson() {
    final values = SplayTreeMap<String, dynamic>.from({});

    if (file.isInMemomry) {
      throw 'Can not serialize in memory files';
    }
    if (file.isOnDisk) {
      values.addAll({'path': file.pathToFile!});
    }
    if (file.isUploaded) {
      values.addAll({'id': file.attachmentId!.value});
    }
    if (this is Screenshot) {
      final screenshot = this as Screenshot;
      values.addAll({'deviceInfo': screenshot.deviceInfo.toJson()});
    }
    return values;
  }
}

extension _SerializeDeviceInfo on FlutterDeviceInfo {
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

/// [WindowPadding] doesn't offer a public constructor and doesn't implement
/// ==() and hashCode
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

  factory WiredashWindowPadding.fromWindowPadding(WindowPadding padding) {
    return WiredashWindowPadding(
      left: padding.left,
      top: padding.top,
      right: padding.right,
      bottom: padding.bottom,
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
