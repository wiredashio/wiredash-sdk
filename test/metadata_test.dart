// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/options/feedback_options.dart';
import 'package:wiredash/src/core/widgets/larry_page_view.dart';
import 'package:wiredash/src/feedback/_feedback.dart';

import 'util/assert_widget.dart';
import 'util/robot.dart';
import 'util/wiredash_tester.dart';

void main() {
  test('userEmail can be set', () async {
    final WiredashModel model = WiredashModel(createMockServices());
    final controller = WiredashController(model);
    expect(controller.metaData.userEmail, isNull);
    controller.setUserProperties(userEmail: 'dash@flutter.io');
    expect(controller.metaData.userEmail, 'dash@flutter.io');
  });

  test('userEmail can be resetted', () async {
    final WiredashModel model = WiredashModel(createMockServices());
    final controller = WiredashController(model);
    expect(controller.metaData.userEmail, isNull);
    controller.setUserProperties(userEmail: 'dash@flutter.io');
    expect(controller.metaData.userEmail, 'dash@flutter.io');
    controller.setUserProperties(userEmail: null);
    expect(controller.metaData.userEmail, isNull);
  });

  test('buildNumber can be set', () async {
    final WiredashModel model = WiredashModel(createMockServices());
    final controller = WiredashController(model);
    expect(controller.metaData.userEmail, isNull);
    controller.setBuildProperties(buildNumber: '123');
    expect(controller.metaData.buildNumber, '123');
  });

  test('buildNumber can be resetted', () async {
    final WiredashModel model = WiredashModel(createMockServices());
    final controller = WiredashController(model);
    expect(controller.metaData.userEmail, isNull);
    controller.setBuildProperties(buildNumber: '123');
    expect(controller.metaData.buildNumber, '123');
    controller.setBuildProperties(buildNumber: null);
    expect(controller.metaData.buildNumber, isNull);
  });
}
