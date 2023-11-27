import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/version.dart';
import 'package:wiredash/src/metadata/meta_data_collector.dart';

/// A collection of captures metadata from different sources
///
/// See [MetaDataCollector] for more information about the data sources
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

  /// Either a 16 char nanoId or a 36 char uuid from SDK 1.7.X and earlier
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
    required SessionMetaData sessionMetadata,
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
      email: email ?? defaultArgument,
    );
  }

  // ignore: prefer_constructors_over_static_methods
  static AllMetaData _from({
    required SessionMetaData sessionMetadata,
    required FixedMetaData fixedMetadata,
    required FlutterInfo flutterInfo,
    required String installId,
    Object? email = defaultArgument,
  }) {
    return AllMetaData(
      appLocale: sessionMetadata.appLocale,
      appName: fixedMetadata.appInfo.appName,
      buildCommit: fixedMetadata.buildInfo.buildCommit,
      buildNumber: fixedMetadata.buildInfo.buildNumber,
      buildVersion: fixedMetadata.buildInfo.buildVersion,
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
      platformOSVersion: fixedMetadata.deviceInfo.osVersion,
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

/// WindowPadding doesn't offer a public constructor and doesn't implement
/// ==() and hashCode
// Remove when we drop support for Flutter v3.8.0-14.0.pre.
// ignore: deprecated_member_use
class WiredashWindowPadding implements WindowPadding {
  const WiredashWindowPadding({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  factory WiredashWindowPadding.fromJson(List json) {
    return WiredashWindowPadding(
      left: (json[0] as num).toDouble(),
      top: (json[1] as num).toDouble(),
      right: (json[2] as num).toDouble(),
      bottom: (json[3] as num).toDouble(),
    );
  }

  // Remove when we drop support for Flutter v3.8.0-14.0.pre.
  // ignore: deprecated_member_use
  factory WiredashWindowPadding.fromWindowPadding(WindowPadding padding) {
    return WiredashWindowPadding(
      left: padding.left,
      top: padding.top,
      right: padding.right,
      bottom: padding.bottom,
    );
  }

  /// The distance from the left edge to the first unpadded pixel, in physical
  /// pixels.
  @override
  final double left;

  /// The distance from the top edge to the first unpadded pixel, in physical
  /// pixels.
  @override
  final double top;

  /// The distance from the right edge to the first unpadded pixel, in physical
  /// pixels.
  @override
  final double right;

  /// The distance from the bottom edge to the first unpadded pixel, in physical
  /// pixels.
  @override
  final double bottom;

  @override
  String toString() {
    return 'WiredashWindowPadding{'
        'left: $left, top: $top, right: $right, bottom: $bottom'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WiredashWindowPadding &&
          runtimeType == other.runtimeType &&
          left == other.left &&
          top == other.top &&
          right == other.right &&
          bottom == other.bottom;

  @override
  int get hashCode =>
      left.hashCode ^ top.hashCode ^ right.hashCode ^ bottom.hashCode;
}
