import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:file/file.dart';
import 'package:wiredash/src/common/network/wiredash_api.dart';
import 'package:wiredash/src/common/utils/error_report.dart';
import 'package:wiredash/src/feedback/data/feedback_item.dart';
import 'package:wiredash/src/feedback/data/feedback_submitter.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item_storage.dart';

/// A class that knows how to "eventually send" a [FeedbackItem] and an associated
/// screenshot file, retrying appropriately when sending fails.
class RetryingFeedbackSubmitter implements FeedbackSubmitter {
  RetryingFeedbackSubmitter(
    this.fs,
    this._pendingFeedbackItemStorage,
    this._api,
  );

  final FileSystem fs;
  final PendingFeedbackItemStorage _pendingFeedbackItemStorage;
  final WiredashApi _api;

  // Ensures that we're not starting multiple "submitPendingFeedbackItems()" jobs
  // in parallel.
  bool _submitting = false;

  // Whether or not "submit()" / "submitPendingFeedbackItems()" was called while
  // submitting feedback was already in progress.
  bool _hasLeftoverItems = false;

  /// Persists [item] and [screenshot], then tries to send them.
  ///
  /// If sending fails, uses exponential backoff and tries again up to 7 times.
  @override
  Future<void> submit(FeedbackItem item, Uint8List? screenshot) async {
    await _pendingFeedbackItemStorage.addPendingItem(item, screenshot);

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

    for (final item in items) {
      await _submitWithRetry(item).catchError((_) {
        // ignore when a single item couldn't be submitted
        return null;
      });

      // Some "time to breathe", so that if there's a lot of pending items to
      // send, they're not sent at the same exact moment which could cause
      // some potential jank.
      await Future.delayed(const Duration(milliseconds: 100));
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

    // ignore: literal_only_boolean_expressions
    while (true) {
      attempt++;
      try {
        final screenshotPath = item.screenshotPath;
        final Uint8List? screenshot =
            screenshotPath != null && await fs.file(screenshotPath).exists()
                ? await fs.file(screenshotPath).readAsBytes()
                : null;
        await _api.sendFeedback(
            feedback: item.feedbackItem, screenshot: screenshot);
        // ignore: avoid_print
        print("Feedback submitted ✌️ ${item.feedbackItem.message}");
        await _pendingFeedbackItemStorage.clearPendingItem(item.id);
        break;
      } on UnauthenticatedWiredashApiException catch (e, stack) {
        // Project configuration is off, retry at next app start
        reportWiredashError(e, stack,
            'Wiredash project configuration is wrong, next retry after next app start');
        break;
      } on WiredashApiException catch (e, stack) {
        if (e.message != null &&
            e.message!.contains("fails because") &&
            e.message!.contains("is required")) {
          // some required property is missing. The item will never be delivered
          // to the server, therefore discard it.
          reportWiredashError(e, stack,
              'Feedback has missing properties and can not be submitted to server');
          await _pendingFeedbackItemStorage.clearPendingItem(item.id);
          break;
        }
        reportWiredashError(
            e, stack, 'Wiredash server error. Will retry after app restart');
        break;
      } catch (e, stack) {
        if (attempt >= _maxAttempts) {
          // Exit after max attempts
          reportWiredashError(
              e, stack, 'Could not send feedback after $attempt retries');
          break;
        }

        // Report error and retry with exponential backoff
        reportWiredashError(e, stack,
            'Could not send feedback to server after $attempt retries. Retrying...',
            debugOnly: true);
        await Future.delayed(_exponentialBackoff(attempt));
      }
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
