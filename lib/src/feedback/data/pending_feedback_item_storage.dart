import 'dart:async';
import 'dart:convert';

import 'package:file/file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/_wiredash_internal.dart';

/// A temporary place for [PersistedFeedbackItem] classes and user-generated
/// screenshot to sit in until they get sent into the Wiredash console.
class PendingFeedbackItemStorage {
  PendingFeedbackItemStorage({
    required FileSystem fileSystem,
    required Future<SharedPreferences> Function() sharedPreferencesProvider,
    required Future<String> Function() dirPathProvider,
    required UidGenerator idGenerator,
  })  : _fs = fileSystem,
        _sharedPreferences = sharedPreferencesProvider,
        _getScreenshotStorageDirectoryPath = dirPathProvider,
        _idGenerator = idGenerator;

  final FileSystem _fs;
  final Future<SharedPreferences> Function() _sharedPreferences;
  final Future<String> Function() _getScreenshotStorageDirectoryPath;
  final UidGenerator _idGenerator;

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
  Future<PendingFeedbackItem> addPendingItem(FeedbackItem item) async {
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
        final uniqueFileName = _idGenerator.screenshotFilename();
        final filePath = _fs.path
            .normalize(_fs.path.join(screenshotsDir, '$uniqueFileName.png'));
        final data = attachment.file.binaryData(_fs)!;
        await _fs.file(filePath).writeAsBytes(data);
        serializedAttachments.add(
          attachment.copyWith(file: FileDataEventuallyOnDisk.file(filePath)),
        );
      }
    }
    final serializable = item.copyWith(attachments: serializedAttachments);

    final pendingItem = PendingFeedbackItem(
      id: _idGenerator.localFeedbackId(),
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
    await _mutatePendingItems((list) async {
      final removed = list.firstWhere((e) => e.id == item.id);
      list.remove(removed);
      list.add(item);

      final List<PersistedAttachment> oldDiskAttachments = removed
          .feedbackItem.attachments
          .where((element) => element.file.isOnDisk)
          .toList();
      final newDiskAttachments = item.feedbackItem.attachments
          .where((element) => element.file.isOnDisk)
          .toList();
      final uploaded = oldDiskAttachments
          .where((element) => !newDiskAttachments.contains(element))
          .toList();

      /// Delete local files of attachments that have been uploaded
      for (final u in uploaded) {
        final screenshot = _fs.file(u.file.pathToFile);
        if (await screenshot.exists()) {
          await screenshot.delete();
        }
      }
    });
  }

  Future<void> _mutatePendingItems(
    FutureOr<void> Function(List<PendingFeedbackItem>) block,
  ) async {
    final items = List.of(await retrieveAllPendingItems());
    await block(items);
    await _savePendingItems(items);
  }

  Future<void> _savePendingItems(List<PendingFeedbackItem> items) async {
    final preferences = await _sharedPreferences();
    final List<String> values =
        items.map((it) => serializePendingFeedbackItem(it)).toList();
    await preferences.setStringList(_feedbackItemsKey, values);
  }

  Future<bool> contains(String id) async {
    final items = await retrieveAllPendingItems();
    return items.map((it) => it.id).contains(id);
  }
}
