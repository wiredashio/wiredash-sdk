import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/common/utils/uuid.dart';
import 'package:wiredash/src/feedback/data/feedback_item.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item.dart';

class PendingFeedbackItemStorage {
  PendingFeedbackItemStorage(this._sharedPreferences);
  final Future<SharedPreferences> Function() _sharedPreferences;

  static const _feedbackItemsKey = 'io.wiredash.pending_feedback_items';

  Future<List<PendingFeedbackItem>> retrieveAllPendingItems() async {
    final items = (await _sharedPreferences()).getStringList(_feedbackItemsKey);
    return items == null
        ? <PendingFeedbackItem>[]
        : items
            .map((item) =>
                PendingFeedbackItem.fromJson((json.decode(item) as Map).cast()))
            .toList();
  }

  Future<PendingFeedbackItem> persistItem(
      FeedbackItem item, Uint8List screenshot) async {
    String screenshotPath;

    if (screenshot != null) {
      final directory = await getApplicationDocumentsDirectory();
      final file = await File('${directory.path}/${uuidV4.generate()}.png')
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

  Future<void> clearPendingItem(PendingFeedbackItem itemToClear) async {
    final items = await retrieveAllPendingItems();

    if (items != null) {
      for (final item in items) {
        if (item.id == itemToClear.id) {
          if (item.screenshotPath != null) {
            await File(item.screenshotPath).delete();
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
