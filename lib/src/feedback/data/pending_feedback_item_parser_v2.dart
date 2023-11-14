import 'dart:convert';
import 'dart:ui';

import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/_wiredash_internal.dart';

/// Parses saved feedback in the format from SDK version 1.0.0 to 1.7.X
class PendingFeedbackItemParserV2 {
  static PendingFeedbackItem fromJson(Map json) {
    final feedbackItemJson = json['feedbackItem'] as Map<dynamic, dynamic>;

    final deviceInfoJson =
        feedbackItemJson['deviceInfo'] as Map<dynamic, dynamic>;
    final physicalSize = deviceInfoJson['physicalSize'] as List<dynamic>;
    final physicalGeometry =
        deviceInfoJson['physicalGeometry'] as List<dynamic>;
    final buildInfoJson =
        feedbackItemJson['buildInfo'] as Map<dynamic, dynamic>? ?? {};
    final appInfoJson = feedbackItemJson['appInfo'] as Map<dynamic, dynamic>;
    final attachments =
        (feedbackItemJson['attachments'] as List<dynamic>?)?.map((item) {
      final map = item as Map<dynamic, dynamic>;
      final path = map['path'] as String?;
      final attachmentId = map['id'] as String?;
      final file = path != null
          ? FileDataEventuallyOnDisk.file(path)
          : FileDataEventuallyOnDisk.uploaded(
              AttachmentId(attachmentId!),
            );
      return PersistedAttachment.screenshot(file: file);
    }).toList();

    final feedbackItem = FeedbackItem(
      metadata: AllMetaData(
        installId: deviceInfoJson['deviceId'] as String,
        appLocale: appInfoJson['appLocale'] as String,
        compilationMode: () {
          final mode = buildInfoJson['compilationMode'] as String;
          if (mode == 'debug') return CompilationMode.debug;
          if (mode == 'profile') return CompilationMode.profile;
          return CompilationMode.release;
        }(),
        buildCommit: buildInfoJson['buildCommit'] as String?,
        buildNumber: buildInfoJson['buildNumber'] as String?,
        buildVersion: buildInfoJson['buildVersion'] as String?,
        userId: feedbackItemJson['userId'] as String?,
        userEmail: feedbackItemJson['email'] as String?,
        sdkVersion: feedbackItemJson['sdkVersion'] as int,
        custom: (feedbackItemJson['customMetaData'] as Map?)?.map(
          (key, value) =>
              MapEntry(key.toString(), jsonDecode(value.toString())),
        ),
        platformGestureInsets: WiredashWindowPadding.fromJson(
          deviceInfoJson['gestureInsets'] as List<dynamic>,
        ),
        platformLocale: deviceInfoJson['platformLocale'] as String,
        platformSupportedLocales:
            (deviceInfoJson['platformSupportedLocales'] as List<dynamic>)
                .cast<String>(),
        windowPadding: WiredashWindowPadding.fromJson(
          deviceInfoJson['padding'] as List<dynamic>,
        ),
        platformBrightness: () {
          final value = deviceInfoJson['platformBrightness'];
          if (value == 'light') return Brightness.light;
          if (value == 'dark') return Brightness.dark;
          throw 'Unknown brightness value $value';
        }(),
        windowSize: Size(
          (physicalSize[0] as num).toDouble(),
          (physicalSize[1] as num).toDouble(),
        ),
        windowPixelRatio: (deviceInfoJson['pixelRatio'] as num).toDouble(),
        platformOS: deviceInfoJson['platformOS'] as String?,
        platformOSVersion: deviceInfoJson['platformOSBuild'] as String?,
        platformDartVersion: deviceInfoJson['platformVersion'] as String?,
        windowTextScaleFactor:
            (deviceInfoJson['textScaleFactor'] as num).toDouble(),
        windowInsets: WiredashWindowPadding.fromJson(
          deviceInfoJson['viewInsets'] as List<dynamic>,
        ),
        physicalGeometry: Rect.fromLTRB(
          (physicalGeometry[0] as num).toDouble(),
          (physicalGeometry[1] as num).toDouble(),
          (physicalGeometry[2] as num).toDouble(),
          (physicalGeometry[3] as num).toDouble(),
        ),
      ),
      message: feedbackItemJson['message'] as String,
      labels: (feedbackItemJson['labels'] as List<dynamic>?)
          ?.map((it) => it as String)
          .toList(),
      feedbackId: (json['id'] as String).replaceAll('-', '').takeFirst(16),
      attachments: attachments ?? [],
    );

    return PendingFeedbackItem(
      id: json['id'] as String,
      feedbackItem: feedbackItem,
    );
  }
}

extension on String {
  String takeFirst(int length) {
    if (length >= this.length) return this;
    return substring(0, length);
  }
}
