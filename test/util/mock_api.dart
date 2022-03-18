import 'dart:math';
import 'dart:typed_data';

import 'package:http_parser/src/media_type.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/network/wiredash_api.dart';
import 'package:wiredash/src/feedback/_feedback.dart';

import 'invocation_catcher.dart';

class MockWiredashApi implements WiredashApi {
  MockWiredashApi();

  factory MockWiredashApi.fake() {
    final api = MockWiredashApi();
    api.uploadAttachmentInvocations.interceptor = (iv) {
      final randomFloat = Random().nextDouble().toString();
      return AttachmentId(randomFloat.replaceFirst('0.', ''));
    };
    return api;
  }

  final MethodInvocationCatcher sendFeedbackInvocations =
      MethodInvocationCatcher('sendFeedback');

  @override
  Future<void> sendFeedback(PersistedFeedbackItem feedback) async {
    return await sendFeedbackInvocations.addMethodCall(args: [feedback]);
  }

  final MethodInvocationCatcher uploadAttachmentInvocations =
      MethodInvocationCatcher('uploadAttachment');

  @override
  Future<AttachmentId> uploadAttachment({
    required Uint8List screenshot,
    required AttachmentType type,
    String? filename,
    MediaType? contentType,
  }) async {
    final response = await uploadAttachmentInvocations.addMethodCall(
      namedArgs: {
        'screenshot': screenshot,
        'type': type,
        'filename': filename,
        'contentType': contentType,
      },
    );
    if (response != null) {
      return response as AttachmentId;
    }
    throw 'Not mocked';
  }

  final MethodInvocationCatcher sendNpsInvocations =
      MethodInvocationCatcher('sendNps');

  @override
  Future<void> sendNps(NpsRequestBody body) async {
    return await sendNpsInvocations.addMethodCall(args: [body]);
  }
}
