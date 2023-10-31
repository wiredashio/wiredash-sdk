// ignore: unnecessary_import
import 'dart:typed_data';

// ignore: unused_import
import 'package:collection/collection.dart';
import 'package:file/file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/version.dart';
import 'package:wiredash/src/metadata/meta_data_collector.dart';

import 'package:wiredash/src/metadata/user_meta_data.dart';

/// Contains all relevant feedback information, both user-provided and
/// automatically inferred, that will be eventually sent to the Wiredash
/// console and are in the meantime persisted on disk inside
/// [PendingFeedbackItem].
///
/// Actual serialization happens in [PendingFeedbackItem]
class FeedbackItem {
  final AllMetaData metadata;
  final List<PersistedAttachment>? attachments;
  final List<String>? labels;
  final String message;

  const FeedbackItem({
    required this.metadata,
    this.attachments,
    this.labels,
    required this.message,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedbackItem &&
          runtimeType == other.runtimeType &&
          metadata == other.metadata &&
          listEquals(attachments, other.attachments) &&
          listEquals(labels, other.labels) &&
          message == other.message);

  @override
  int get hashCode =>
      metadata.hashCode ^
      // 'hashList' is deprecated and shouldn't be used. Use Object.hashAll() or Object.hashAllUnordered() instead. This feature was deprecated in v3.1.0-0.0.pre.897.
      // ignore: deprecated_member_use
      hashList(attachments) ^
      // 'hashList' is deprecated and shouldn't be used. Use Object.hashAll() or Object.hashAllUnordered() instead. This feature was deprecated in v3.1.0-0.0.pre.897.
      // ignore: deprecated_member_use
      hashList(labels) ^
      message.hashCode;

  @override
  String toString() {
    return 'FeedbackItem{ '
        'metaData: $metadata, '
        'attachments: $attachments, '
        'labels: $labels, '
        'message: $message, '
        '}';
  }

  FeedbackItem copyWith({
    AllMetaData? metadata,
    List<PersistedAttachment>? attachments,
    String? userEmail,
    List<String>? labels,
    String? message,
  }) {
    return FeedbackItem(
      metadata: metadata ?? this.metadata,
      attachments: attachments ?? this.attachments,
      labels: labels ?? this.labels,
      message: message ?? this.message,
    );
  }
}

// TODO move to a different file (non-feedback)
class AllMetaData {
  final String? appLocale;
  final String? appName;
  final String? buildCommit;
  final String? buildNumber;
  final String? buildVersion;
  final String? bundleId;
  final CompilationMode compilationMode;
  final Map<String, Object?>? custom;
  final String? deviceModel;
  final String installId;
  final Rect physicalGeometry;
  final Brightness platformBrightness;
  final String? platformDartVersion;
  final WiredashWindowPadding platformGestureInsets;
  final String platformLocale;
  final String? platformOS;
  final String? platformOSVersion;
  final List<String> platformSupportedLocales;
  final int sdkVersion;
  final String? userId;
  final String? userEmail;
  final WiredashWindowPadding windowInsets;
  final WiredashWindowPadding windowPadding;
  final double windowPixelRatio;
  final Size windowSize;
  final double windowTextScaleFactor;

  const AllMetaData({
    this.appLocale,
    this.appName,
    this.buildCommit,
    this.buildNumber,
    this.buildVersion,
    this.bundleId,
    required this.compilationMode,
    this.custom,
    this.deviceModel,
    required this.installId,
    required this.physicalGeometry,
    required this.platformBrightness,
    this.platformDartVersion,
    required this.platformGestureInsets,
    required this.platformLocale,
    this.platformOS,
    this.platformOSVersion,
    required this.platformSupportedLocales,
    required this.sdkVersion,
    this.userId,
    this.userEmail,
    required this.windowInsets,
    required this.windowPadding,
    required this.windowPixelRatio,
    required this.windowSize,
    required this.windowTextScaleFactor,
  });

  factory AllMetaData.from({
    required WiredashMetaData sessionMetadata,
    required FixedMetaData fixedMetadata,
    required FlutterInfo flutterInfo,
    required String installId,
    String? email,
  }) {
    return _from(
      sessionMetadata: sessionMetadata,
      fixedMetadata: fixedMetadata,
      flutterInfo: flutterInfo,
      installId: installId,
      email: email,
    );
  }

