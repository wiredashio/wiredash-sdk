import 'dart:math';
import 'dart:typed_data';

import 'package:http_parser/src/media_type.dart';
import 'package:wiredash/src/common/network/wiredash_api.dart';
import 'package:wiredash/src/feedback/data/persisted_feedback_item.dart';

import 'invocation_catcher.dart';

class MockWiredashApi implements WiredashApi {
  List<PersistedFeedbackItem> submissions = [];
  MethodInvocationCatcher sendFeedbackInvocations =
      MethodInvocationCatcher('sendFeedback');

  @override
  Future<void> sendFeedback(
    PersistedFeedbackItem feedback, {
    List<AttachmentId> images = const [],
  }) async {
    return sendFeedbackInvocations
        .addMethodCall(namedArgs: {'images': images}, args: [feedback]);
  }

  @override
  Future<AttachmentId> uploadAttachment({
    required Uint8List screenshot,
    required AttachmentType type,
    String? filename,
    MediaType? contentType,
  }) async {
    return AttachmentId(Random().nextDouble().toString());
  }
}
