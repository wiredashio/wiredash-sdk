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
      if (labels != null) 'labels': labels,
      'message': message,
      'metadata': metadata.toJson(),
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
