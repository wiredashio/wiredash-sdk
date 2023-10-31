import 'dart:collection';
import 'dart:convert';

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
