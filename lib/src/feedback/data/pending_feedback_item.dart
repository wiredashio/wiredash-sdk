import 'dart:collection';
import 'dart:convert';
import 'dart:ui';

import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item_parser_v2.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item_parser_v3.dart';
import 'package:wiredash/src/metadata/meta_data_collector.dart';

const int _serializationVersion = 3;

/// Represents a [PersistedFeedbackItem] that has not yet been submitted,
/// and that has been saved in the persistent storage.
class PendingFeedbackItem {
  const PendingFeedbackItem({
    required this.id,
    required this.feedbackItem,
  });

  final String id;
  final FeedbackItem feedbackItem;

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
    FeedbackItem? feedbackItem,
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
  if (version == 3) {
    return PendingFeedbackItemParserV3.fromJson(map);
  }
  throw 'Unknown version "$version" of PendingFeedbackItem';
}

/// Serializes feedbacks to json
String serializePendingFeedbackItem(PendingFeedbackItem item) {
  final json = item.toJson();
  return jsonEncode(json);
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

extension _SerializePersistedFeedbackItem on FeedbackItem {
  Map<String, dynamic> toJson() {
    return SplayTreeMap.from({
      if (attachments.isNotEmpty)
        'attachments': attachments.map((it) => it.toJson()).toList(),
      'appInfo': appInfo.toJson(),
      'buildInfo': this.buildInfo.toJson(),
      'deviceId': deviceId,
      'deviceInfo': deviceInfo.toJson(),
      if (email != null) 'email': email,
      'flutterInfo': flutterInfo.toJson(),
      if (labels != null) 'labels': labels,
      'sessionMetadata': sessionMetadata.toJson(),
      'message': message,
      'sdkVersion': sdkVersion,
    });
  }
}

extension on BuildInfo {
  Map<String, dynamic> toJson() {
    return SplayTreeMap.from({
      'compilationMode': compilationMode.jsonEncode(),
      if (buildVersion != null) 'buildVersion': buildVersion,
      if (buildNumber != null) 'buildNumber': buildNumber,
      if (buildCommit != null) 'buildCommit': buildCommit,
    });
  }
}

extension on AppInfo {
  Map<String, dynamic> toJson() {
    return SplayTreeMap.from({
      if (appName != null) 'appName': appName,
      if (buildNumber != null) 'buildNumber': buildNumber,
      if (bundleId != null) 'bundleId': bundleId,
      if (version != null) 'version': version,
    });
  }
}

extension on SessionMetaData {
  Map<String, dynamic> toJson() {
    return SplayTreeMap.from({
      if (userId != null) 'userId': userId,
      if (userEmail != null) 'userEmail': userEmail,
      if (buildVersion != null) 'buildVersion': buildVersion,
      if (buildNumber != null) 'buildNumber': buildNumber,
      if (buildCommit != null) 'buildCommit': buildCommit,
      if (appLocale != null) 'appLocale': appLocale,
      if (custom.isNotEmpty) 'custom': _serializedCustomMetaData(custom),
    });
  }

  Map<String, Object> _serializedCustomMetaData(Map<String, Object?> metaData) {
    final data = metaData.map((key, value) {
      try {
        return MapEntry(key, jsonEncode(value));
      } catch (e, stack) {
        reportWiredashError(
          e,
          stack,
          'Could not serialize customMetaData property '
          '$key=$value',
        );
        return MapEntry(key, null);
      }
    });
    data.removeWhere((key, value) => value == null);
    return SplayTreeMap.from(data);
  }
}

extension on DeviceInfo {
  Map<String, dynamic> toJson() {
    return SplayTreeMap.from({
      if (deviceModel != null) 'deviceModel': deviceModel,
    });
  }
}

extension on PersistedAttachment {
  Map<String, dynamic> toJson() {
    final values = SplayTreeMap<String, dynamic>.from({});

    if (file.isInMemory) {
      throw 'Can not serialize in memory files';
    }
    if (file.isOnDisk) {
      values.addAll({'path': file.pathToFile});
    }
    if (file.isUploaded) {
      values.addAll({'id': file.attachmentId!.value});
    }
    return values;
  }
}

extension on FlutterInfo {
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

/// WindowPadding doesn't offer a public constructor and doesn't implement
/// ==() and hashCode
// Remove when we drop support for Flutter v3.8.0-14.0.pre.
// ignore: deprecated_member_use
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

  // Remove when we drop support for Flutter v3.8.0-14.0.pre.
  // ignore: deprecated_member_use
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

// Remove when we drop support for Flutter v3.8.0-14.0.pre.
// ignore: deprecated_member_use
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
