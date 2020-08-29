import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:file/file.dart';
import 'package:wiredash/src/common/network/network_manager.dart';
import 'package:wiredash/src/feedback/data/feedback_item.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item_storage.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item.dart';

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
  bool _resubmitWhenCompleted = false;

  Future<void> submit(FeedbackItem item, Uint8List screenshot) async {
    await _pendingFeedbackItemStorage.persistItem(item, screenshot);

    // Intentionally not "await"-ed. Since we've persisted the pending feedback
    // item, we can pretty safely assume it's going to be eventually sent.
    submitPendingFeedbackItems();
  }

  Future<void> submitPendingFeedbackItems({bool isResubmit = false}) async {
    if (_submitting) {
      _resubmitWhenCompleted = true;
      return;
    }

    _submitting = true;

    final items = await _pendingFeedbackItemStorage.retrieveAllPendingItems();
    if (items != null) {
      for (final item in items) {
        await _submitWithRetry(item);
      }
    }

    _submitting = false;

    if (!isResubmit && _resubmitWhenCompleted) {
      _resubmitWhenCompleted = false;
      await submitPendingFeedbackItems(isResubmit: true);
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
      attempt++; // first invocation is the first attempt

      try {
        await _networkManager.sendFeedback(feedback, screenshot);
        await _pendingFeedbackItemStorage.clearPendingItem(item);
        assert(() {
          print(
            '[Wiredash]: Feedback [id:${item.id}] sent successfully!',
          );
          return true;
        }());
        break;
      } catch (_) {
        if (attempt >= _maxAttempts) {
          assert(() {
            print(
              '[Wiredash]: Tried to send feedback [id:${item.id}] $attempt times. Will try '
              'again some other time.',
            );
            return true;
          }());
          break;
        }

        assert(() {
          print(
            '[Wiredash]: Could not send feedback [id:${item.id}]. Will retry again after a while. Attempts: $attempt',
          );
          return true;
        }());
      }

      // Sleep for a delay
      await Future.delayed(_delay(attempt));
    }
  }
}

const _delayFactor = Duration(seconds: 1);
const _maxDelay = Duration(seconds: 30);
const _maxAttempts = 8;

Duration _delay(int attempt) {
  if (attempt <= 0) return const Duration(milliseconds: 75);
  final exp = math.min(attempt, 31); // prevent overflows.
  final delay = _delayFactor * math.pow(2.0, exp);
  return delay < _maxDelay ? delay : _maxDelay;
}
