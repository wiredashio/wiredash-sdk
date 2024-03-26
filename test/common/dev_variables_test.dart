import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('kDevMode == false', () {
    final internalFile = File('lib/src/_wiredash_internal.dart');
    final content = internalFile.readAsStringSync();
    expect(content, contains('kDevMode = false'));
    expect(content, isNot(contains('kDevMode = true')));
  });

  test('_kDebugStreamPod == false', () {
    final coreFile = File('lib/src/core/services/streampod.dart');
    final content = coreFile.readAsStringSync();
    expect(content, contains('_kDebugStreamPod = false'));
    expect(content, isNot(contains('_kDebugStreamPod = true')));
  });
}
