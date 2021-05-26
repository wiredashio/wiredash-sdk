import 'dart:convert';
import 'dart:typed_data';

import 'package:file/file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/common/utils/error_report.dart';
import 'package:wiredash/src/common/utils/uuid.dart';
import 'package:wiredash/src/feedback/data/feedback_item.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item.dart';

/// A temporary place for [FeedbackItem] classes and user-generated screenshot to
/// sit in until they get sent into the Wiredash console.
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
        // cast may fail for invalid entries
        final map = json.decode(item) as Map<String, dynamic>;
        // parsing may fail for missing required properties
        parsed.add(PendingFeedbackItem.fromJson(map));
      } catch (e, stack) {
        // Usually this happens when we add new required properties without a migration

        // The next time addPendingItem is called, the invalid feedbacks get
        // removed automatically
        reportWiredashError(e, stack, 'Could not parse item from disk $item');
        try {
          // Remove the associated screenshot right now.
          final map = json.decode(item) as Map<String, dynamic>;
          final screenshot = _fs.file(map['screenshotPath']);
          if (await screenshot.exists()) {
            await screenshot.delete();
          }
        } catch (e) {
          reportWiredashError(
              e, stack, 'Could not delete screenshot for invalid item $item');
        }
      }
    }
    return parsed.toList();
  }

  /// Saves [item] and [screenshot] in the persistent storage.
  ///
  /// If [screenshot] is non-null, saves it in the application documents directory
  /// with a randomly generated filename.
  Future<PendingFeedbackItem> addPendingItem(
    FeedbackItem item,
    Uint8List? screenshot,
  ) async {
    String? screenshotPath;

    if (screenshot != null) {
      final directory = await _getScreenshotStorageDirectoryPath();
      final file = await _fs
          .file('$directory/${uuidV4.generate()}.png')
          .writeAsBytes(screenshot);
      screenshotPath = file.path;
    }

    final pendingItem = PendingFeedbackItem(
      id: uuidV4.generate(),
      feedbackItem: item,
      screenshotPath: screenshotPath,
    );

    final all = await retrieveAllPendingItems();
    final items = List.of(all)..add(pendingItem);
    final preferences = await _sharedPreferences();
    preferences.setStringList(_feedbackItemsKey,
        items.map((it) => json.encode(it.toJson())).toList());

    return pendingItem;
  }

  /// Deletes [itemToClear] and the screenshot associated with (if any) from the
  /// persistent storage.
  Future<void> clearPendingItem(String itemId) async {
    final items = await retrieveAllPendingItems();

    for (final item in items) {
      if (item.id == itemId) {
        if (item.screenshotPath != null) {
          final screenshot = _fs.file(item.screenshotPath);
          if (await screenshot.exists()) {
            await screenshot.delete();
          }
        }

        final updatedItems = List.of(await retrieveAllPendingItems());
        updatedItems.removeWhere((e) => e.id == item.id);
        final preferences = await _sharedPreferences();
        await preferences.setStringList(_feedbackItemsKey,
            updatedItems.map((e) => json.encode(e.toJson())).toList());
        break;
      }
    }
  }
}
