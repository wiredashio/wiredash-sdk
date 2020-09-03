import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:file/file.dart';
import 'package:wiredash/src/common/network/network_manager.dart';
import 'package:wiredash/src/feedback/data/feedback_item.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item_storage.dart';

/// A class that knows how to "eventually send" a [FeedbackItem] and an associated
/// screenshot file, retrying appropriately when sending fails.
class RetryingFeedbackSubmitter {
  RetryingFeedbackSubmitter(
    this.fs,
    this._pendingFeedbackItemStorage,
    this._networkManager,
  );

  final FileSystem fs;
  final PendingFeedbackItemStorage _pendingFeedbackItemStorage;
  final NetworkManager _networkManager;

  // Ensures that we're not starting multiple "submitPendingFeedbackItems()" jobs
  // in parallel.
  bool _submitting = false;

  // Whether or not "submit()" / "submitPendingFeedbackItems()" was called while
  // submitting feedback was already in progress.
  bool _hasLeftoverItems = false;

  /// Persists [item] and [screenshot], then tries to send them.
  ///
  /// If sending fails, uses exponential backoff and tries again up to 7 times.
  Future<void> submit(FeedbackItem item, Uint8List screenshot) async {
    await _pendingFeedbackItemStorage.persistItem(item, screenshot);

    // Intentionally not "await"-ed. Since we've persisted the pending feedback
    // item, we can pretty safely assume it's going to be eventually sent, so the
    // future can complete after persisting the item.
    submitPendingFeedbackItems();
  }

  /// Checks if there are any pending feedback items stored in persistent storage.
  /// If there are, tries to send all of them.
  ///
  /// Can be called whenever there's a good time to try sending pending feedback
  /// items, such as in "initState()" of the Wiredash widget, or when network
  /// connection comes back online.
  Future<void> submitPendingFeedbackItems() => _submitPendingFeedbackItems();

  Future<void> _submitPendingFeedbackItems({
    bool submittingLeftovers = false,
  }) async {
    if (_submitting) {
      _hasLeftoverItems = true;
      return;
    }

    _submitting = true;
    final items = await _pendingFeedbackItemStorage.retrieveAllPendingItems();

    if (items != null) {
      for (final item in items) {
        await _submitWithRetry(item);

        // Some "time to breathe", so that if there's a lot of pending items to
        // send, they're not sent at the same exact moment which could cause
        // some potential jank.
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    _submitting = false;

    if (_hasLeftoverItems) {
      // "submitPendingFeedbackItems()" was called at least once while we were
      // already submitting pending items. This means that there might be some
      // new items to submit.
      _hasLeftoverItems = false;

      if (submittingLeftovers) {
        // We're already submitting leftover items. Let's not get into infinite
        // recursion mode. That would not be fun.
        return;
      }

      await _submitPendingFeedbackItems(submittingLeftovers: true);
    }
  }

  Future<void> _submitWithRetry<T>(PendingFeedbackItem item) async {
    var attempt = 0;

    final feedback = item.feedbackItem;
    final Uint8List screenshot = item.screenshotPath != null
        ? await fs.file(item.screenshotPath).readAsBytes()
        : null;

    // ignore: literal_only_boolean_expressions
    while (true) {
      attempt++;

      try {
        await _networkManager.sendFeedback(feedback, screenshot);
        await _pendingFeedbackItemStorage.clearPendingItem(item);
        break;
      } catch (_) {
        if (attempt >= _maxAttempts) {
          break;
        }
      }

      await Future.delayed(_exponentialBackoff(attempt));
    }
  }
}

const _delayFactor = Duration(seconds: 1);
const _maxDelay = Duration(seconds: 30);
const _maxAttempts = 8;

Duration _exponentialBackoff(int attempt) {
  if (attempt <= 0) return Duration.zero;
  final exp = math.min(attempt, 31);
  final delay = _delayFactor * math.pow(2.0, exp);
  return delay < _maxDelay ? delay : _maxDelay;
}
