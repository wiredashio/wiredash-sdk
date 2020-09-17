import 'dart:convert';
import 'dart:typed_data';

import 'package:file/file.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    final items = (await _sharedPreferences()).getStringList(_feedbackItemsKey);
    return items == null
        ? <PendingFeedbackItem>[]
        : items
            .map((item) =>
                PendingFeedbackItem.fromJson((json.decode(item) as Map).cast()))
            .toList();
  }

  /// Saves [item] and [screenshot] in the persistent storage.
  ///
  /// If [screenshot] is non-null, saves it in the application documents directory
  /// with a randomly generated filename.
  Future<void> addPendingItem(FeedbackItem item, Uint8List screenshot) async {
    String screenshotPath;

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

    final items = List.of(await retrieveAllPendingItems())..add(pendingItem);
    (await _sharedPreferences()).setStringList(
      _feedbackItemsKey,
      items.map((e) => json.encode(e.toJson())).toList(),
    );

    return pendingItem;
  }

  /// Deletes [itemToClear] and the screenshot associated with (if any) from the
  /// persistent storage.
  Future<void> clearPendingItem(PendingFeedbackItem itemToClear) async {
    final items = await retrieveAllPendingItems();

    if (items != null) {
      for (final item in items) {
        if (item.id == itemToClear.id) {
          if (item.screenshotPath != null) {
            final screenshot = _fs.file(item.screenshotPath);
            if (await screenshot.exists()) {
              await screenshot.delete();
            }
          }

          final updatedItems = List.of(await retrieveAllPendingItems());
          updatedItems.removeWhere((e) => e.id == item.id);
          (await _sharedPreferences()).setStringList(
            _feedbackItemsKey,
            updatedItems.map((e) => json.encode(e.toJson())).toList(),
          );
          break;
        }
      }
    }
  }
}
