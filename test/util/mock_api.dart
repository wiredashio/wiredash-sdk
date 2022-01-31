import 'dart:typed_data';

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
    List<ImageBlob> images = const [],
  }) async {
    return sendFeedbackInvocations
        .addMethodCall(namedArgs: {'images': images}, args: [feedback]);
  }

  @override
  Future<ImageBlob> sendImage(Uint8List screenshot) async {
    return ImageBlob({});
  }
}
