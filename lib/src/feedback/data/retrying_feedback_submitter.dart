import 'dart:async';
import 'dart:math' as math;

import 'package:file/file.dart';
import 'package:flutter/cupertino.dart';
import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item_storage.dart';

/// A class that knows how to "eventually send" a [PersistedFeedbackItem]
/// and an associated screenshot file, retrying appropriately when sending
/// fails.
class RetryingFeedbackSubmitter implements FeedbackSubmitter {
  RetryingFeedbackSubmitter(
    this.fs,
    this._pendingFeedbackItemStorage,
    this._api,
  );

  final FileSystem fs;
  final PendingFeedbackItemStorage _pendingFeedbackItemStorage;
  final WiredashApi _api;

  // Ensures that we're not starting multiple "submitPendingFeedbackItems()"
  // jobs in parallel.
  bool _submitting = false;

  // Whether or not "submit()" / "submitPendingFeedbackItems()" was called while
  // submitting feedback was already in progress.
  bool _hasLeftoverItems = false;

  /// Persists [item] and [screenshot], then tries to send them.
  ///
  /// If sending fails, uses exponential backoff and tries again up to 7 times.
  @override
  Future<SubmissionState> submit(FeedbackItem item) async {
    final pending = await _pendingFeedbackItemStorage.addPendingItem(item);

    try {
      // Immediately try to submit the feedback
      await _submitWithRetry(pending, maxAttempts: 1);
      final isStillPending =
          await _pendingFeedbackItemStorage.contains(pending.id);
      if (isStillPending) {
        return SubmissionState.pending;
      } else {
        // Only submit remaining feedback when submitting the current one worked
        // Intentionally not "await"-ed. Triggers submission of queued feedback
        // Calling it doesn't affect the return value (in case of error)
        scheduleMicrotask(submitPendingFeedbackItems);

        return SubmissionState.submitted;
      }
    } catch (e) {
      final isStillPending =
          await _pendingFeedbackItemStorage.contains(pending.id);
      if (isStillPending) {
        return SubmissionState.pending;
      }
      rethrow;
    }
  }

  /// Checks if there are any pending feedback items stored in persistent
  /// storage. If there are, tries to send all of them.
  ///
  /// Can be called whenever there's a good time to try sending pending feedback
  /// items, such as in "initState()" of the Wiredash widget, or when network
  /// connection comes back online.
  Future<void> submitPendingFeedbackItems() => _submitPendingFeedbackItems();

  Completer<void>? _pendingCompleter;

  Future<void> _submitPendingFeedbackItems({
    bool submittingLeftovers = false,
  }) async {
    if (_submitting) {
      _hasLeftoverItems = true;
      return _pendingCompleter!.future;
    }

    _submitting = true;
    _pendingCompleter ??= Completer();
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
    _pendingCompleter?.complete(null);
    _pendingCompleter = null;
  }

