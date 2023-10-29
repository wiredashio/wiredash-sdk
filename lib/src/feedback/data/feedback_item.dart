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

/// Contains all relevant feedback information, both user-provided and
/// automatically inferred, that will be eventually sent to the Wiredash
/// console and are in the meantime persisted on disk inside
/// [PendingFeedbackItem].
///
/// Actual serialization happens in [PendingFeedbackItem]
class FeedbackItem {
  const FeedbackItem({
    required this.appInfo,
    required this.attachments,
    required this.buildInfo,
    required this.deviceId,
    required this.deviceInfo,
    required this.flutterInfo,
    this.email,
    this.labels,
    required this.message,
    this.sdkVersion = wiredashSdkVersion,
    required this.sessionMetadata,
  });

  final AppInfo appInfo;
  final List<PersistedAttachment> attachments;
  final BuildInfo buildInfo;
  final String deviceId;
  final DeviceInfo deviceInfo;
  final FlutterInfo flutterInfo;
  final String? email;
  final List<String>? labels;
  final String message;
  final int sdkVersion;
  final SessionMetaData sessionMetadata;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedbackItem &&
          runtimeType == other.runtimeType &&
          listEquals(attachments, other.attachments) &&
          buildInfo == other.buildInfo &&
          deviceId == other.deviceId &&
          email == other.email &&
          message == other.message &&
          sessionMetadata == other.sessionMetadata &&
          sdkVersion == other.sdkVersion &&
          flutterInfo == other.flutterInfo &&
          listEquals(labels, other.labels) &&
          appInfo == other.appInfo &&
          deviceInfo == other.deviceInfo;

  @override
  int get hashCode =>
      // replace with Object.hashAll() when we drop support for Flutter v3.1.0-0.0.pre.897
      // ignore: deprecated_member_use
      hashList(attachments) ^
      buildInfo.hashCode ^
      deviceId.hashCode ^
      email.hashCode ^
      message.hashCode ^
      sessionMetadata.hashCode ^
      sdkVersion.hashCode ^
      flutterInfo.hashCode ^
      // ignore: deprecated_member_use
      hashList(labels) ^
      appInfo.hashCode ^
      deviceInfo.hashCode;

  @override
  String toString() {
    return 'PersistedFeedbackItem{\n'
        'buildInfo: $buildInfo,\n'
        'deviceId: $deviceId,\n'
        'email: $email,\n'
        'message: $message,\n'
        'sessionMetadata: $sessionMetadata,\n'
        'flutterInfo: $flutterInfo,\n'
        'sdkVersion: $sdkVersion,\n'
        'labels: $labels,\n'
        'appInfo: $appInfo,\n'
        'deviceInfo: $deviceInfo,\n'
        'attachments: $attachments\n'
        '}';
  }

  FeedbackItem copyWith({
    List<PersistedAttachment>? attachments,
    BuildInfo? buildInfo,
    String? deviceId,
    String? email,
    String? message,
    SessionMetaData? sessionMetadata,
    int? sdkVersion,
    FlutterInfo? flutterInfo,
    List<String>? labels,
    AppInfo? appInfo,
    DeviceInfo? deviceInfo,
    Map<String, Object?>? customMetaData,
  }) {
    return FeedbackItem(
      attachments: attachments ?? this.attachments,
      buildInfo: buildInfo ?? this.buildInfo,
      deviceId: deviceId ?? this.deviceId,
      email: email ?? this.email,
      message: message ?? this.message,
      sessionMetadata: sessionMetadata ?? this.sessionMetadata,
      sdkVersion: sdkVersion ?? this.sdkVersion,
      flutterInfo: flutterInfo ?? this.flutterInfo,
      labels: labels ?? this.labels,
      appInfo: appInfo ?? this.appInfo,
      deviceInfo: deviceInfo ?? this.deviceInfo,
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
