import 'dart:convert';
import 'dart:ui';

import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/metadata/meta_data_collector.dart';
import 'package:wiredash/src/metadata/user_meta_data.dart';

class PendingFeedbackItemParserV2 {
  static FlutterInfo _parseFlutterInfo(Map deviceInfoJson) {
    final physicalSize = deviceInfoJson['physicalSize'] as List<dynamic>;
    final physicalGeometry =
        deviceInfoJson['physicalGeometry'] as List<dynamic>;
    return FlutterInfo(
      gestureInsets: WiredashWindowPadding.fromJson(
        deviceInfoJson['gestureInsets'] as List<dynamic>,
      ),
      platformLocale: deviceInfoJson['platformLocale'] as String,
      platformSupportedLocales:
          (deviceInfoJson['platformSupportedLocales'] as List<dynamic>)
              .cast<String>(),
      padding: WiredashWindowPadding.fromJson(
        deviceInfoJson['padding'] as List<dynamic>,
      ),
      platformBrightness: () {
        final value = deviceInfoJson['platformBrightness'];
        if (value == 'light') return Brightness.light;
        if (value == 'dark') return Brightness.dark;
        throw 'Unknown brightness value $value';
      }(),
      physicalSize: Size(
        (physicalSize[0] as num).toDouble(),
        (physicalSize[1] as num).toDouble(),
      ),
      pixelRatio: (deviceInfoJson['pixelRatio'] as num).toDouble(),
      platformOS: deviceInfoJson['platformOS'] as String?,
      platformOSVersion: deviceInfoJson['platformOSBuild'] as String?,
      platformVersion: deviceInfoJson['platformVersion'] as String?,
      textScaleFactor: (deviceInfoJson['textScaleFactor'] as num).toDouble(),
      viewInsets: WiredashWindowPadding.fromJson(
        deviceInfoJson['viewInsets'] as List<dynamic>,
      ),
      userAgent: deviceInfoJson['userAgent'] as String?,
      physicalGeometry: Rect.fromLTRB(
        (physicalGeometry[0] as num).toDouble(),
        (physicalGeometry[1] as num).toDouble(),
        (physicalGeometry[2] as num).toDouble(),
        (physicalGeometry[3] as num).toDouble(),
      ),
    );
  }

  static PendingFeedbackItem fromJson(Map json) {
    final feedbackItemJson = json['feedbackItem'] as Map<dynamic, dynamic>;

    final flutterInfoJson =
        feedbackItemJson['deviceInfo'] as Map<dynamic, dynamic>;
    final flutterInfo = _parseFlutterInfo(flutterInfoJson);

    final buildInfoJson =
        feedbackItemJson['buildInfo'] as Map<dynamic, dynamic>? ?? {};
    final buildInfo = BuildInfo(
      compilationMode: () {
        final mode = buildInfoJson['compilationMode'] as String;
        if (mode == 'debug') return CompilationMode.debug;
        if (mode == 'profile') return CompilationMode.profile;
        return CompilationMode.release;
      }(),
      buildCommit: buildInfoJson['buildCommit'] as String?,
      buildNumber: buildInfoJson['buildNumber'] as String?,
      buildVersion: buildInfoJson['buildVersion'] as String?,
    );

    final appInfoJson = feedbackItemJson['appInfo'] as Map<dynamic, dynamic>;
    final appLocale = appInfoJson['appLocale'] as String;
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
      appInfo: AppInfo(
        version: appInfoJson['appVersion'] as String?,
      ),
      buildInfo: buildInfo,
      flutterInfo: flutterInfo,
      deviceId: feedbackItemJson['deviceId'] as String,
      deviceInfo: const DeviceInfo(),
      sessionMetadata: CustomizableWiredashMetaData()
        ..appLocale = appLocale
        ..userId = feedbackItemJson['userId'] as String?
        ..custom = (feedbackItemJson['customMetaData'] as Map?)?.map(
              (key, value) =>
                  MapEntry(key.toString(), jsonDecode(value.toString())),
            ) ??
            {},
      email: feedbackItemJson['email'] as String?,
      message: feedbackItemJson['message'] as String,
      sdkVersion: feedbackItemJson['sdkVersion'] as int,
      labels: (feedbackItemJson['labels'] as List<dynamic>?)
          ?.map((it) => it as String)
          .toList(),
      attachments: attachments ?? [],
    );

    return PendingFeedbackItem(
      id: json['id'] as String,
      feedbackItem: feedbackItem,
    );
  }
}
