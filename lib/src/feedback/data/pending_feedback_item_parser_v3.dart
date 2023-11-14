import 'dart:ui';

import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/_wiredash_internal.dart';

/// Parses saved feedback in the format starting at SDK version 1.8.0
class PendingFeedbackItemParserV3 {
  static PendingFeedbackItem fromJson(Map json) {
    final feedbackItemJson = json['feedbackItem'] as Map<dynamic, dynamic>;
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

    final metadataJson = feedbackItemJson['metadata'] as Map<dynamic, dynamic>;
    final windowSize = metadataJson['windowSize'] as List<dynamic>;
    final physicalGeometry = metadataJson['physicalGeometry'] as List<dynamic>;

    final feedbackItem = FeedbackItem(
      feedbackId: feedbackItemJson['feedbackId'] as String,
      message: feedbackItemJson['message'] as String,
      labels: (feedbackItemJson['labels'] as List<dynamic>?)
          ?.map((it) => it as String)
          .toList(),
      attachments: attachments,
      metadata: AllMetaData(
        appLocale: metadataJson['appLocale'] as String?,
        appName: metadataJson['appName'] as String?,
        buildCommit: metadataJson['buildCommit'] as String?,
        buildNumber: metadataJson['buildNumber'] as String?,
        buildVersion: metadataJson['buildVersion'] as String?,
        bundleId: metadataJson['bundleId'] as String?,
        compilationMode: () {
          final mode = metadataJson['compilationMode'] as String;
          if (mode == 'debug') return CompilationMode.debug;
          if (mode == 'profile') return CompilationMode.profile;
          return CompilationMode.release;
        }(),
        custom: (metadataJson['custom'] as Map?)?.map(
          (key, value) {
            return MapEntry(key.toString(), value);
          },
        ),
        deviceModel: metadataJson['deviceModel'] as String?,
        installId: metadataJson['installId'] as String,
        physicalGeometry: Rect.fromLTRB(
          (physicalGeometry[0] as num).toDouble(),
          (physicalGeometry[1] as num).toDouble(),
          (physicalGeometry[2] as num).toDouble(),
          (physicalGeometry[3] as num).toDouble(),
        ),
        platformBrightness: () {
          final value = metadataJson['platformBrightness'];
          if (value == 'light') return Brightness.light;
          if (value == 'dark') return Brightness.dark;
          throw 'Unknown brightness value $value';
        }(),
        platformDartVersion: metadataJson['platformDartVersion'] as String?,
        platformGestureInsets: WiredashWindowPadding.fromJson(
          metadataJson['platformGestureInsets'] as List<dynamic>,
        ),
        platformLocale: metadataJson['platformLocale'] as String,
        platformOS: metadataJson['platformOS'] as String?,
        platformOSVersion: metadataJson['platformOSVersion'] as String?,
        platformSupportedLocales:
            (metadataJson['platformSupportedLocales'] as List<dynamic>)
                .cast<String>(),
        sdkVersion: metadataJson['sdkVersion'] as int,
        userId: metadataJson['userId'] as String?,
        userEmail: metadataJson['userEmail'] as String?,
        windowInsets: WiredashWindowPadding.fromJson(
          metadataJson['windowInsets'] as List<dynamic>,
        ),
        windowPadding: WiredashWindowPadding.fromJson(
          metadataJson['windowPadding'] as List<dynamic>,
        ),
        windowPixelRatio: (metadataJson['windowPixelRatio'] as num).toDouble(),
        windowSize: Size(
          (windowSize[0] as num).toDouble(),
          (windowSize[1] as num).toDouble(),
        ),
        windowTextScaleFactor:
            (metadataJson['windowTextScaleFactor'] as num).toDouble(),
      ),
    );
    //
    return PendingFeedbackItem(
      id: json['id'] as String,
      feedbackItem: feedbackItem,
    );
  }
}
