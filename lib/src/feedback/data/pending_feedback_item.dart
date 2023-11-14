// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:collection';
import 'dart:convert';
import 'dart:ui';

import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item_parser_v2.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item_parser_v3.dart';

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
      if (attachments != null && attachments!.isNotEmpty)
        'attachments': attachments!.map((it) => it.toJson()).toList(),
      'feedbackId': feedbackId,
      if (labels != null) 'labels': labels,
      'metadata': metadata.toJson(),
      'message': message,
    });
  }
}

extension on AllMetaData {
  Map<String, Object?> toJson() {
    final Map<String, Object> values = SplayTreeMap.from({});

    // Values are sorted alphabetically for easy comparison with the backend
    final _appLocale = appLocale;
    if (_appLocale != null) {
      values.addAll({'appLocale': _appLocale});
    }

    final _appName = appName;
    if (_appName != null) {
      values.addAll({'appName': _appName});
    }

    final _buildCommit = buildCommit;
    if (_buildCommit != null) {
      values.addAll({'buildCommit': _buildCommit});
    }

    final _buildNumber = buildNumber;
    if (_buildNumber != null) {
      values.addAll({'buildNumber': _buildNumber});
    }

    final _buildVersion = buildVersion;
    if (_buildVersion != null) {
      values.addAll({'buildVersion': _buildVersion});
    }

    final _bundleId = bundleId;
    if (_bundleId != null) {
      values.addAll({'bundleId': _bundleId});
    }

    values.addAll({
      'compilationMode': nonNull(compilationMode.jsonEncode()),
    });

    final customMetaData = custom?.map((key, value) {
      if (value == null) {
        return MapEntry(key, null);
      }
      try {
        // try encoding. We don't care about the actual encoded content because
        // it will be later by the http library encoded
        jsonEncode(value);
        // encoding worked, it's valid data
        return MapEntry(key, value);
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
    if (customMetaData != null) {
      customMetaData.removeWhere((key, value) => value == null);
      if (customMetaData.isNotEmpty) {
        values.addAll({'custom': customMetaData});
      }
    }

    assert(installId.length >= 16);
    values.addAll({'installId': nonNull(installId)});

    final _deviceModel = deviceModel;
    if (_deviceModel != null) {
      values.addAll({'deviceModel': _deviceModel});
    }

    values.addAll({
      'physicalGeometry': nonNull(physicalGeometry).toJson(),
    });

    values.addAll({
      'platformBrightness': nonNull(platformBrightness).jsonEncode(),
    });

    final _platformDartVersion = platformDartVersion;
    if (_platformDartVersion != null) {
      values.addAll({'platformDartVersion': _platformDartVersion});
    }

    values.addAll({
      'platformGestureInsets': nonNull(platformGestureInsets).toJson(),
    });

    values.addAll({'platformLocale': nonNull(platformLocale)});

    final _platformOS = platformOS;
    if (_platformOS != null) {
      values.addAll({'platformOS': _platformOS});
    }

    final _platformOSVersion = platformOSVersion;
    if (_platformOSVersion != null) {
      values.addAll({'platformOSVersion': _platformOSVersion});
    }

    values.addAll({
      'platformSupportedLocales': nonNull(platformSupportedLocales),
    });

    values.addAll({'sdkVersion': nonNull(sdkVersion)});

    final _userEmail = userEmail;
    if (_userEmail != null && _userEmail.isNotEmpty) {
      values.addAll({'userEmail': _userEmail});
    }

    final String? _userId = userId;
    if (_userId != null) {
      values.addAll({'userId': _userId});
    }

    values.addAll({
      'windowInsets': nonNull(windowInsets).toJson(),
    });

    values.addAll({
      'windowPadding': nonNull(windowPadding).toJson(),
    });

    values.addAll({
      'windowPixelRatio': nonNull(windowPixelRatio),
    });

    values.addAll({
      'windowSize': nonNull(windowSize).toJson(),
    });

    values.addAll({
      'windowTextScaleFactor': nonNull(windowTextScaleFactor),
    });

    return values.map((k, v) => MapEntry(k, v));
  }
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
