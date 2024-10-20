import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/_wiredash_internal.dart';

/// Submits feedback immediately to the wiredash backend
class DirectFeedbackSubmitter implements FeedbackSubmitter {
  DirectFeedbackSubmitter(WiredashApi Function() api) : _api = api;

  final WiredashApi Function() _api;

  @override
  Future<SubmissionState> submit(FeedbackItem item) async {
    try {
      final List<PersistedAttachment> uploadedAttachments = [];

      // Upload screenshots that are not yet uploaded
      for (final attachment in item.attachments ?? []) {
        if (attachment is Screenshot) {
          // simplification: upload all attachments from memory
          final id = await _api().uploadScreenshot(attachment.file.data!);
          final uploaded =
              attachment.copyWith(file: FileDataEventuallyOnDisk.uploaded(id));
          uploadedAttachments.add(uploaded);
        } else {
          throw "Unknown attachment type ${attachment.runtimeType}";
        }
      }

      final updatedItem = item.copyWith(attachments: uploadedAttachments);
      await _api().sendFeedback(updatedItem);

      // ignore: avoid_print
      print('Feedback submitted ✌️ ${item.message}');
      return SubmissionState.submitted;
    } on UnauthenticatedWiredashApiException catch (e, stack) {
      // Project configuration is off, retry at next app start
      reportWiredashError(
        e,
        stack,
        'Wiredash project configuration is wrong, next retry after '
        'next app start',
      );
      rethrow;
    } on WiredashApiException catch (e, stack) {
      if (e.message != null &&
          e.message!.contains('fails because') &&
          e.message!.contains('is required')) {
        // some required property is missing. The item will never be delivered
        // to the server, therefore discard it.
        reportWiredashInfo(
          e,
          stack,
          'Feedback has missing properties and can not be submitted to server',
        );
        rethrow;
      }
      reportWiredashInfo(
        e,
        stack,
        'Wiredash server error. Will retry after app restart',
      );
      rethrow;
    }
  }
}
