import 'dart:convert';
import 'dart:typed_data';

import 'package:file/file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/common/utils/error_report.dart';
import 'package:wiredash/src/common/utils/uuid.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item.dart';
import 'package:wiredash/src/feedback/data/persisted_feedback_item.dart';

/// A temporary place for [PersistedFeedbackItem] classes and user-generated
/// screenshot to sit in until they get sent into the Wiredash console.
class PendingFeedbackItemStorage {
  PendingFeedbackItemStorage(
    this._fs,
    this._sharedPreferences,
    this._getScreenshotStorageDirectoryPath,
  );

  final FileSystem _fs;
  final Future<SharedPreferences> Function() _sharedPreferences;
  final Future<String> Function() _getScreenshotStorageDirectoryPath;

  static const _feedbackItemsKey = 'io.wiredash.pending_feedback_items';

  /// Returns a list of all feedback items and their screenshot paths that are
  /// currently stored in the storage.
  Future<List<PendingFeedbackItem>> retrieveAllPendingItems() async {
    final preferences = await _sharedPreferences();
    final items = preferences.getStringList(_feedbackItemsKey) ?? [];
    final List<PendingFeedbackItem> parsed = [];
    for (final item in items) {
      try {
        // parsing may fail for missing required properties
        parsed.add(deserializePendingFeedbackItem(item));
      } catch (e, stack) {
        // Usually this happens when we add new required properties without
        // a migration

        // The next time addPendingItem is called, the invalid feedbacks get
        // removed automatically
        reportWiredashError(e, stack, 'Could not parse item from disk $item');
        try {
          // Remove the associated screenshot right now.
          // This here is custom parsing and fails when the serialization
          // changes
          final map = jsonDecode(item) as Map<String, dynamic>;
          final screenshot = _fs.file(map['screenshotPath']);
          if (await screenshot.exists()) {
            await screenshot.delete();
          }
        } catch (e) {
          reportWiredashError(
            e,
            stack,
            'Could not delete screenshot for invalid item $item',
          );
        }
      }
    }
    return parsed.toList();
  }

  /// Saves [item] and [screenshot] in the persistent storage.
  ///
  /// If [screenshot] is non-null, saves it in the application documents
  /// directory
  /// with a randomly generated filename.
  Future<PendingFeedbackItem> addPendingItem(PersistedFeedbackItem item) async {
    // Save in-memory images files to disk
    final List<PersistedAttachment> serializedAttachments = [];
    for (final attachment in item.attachments) {
      if (attachment is Screenshot) {
        if (attachment.file.isUploaded) {
          // good already uploaded
          serializedAttachments.add(attachment);
          continue;
        }
        if (attachment.file.isOnDisk) {
          // good already on disk
          serializedAttachments.add(attachment);
          continue;
        }
        // save file to disk
        final screenshotsDir = await _getScreenshotStorageDirectoryPath();
        final file = await _fs
            .file('$screenshotsDir/${uuidV4.generate()}.png')
            .writeAsBytes(attachment.file.binaryData!);
        serializedAttachments.add(
          attachment.copyWith(file: FileDataEventuallyOnDisk.file(file)),
        );
      }
    }
    final serializable = item.copyWith(attachments: serializedAttachments);

    final pendingItem = PendingFeedbackItem(
      id: uuidV4.generate(),
      feedbackItem: serializable,
    );

    await _mutatePendingItems((list) {
      list.add(pendingItem);
    });
    return pendingItem;
  }

  /// Deletes [itemToClear] and the screenshot associated with (if any) from the
  /// persistent storage.
  Future<void> clearPendingItem(String itemId) async {
    final items = await retrieveAllPendingItems();

    for (final item in items) {
      if (item.id == itemId) {
        for (final attachment in item.feedbackItem.attachments) {
          final eventuallyOnDisk = attachment.file;
          if (eventuallyOnDisk.isOnDisk) {
            final screenshot = _fs.file(eventuallyOnDisk.pathToFile);
            if (await screenshot.exists()) {
              await screenshot.delete();
            }
          }
        }

        await _removePendingItem(item);
      }
    }
  }

  Future<void> _removePendingItem(PendingFeedbackItem item) async {
    await _mutatePendingItems((list) {
      list.removeWhere((e) => e.id == item.id);
    });
  }

  /// Replaces the item with the same [PendingFeedbackItem.id]
  Future<void> updatePendingItem(PendingFeedbackItem item) async {
    await _mutatePendingItems((list) {
      list.removeWhere((e) => e.id == item.id);
      list.add(item);
    });
  }

  Future<void> _mutatePendingItems(
    void Function(List<PendingFeedbackItem>) block,
  ) async {
    final items = List.of(await retrieveAllPendingItems());
    block(items);
    await _savePendingItems(items);
  }

  Future<void> _savePendingItems(List<PendingFeedbackItem> items) async {
    final preferences = await _sharedPreferences();
    final List<String> values =
        items.map((it) => serializePendingFeedbackItem(it)).toList();
    await preferences.setStringList(_feedbackItemsKey, values);
  }
}
