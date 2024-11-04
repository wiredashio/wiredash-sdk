// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:convert';

import 'package:http/http.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/network/serializers.dart';
import 'package:wiredash/src/core/version.dart';
import 'package:wiredash/src/feedback/data/feedback_item.dart';

Future<void> postSendFeedback(
  ApiClientContext context,
  String url,
  FeedbackItem feedback,
) async {
  final uri = Uri.parse(url);
  final Request request = Request('POST', uri);

  request.headers.addAll({
    'Content-Type': 'application/json',
    'project': context.projectId,
    'secret': context.secret,
    'version': wiredashSdkVersion.toString(),
  });

  final body = feedback.toRequestJson();
  request.body = jsonEncode(body);

  final response = await context.send(request);
  if (response.statusCode == 200) {
    // success 🎉
    return;
  }
  context.throwApiError(response);
}

extension FeedbackBody on FeedbackItem {
  Map<String, dynamic> toRequestJson() {
    final Map<String, Object> values = {};

    // Values are sorted alphabetically for easy comparison with the backend
    if (attachments != null && attachments!.isNotEmpty) {
      final items = attachments!.map((it) {
        if (it is Screenshot) {
          return it.file.attachmentId!.value;
        } else {
          throw "Unsupported attachment type ${it.runtimeType}";
        }
      }).toList();
      values.addAll({'attachments': items});
    }

    final _labels = labels;
    if (_labels != null) {
      values.addAll({'labels': _labels});
    }

    values.addAll({'feedbackId': feedbackId});

    values.addAll({'message': nonNull(message)});

    values.addAll({'metadata': metadata.toRequestJson()});

    return values.map((k, v) => MapEntry(k, v));
  }
}