  Future<void> _submitWithRetry<T>(
    PendingFeedbackItem item, {
    int maxAttempts = 7,
  }) async {
    assert(maxAttempts > 0);
    var attempt = 0;

    // ignore: literal_only_boolean_expressions
    while (true) {
      attempt++;
      try {
        // keep a copy here that always representes the latest state
        PendingFeedbackItem copy = item;

        /// Updates [copy] and [_pendingFeedbackItemStorage] once file is uploaded
        Future<void> updateAttachment(
          PersistedAttachment oldAttachment,
          PersistedAttachment? update,
        ) async {
          final atts = (copy.feedbackItem.attachments?.toList() ?? [])
            ..remove(oldAttachment);
          if (update != null) {
            atts.add(update);
          }
          copy = copy.copyWith(
            feedbackItem: copy.feedbackItem.copyWith(attachments: atts),
          );

          await _pendingFeedbackItemStorage.updatePendingItem(copy);
        }

        for (final attachment in item.feedbackItem.attachments ?? []) {
          if (attachment is Screenshot) {
            final screenshot = attachment.file;
            if (screenshot.isUploaded) {
              continue;
            }
            assert(screenshot.isOnDisk || screenshot.isInMemory);
            if (screenshot.isInMemory) {
              final AttachmentId attachemntId =
                  await _api.uploadScreenshot(screenshot.binaryData(fs)!);

              final uploaded = PersistedAttachment.screenshot(
                file: FileDataEventuallyOnDisk.uploaded(attachemntId),
              );
              await updateAttachment(attachment, uploaded);
            } else if (screenshot.isOnDisk) {
              final file = fs.file(screenshot.pathToFile);
              if (file.existsSync()) {
                final AttachmentId attachemntId =
                    await _api.uploadScreenshot(screenshot.binaryData(fs)!);

                final uploaded = PersistedAttachment.screenshot(
                  file: FileDataEventuallyOnDisk.uploaded(attachemntId),
                );
                await updateAttachment(attachment, uploaded);
              } else {
                // remove item as it doesn't exist on disk anymore
                await updateAttachment(attachment, null);
              }
            }
          }
        }

        // once all feedback is uploaded
        assert(
          (copy.feedbackItem.attachments ?? []).every((it) => it.isUploaded),
        );

        // actually submit the feedback
        await _api.sendFeedback(copy.feedbackItem);

        // ignore: avoid_print
        print(
          'Feedback with ${copy.feedbackItem.attachments?.length ?? 0} screenshots submitted ✌️\n'
          'message: ${copy.feedbackItem.message}',
        );
        await _pendingFeedbackItemStorage.clearPendingItem(item.id);
        break;
      } on UnauthenticatedWiredashApiException catch (e, stack) {
        // Project configuration is off, show error immediately
        reportWiredashError(
          e,
          stack,
          'Wiredash project configuration is wrong, next retry after '
          'next app start',
        );
        await _pendingFeedbackItemStorage.clearPendingItem(item.id);
        rethrow;
      } on WiredashApiException catch (e, stack) {
        if (e.response?.statusCode == 400) {
          // The request is invalid. The feedback will never be delivered
          // to the server, therefore discard it.
          reportWiredashError(
            e,
            stack,
            'Feedback has missing properties and can not be submitted to '
            'server. Will be discarded',
          );
          await _pendingFeedbackItemStorage.clearPendingItem(item.id);
          rethrow;
        }
        reportWiredashInfo(
          e,
          stack,
          'Wiredash server error. Will retry after app restart',
        );
        break;
      } catch (e, stack) {
        if (attempt >= maxAttempts) {
          // Exit after max attempts
          reportWiredashInfo(
            e,
            stack,
            'Could not send feedback after $attempt attempts',
          );
          rethrow;
        }

        // Report error and retry with exponential backoff
        reportWiredashInfo(
          e,
          stack,
          'Could not send feedback to server after $attempt attempts. '
          'Retrying...',
        );
        await Future.delayed(_exponentialBackoff(attempt));
      }
    }
  }

  /// Deletes all pending feedback items and their screenshots.
  Future<void> deletePendingFeedbacks() async {
    final items = await _pendingFeedbackItemStorage.retrieveAllPendingItems();
    if (items.isEmpty) {
      debugPrint('No pending feedbacks');
      return;
    }
    for (final item in items) {
      await _pendingFeedbackItemStorage.clearPendingItem(item.id);
      debugPrint("deleted Feedback ${item.id} '${item.feedbackItem.message}'");
    }
  }
}

const _delayFactor = Duration(seconds: 1);
const _maxDelay = Duration(seconds: 30);

Duration _exponentialBackoff(int attempt) {
  if (attempt <= 0) return Duration.zero;
  final exp = math.min(attempt, 31);
  final delay = _delayFactor * math.pow(2.0, exp);
  return delay < _maxDelay ? delay : _maxDelay;
}
