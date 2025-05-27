import 'dart:io';

import 'package:test/test.dart';

void main() {
  group('File path validation', () {
    test('no file paths in lib/ should contain ad blocker targeted words', () {
      final libDir = Directory('lib');
      expect(libDir.existsSync(), isTrue, reason: 'lib directory should exist');

      final allFilePaths = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .map((file) => file.path.toLowerCase())
          .toList();

      // Words commonly blocked by ad blockers based on EasyPrivacy list
      const blockedWords = [
        'analytics',
        'event',
        'tracking',
        'tracker',
        'stats',
        'metric',
        'beacon',
        'pixel',
        'counter',
        'collect',
        'capture',
        'monitor',
      ];

      for (final filePath in allFilePaths) {
        for (final blockedWord in blockedWords) {
          expect(
            filePath,
            isNot(contains(blockedWord)),
            reason:
                'File path "$filePath" contains "$blockedWord" which may be '
                'blocked by ad blockers during development',
          );
        }
      }
    });
  });
}
