import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('kDevMode == false', () {
    final internalFile = File('lib/src/_wiredash_internal.dart');
    final content = internalFile.readAsStringSync();
    expect(content, contains('kDevMode = false'));
    expect(content, isNot(contains('kDevMode = true')));
  });
}
