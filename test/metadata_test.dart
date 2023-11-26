// ignore_for_file: avoid_print, deprecated_member_use_from_same_package

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/wiredash.dart';

import 'util/robot.dart';

void main() {
  test('userEmail can be set', () async {
    final WiredashModel model = WiredashModel(createMockServices());
    final controller = WiredashController(model);
    expect(controller.metaData.userEmail, isNull);
    await controller.setUserProperties(userEmail: 'dash@flutter.io');
    expect(controller.metaData.userEmail, 'dash@flutter.io');
  });

  test('userEmail can be resetted', () async {
    final WiredashModel model = WiredashModel(createMockServices());
    final controller = WiredashController(model);
    expect(controller.metaData.userEmail, isNull);
    await controller.setUserProperties(userEmail: 'dash@flutter.io');
    expect(controller.metaData.userEmail, 'dash@flutter.io');
    await controller.setUserProperties(userEmail: null);
    expect(controller.metaData.userEmail, isNull);
  });

  test('deprecated setBuildProperties() is noop', () async {
    final WiredashModel model = WiredashModel(createMockServices());
    final controller = WiredashController(model);
    expect(controller.metaData.buildNumber, isNull);
    controller.setBuildProperties(
      buildNumber: '123',
      buildCommit: 'abc',
      buildVersion: '1.0.0',
    );
    expect(controller.metaData.buildNumber, isNull);
    expect(controller.metaData.buildCommit, isNull);
    expect(controller.metaData.buildVersion, isNull);
  });

  test('custom metadata can not be mutable via metaData getter', () async {
    final WiredashModel model = WiredashModel(createMockServices());
    final controller = WiredashController(model);
    final map = controller.metaData.custom;
    expect(() => map['foo'] = 'bar', throwsA(isA<UnsupportedError>()));
  });

  test('custom metadata can be mutated in modifyMetaData', () async {
    final WiredashModel model = WiredashModel(createMockServices());
    final controller = WiredashController(model);
    final map = controller.metaData.custom;
    await controller
        .modifyMetaData((metaData) => metaData..custom['foo'] = 'bar');
    expect(controller.metaData.custom['foo'], 'bar');
    // getter copy did not change
    expect(map['foo'], isNull);
  });

  testWidgets('set metadata before opening wiredash', (tester) async {
    final robot = WiredashTestRobot(tester);

    WiredashMetaData? metadata;
    await robot.launchApp(
      builder: (context) {
        return Scaffold(
          body: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final wiredash = Wiredash.of(context);
                  await wiredash.modifyMetaData((metaData) {
                    metadata = metaData.copyWith();
                    return metaData;
                  });
                  wiredash.show();
                },
                child: const Text('Feedback'),
              ),
            ],
          ),
        );
      },
    );
    await robot.openWiredash();

    // can only be set by developers
    expect(metadata!.userId, isNull);
    expect(metadata!.userEmail, isNull);
    expect(metadata!.buildCommit, isNull);

    // prefilled
    expect(metadata!.buildNumber, isNotNull);
    expect(metadata!.buildVersion, isNotNull);
    expect(metadata!.appLocale, isNotNull);
    expect(metadata!.custom.isEmpty, isTrue);
  });

  testWidgets('reading metadata async is prefilled, sync only eventually',
      (tester) async {
    final robot = WiredashTestRobot(tester);

    WiredashMetaData? syncMetaData;
    WiredashMetaData? asyncMetaData;
    await robot.launchApp(
      builder: (context) {
        return Scaffold(
          body: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final wiredash = Wiredash.of(context);
                  syncMetaData = wiredash.metaData;
                  asyncMetaData = await wiredash.getMetaData();
                  wiredash.show();
                },
                child: const Text('Feedback'),
              ),
            ],
          ),
        );
      },
    );
    await robot.openWiredash();

    // all empty
    expect(syncMetaData!.userId, isNull);
    expect(syncMetaData!.userEmail, isNull);
    expect(syncMetaData!.buildCommit, isNull);
    expect(syncMetaData!.buildNumber, isNull);
    expect(syncMetaData!.buildVersion, isNull);
    expect(syncMetaData!.appLocale, isNull);
    expect(syncMetaData!.custom.isEmpty, isTrue);

    // prefilled
    expect(asyncMetaData!.userId, isNull);
    expect(asyncMetaData!.userEmail, isNull);
    expect(asyncMetaData!.buildCommit, isNull);
    expect(asyncMetaData!.buildNumber, isNotNull);
    expect(asyncMetaData!.buildVersion, isNotNull);
    expect(asyncMetaData!.appLocale, isNotNull);
    expect(asyncMetaData!.custom.isEmpty, isTrue);
  });
}
