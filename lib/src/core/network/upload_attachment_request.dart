import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:wiredash/src/core/network/wiredash_api.dart';
import 'package:wiredash/src/core/version.dart';

Future<AttachmentId> postUploadAttachment(
  ApiClientContext context,
  String url,
  Uint8List screenshot,
  String? filename,
  MediaType? contentType,
  AttachmentType type,
) async {
  final String mappedType;
  switch (type) {
    case AttachmentType.screenshot:
      mappedType = 'screenshot';
      break;
  }

  final request = MultipartRequest('POST', Uri.parse(url))
    ..headers.addAll({
      'project': context.projectId,
      'secret': context.secret,
      'version': wiredashSdkVersion.toString(),
    })
    ..files.add(
      MultipartFile.fromBytes(
        'file',
        screenshot,
        filename: filename,
        contentType: contentType,
      ),
    )
    ..fields.addAll({
      'type': mappedType,
    });
  final response = await context.send(request);
  if (response.statusCode == 200) {
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return AttachmentId(responseBody['id'] as String);
  }
  context.throwApiError(response);
}

/// The reference id returned by the backend identifying the binary attachment
/// hosted in the wiredash cloud
class AttachmentId {
  final String value;

  AttachmentId(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttachmentId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return 'AttachmentId{$value}';
  }
}

enum AttachmentType {
  screenshot,
}

extension UploadScreenshotApi on WiredashApi {
  /// Uploads an screenshot to the Wiredash image hosting, returning a unique
  /// [AttachmentId]
  Future<AttachmentId> uploadScreenshot(Uint8List screenshot) {
    return uploadAttachment(
      screenshot: screenshot,
      type: AttachmentType.screenshot,
      // TODO generate filename when taking the screenshot
      filename: 'Screenshot_${DateTime.now().toUtc().toIso8601String()}',
      contentType: MediaType('image', 'png'),
    );
  }
}