  // ignore: prefer_constructors_over_static_methods
  static AllMetaData _from({
    required WiredashMetaData sessionMetadata,
    required FixedMetaData fixedMetadata,
    required FlutterInfo flutterInfo,
    required String installId,
    Object? email = defaultArgument,
  }) {
    return AllMetaData(
      appLocale: sessionMetadata.appLocale,
      appName: fixedMetadata.appInfo.appName,
      buildCommit:
          sessionMetadata.buildCommit ?? fixedMetadata.buildInfo.buildCommit,
      buildNumber:
          sessionMetadata.buildNumber ?? fixedMetadata.buildInfo.buildNumber,
      buildVersion:
          sessionMetadata.buildVersion ?? fixedMetadata.buildInfo.buildVersion,
      bundleId: fixedMetadata.appInfo.bundleId,
      compilationMode: fixedMetadata.buildInfo.compilationMode,
      custom: sessionMetadata.custom,
      deviceModel: fixedMetadata.deviceInfo.deviceModel,
      installId: installId,
      physicalGeometry: flutterInfo.physicalGeometry,
      platformBrightness: flutterInfo.platformBrightness,
      platformDartVersion: flutterInfo.platformDartVersion,
      platformGestureInsets: flutterInfo.gestureInsets,
      platformLocale: flutterInfo.platformLocale,
      platformOS: flutterInfo.platformOS,
      platformOSVersion: flutterInfo.platformOSVersion,
      platformSupportedLocales: flutterInfo.platformSupportedLocales,
      sdkVersion: wiredashSdkVersion,
      userEmail: email == defaultArgument
          ? sessionMetadata.userEmail
          : email as String?,
      userId: sessionMetadata.userId,
      windowInsets: flutterInfo.viewInsets,
      windowPadding: flutterInfo.viewPadding,
      windowPixelRatio: flutterInfo.pixelRatio,
      windowSize: flutterInfo.physicalSize,
      windowTextScaleFactor: flutterInfo.textScaleFactor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AllMetaData &&
          runtimeType == other.runtimeType &&
          appLocale == other.appLocale &&
          appName == other.appName &&
          buildCommit == other.buildCommit &&
          buildNumber == other.buildNumber &&
          buildVersion == other.buildVersion &&
          bundleId == other.bundleId &&
          compilationMode == other.compilationMode &&
          const DeepCollectionEquality().equals(custom, other.custom) &&
          deviceModel == other.deviceModel &&
          installId == other.installId &&
          physicalGeometry == other.physicalGeometry &&
          platformBrightness == other.platformBrightness &&
          platformDartVersion == other.platformDartVersion &&
          platformGestureInsets == other.platformGestureInsets &&
          platformLocale == other.platformLocale &&
          platformOS == other.platformOS &&
          platformOSVersion == other.platformOSVersion &&
          const ListEquality().equals(
            platformSupportedLocales,
            other.platformSupportedLocales,
          ) &&
          sdkVersion == other.sdkVersion &&
          userId == other.userId &&
          userEmail == other.userEmail &&
          windowInsets == other.windowInsets &&
          windowPadding == other.windowPadding &&
          windowPixelRatio == other.windowPixelRatio &&
          windowSize == other.windowSize &&
          windowTextScaleFactor == other.windowTextScaleFactor);

  @override
  int get hashCode =>
      appLocale.hashCode ^
      appName.hashCode ^
      buildCommit.hashCode ^
      buildNumber.hashCode ^
      buildVersion.hashCode ^
      bundleId.hashCode ^
      compilationMode.hashCode ^
      const DeepCollectionEquality().hash(custom) ^
      deviceModel.hashCode ^
      installId.hashCode ^
      physicalGeometry.hashCode ^
      platformBrightness.hashCode ^
      platformDartVersion.hashCode ^
      platformGestureInsets.hashCode ^
      platformLocale.hashCode ^
      platformOS.hashCode ^
      platformOSVersion.hashCode ^
      const ListEquality().hash(platformSupportedLocales) ^
      sdkVersion.hashCode ^
      userId.hashCode ^
      userEmail.hashCode ^
      windowInsets.hashCode ^
      windowPadding.hashCode ^
      windowPixelRatio.hashCode ^
      windowSize.hashCode ^
      windowTextScaleFactor.hashCode;

  @override
  String toString() {
    return 'AllMetaData{ '
        'appLocale: $appLocale, '
        'appName: $appName, '
        'buildCommit: $buildCommit, '
        'buildNumber: $buildNumber, '
        'buildVersion: $buildVersion, '
        'bundleId: $bundleId, '
        'compilationMode: $compilationMode, '
        'custom: $custom, '
        'deviceModel: $deviceModel, '
        'installId: $installId, '
        'physicalGeometry: $physicalGeometry, '
        'platformBrightness: $platformBrightness, '
        'platformDartVersion: $platformDartVersion, '
        'platformGestureInsets: $platformGestureInsets, '
        'platformLocale: $platformLocale, '
        'platformOS: $platformOS, '
        'platformOSVersion: $platformOSVersion, '
        'platformSupportedLocales: $platformSupportedLocales, '
        'sdkVersion: $sdkVersion, '
        'userId: $userId, '
        'userEmail: $userEmail, '
        'windowInsets: $windowInsets, '
        'windowPadding: $windowPadding, '
        'windowPixelRatio: $windowPixelRatio, '
        'windowSize: $windowSize, '
        'windowTextScaleFactor: $windowTextScaleFactor, '
        '}';
  }

  AllMetaData copyWith({
    String? appLocale,
    String? appName,
    String? buildCommit,
    String? buildNumber,
    String? buildVersion,
    String? bundleId,
    CompilationMode? compilationMode,
    Map<String, Object?>? custom,
    String? deviceModel,
    String? installId,
    Rect? physicalGeometry,
    Brightness? platformBrightness,
    String? platformDartVersion,
    WiredashWindowPadding? platformGestureInsets,
    String? platformLocale,
    String? platformOS,
    String? platformOSVersion,
    List<String>? platformSupportedLocales,
    int? sdkVersion,
    String? userId,
    String? userEmail,
    WiredashWindowPadding? windowInsets,
    WiredashWindowPadding? windowPadding,
    double? windowPixelRatio,
    Size? windowSize,
    double? windowTextScaleFactor,
  }) {
    return AllMetaData(
      appLocale: appLocale ?? this.appLocale,
      appName: appName ?? this.appName,
      buildCommit: buildCommit ?? this.buildCommit,
      buildNumber: buildNumber ?? this.buildNumber,
      buildVersion: buildVersion ?? this.buildVersion,
      bundleId: bundleId ?? this.bundleId,
      compilationMode: compilationMode ?? this.compilationMode,
      custom: custom ?? this.custom,
      deviceModel: deviceModel ?? this.deviceModel,
      installId: installId ?? this.installId,
      physicalGeometry: physicalGeometry ?? this.physicalGeometry,
      platformBrightness: platformBrightness ?? this.platformBrightness,
      platformDartVersion: platformDartVersion ?? this.platformDartVersion,
      platformGestureInsets:
          platformGestureInsets ?? this.platformGestureInsets,
      platformLocale: platformLocale ?? this.platformLocale,
      platformOS: platformOS ?? this.platformOS,
      platformOSVersion: platformOSVersion ?? this.platformOSVersion,
      platformSupportedLocales:
          platformSupportedLocales ?? this.platformSupportedLocales,
      sdkVersion: sdkVersion ?? this.sdkVersion,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      windowInsets: windowInsets ?? this.windowInsets,
      windowPadding: windowPadding ?? this.windowPadding,
      windowPixelRatio: windowPixelRatio ?? this.windowPixelRatio,
      windowSize: windowSize ?? this.windowSize,
      windowTextScaleFactor:
          windowTextScaleFactor ?? this.windowTextScaleFactor,
    );
  }
}

abstract class PersistedAttachment {
  const PersistedAttachment();

