import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('overflow tests', () {
    FlutterDriver driver;
    final errorsByLocale = <String, Set<String>>{};

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    Future<void> _takeOverflowScreenshotIfNeeded(
      String name,
      String locale,
    ) async {
      // Give the UI some "time to settle" and possible overflow errors to happen
      await Future.delayed(const Duration(milliseconds: 100));

      final error = await driver.requestData('getLastError');
      if (error != null) {
        final bytes = await driver.screenshot();
        await Directory('test_driver/overflow_screenshots')
            .create(recursive: true);
        await File('test_driver/overflow_screenshots/$locale-$name.png')
            .writeAsBytesSync(bytes);

        errorsByLocale[locale] ??= {};
        errorsByLocale[locale].add(name);
      }
    }

    test("translations for supported languages don't overflow", () async {
      final supportedLocales =
          (await driver.requestData('getSupportedLocales')).split(',');

      for (final locale in supportedLocales) {
        await driver.requestData('changeLocale:$locale');

        await driver
            .tap(find.byValueKey('wiredash.example.show_wiredash_button'));
        await _takeOverflowScreenshotIfNeeded('intro', locale);

        await driver
            .tap(find.byValueKey('wiredash.sdk.intro.report_a_bug_button'));
        await _takeOverflowScreenshotIfNeeded('take_screenshot', locale);

        await driver.tap(find.byValueKey('wiredash.sdk.next_button'));
        await _takeOverflowScreenshotIfNeeded('save_screenshot', locale);

        await driver.tap(find.byValueKey('wiredash.sdk.next_button'));
        await _takeOverflowScreenshotIfNeeded('give_feedback', locale);

        await driver.tap(find.byValueKey('wiredash.sdk.text_field'));
        await driver.enterText('hello');
        await driver.tap(find.byValueKey('wiredash.sdk.save_feedback_button'));
        await _takeOverflowScreenshotIfNeeded('email', locale);

        await driver.tap(find.byValueKey('wiredash.sdk.text_field'));
        await driver.enterText('example@example.com');
        await driver.tap(find.byValueKey('wiredash.sdk.send_feedback_button'));
        await _takeOverflowScreenshotIfNeeded('thanks', locale);

        await driver.tap(find.byValueKey('wiredash.sdk.exit_button'));
      }

      if (errorsByLocale.isNotEmpty) {
        final buffer = StringBuffer(
          'Encountered overflow errors for the following locales:',
        )..writeln();

        for (final entry in errorsByLocale.entries) {
          buffer
              .writeln('- ${entry.key}: section(s) [${entry.value.join(',')}]');
        }

        buffer
          ..writeln()
          ..writeln(
            'Screenshots of overflowing pages have been saved in test_driver/overflow_screenshots.',
          );
        fail(buffer.toString());
      }
    }, timeout: const Timeout(Duration(minutes: 2)));
  });
}
