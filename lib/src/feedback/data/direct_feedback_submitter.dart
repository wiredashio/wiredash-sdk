import 'dart:typed_data';

import 'package:wiredash/src/common/network/wiredash_api.dart';
import 'package:wiredash/src/common/utils/error_report.dart';
import 'package:wiredash/src/feedback/data/feedback_item.dart';
import 'package:wiredash/src/feedback/data/feedback_submitter.dart';

/// Submits feedback immediately to the wiredash backend
class DirectFeedbackSubmitter implements FeedbackSubmitter {
  DirectFeedbackSubmitter(WiredashApi api) : _api = api;

  final WiredashApi _api;

  @override
  Future<void> submit(FeedbackItem item, Uint8List? screenshot) async {
    try {
      await _api.sendFeedback(feedback: item, screenshot: screenshot);
      // ignore: avoid_print
      print("Feedback submitted ✌️ ${item.message}");
    } on UnauthenticatedWiredashApiException catch (e, stack) {
      // Project configuration is off, retry at next app start
      reportWiredashError(e, stack,
          'Wiredash project configuration is wrong, next retry after next app start');
      rethrow;
    } on WiredashApiException catch (e, stack) {
      if (e.message != null &&
          e.message!.contains("fails because") &&
          e.message!.contains("is required")) {
        // some required property is missing. The item will never be delivered
        // to the server, therefore discard it.
        reportWiredashError(e, stack,
            'Feedback has missing properties and can not be submitted to server');
        rethrow;
      }
      reportWiredashError(
          e, stack, 'Wiredash server error. Will retry after app restart');
      rethrow;
    }
  }
}