  FileDataEventuallyOnDisk get file;

  bool get isUploaded => file.isUploaded;

  // ignore: prefer_constructors_over_static_methods
  static Screenshot screenshot({
    required FileDataEventuallyOnDisk file,
  }) {
    return Screenshot._(
      file: file,
    );
  }

// TODO add freezed like when() for more attachment types
}

/// A attachment type the user created using Wiredash screenshot feature
class Screenshot extends PersistedAttachment {
  const Screenshot._({
    required this.file,
  });

  @override
  final FileDataEventuallyOnDisk file;

  @override
  String toString() {
    return 'Screenshot{'
        'file: $file, '
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Screenshot &&
          runtimeType == other.runtimeType &&
          file == other.file;

  @override
  int get hashCode => file.hashCode;

  Screenshot copyWith({
    FileDataEventuallyOnDisk? file,
    FlutterInfo? deviceInfo,
  }) {
    return PersistedAttachment.screenshot(
      file: file ?? this.file,
    );
  }
}

/// A [PersistedAttachment] type that is either in-memory, on disk or already
/// uploaded to the cloud
class FileDataEventuallyOnDisk {
  final Uint8List? data;
  final String? pathToFile;
  final AttachmentId? attachmentId;

  FileDataEventuallyOnDisk.inMemory(Uint8List data)
      // ignore: prefer_initializing_formals
      : data = data,
        pathToFile = null,
        attachmentId = null;

  FileDataEventuallyOnDisk.file(String path)
      : pathToFile = path,
        data = null,
        attachmentId = null;

  FileDataEventuallyOnDisk.uploaded(AttachmentId attachmentId)
      // ignore: prefer_initializing_formals
      : attachmentId = attachmentId,
        data = null,
        pathToFile = null;

  bool get isOnDisk => pathToFile != null;

  bool get isUploaded => attachmentId != null;

  bool get isInMemory => data != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileDataEventuallyOnDisk &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          pathToFile == other.pathToFile &&
          attachmentId == other.attachmentId;

  @override
  int get hashCode =>
      data.hashCode ^ pathToFile.hashCode ^ attachmentId.hashCode;

  @override
  String toString() {
    if (isUploaded) return "FileDataEventuallyOnDisk.uploaded($attachmentId)";
    if (isOnDisk) return "FileDataEventuallyOnDisk.file($pathToFile)";
    return 'FileDataEventuallyOnDisk.inMemory(${data!.lengthInBytes}bytes)';
  }
}

extension BinaryDataFromFile on FileDataEventuallyOnDisk {
  Uint8List? binaryData(FileSystem filesystem) {
    if (data != null) return data!;
    if (pathToFile != null) {
      return filesystem.file(pathToFile).readAsBytesSync();
    }
    return null;
  }
}
