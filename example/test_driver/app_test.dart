import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'dart:convert';

void main() {
  group('blabla', () {
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('starts at 0', () async {
      final supportedLocales =
          (await driver.requestData('getSupportedLocales')).split(',');

      for (final locale in supportedLocales) {
        await driver.requestData('changeLocale:$locale');

        await driver
            .tap(find.byValueKey('wiredash.example.show_wiredash_button'));

        await driver
            .tap(find.byValueKey('wiredash.sdk.intro.report_a_bug_button'));
        await driver.tap(find.byValueKey('wiredash.sdk.next_button'));
        await driver.tap(find.byValueKey('wiredash.sdk.next_button'));

        await driver.tap(find.byValueKey('wiredash.sdk.text_field'));
        await driver.enterText('hello');
        await driver.tap(find.byValueKey('wiredash.sdk.save_feedback_button'));

        await driver.tap(find.byValueKey('wiredash.sdk.text_field'));
        await driver.enterText('example@example.com');
        await driver.tap(find.byValueKey('wiredash.sdk.send_feedback_button'));

        await driver.tap(find.byValueKey('wiredash.sdk.exit_button'));
      }

      final errors = await driver.requestData('getErrors');

      if (errors != null) {
        final buffer = StringBuffer(
          'Encountered overflow errors for the following locales:',
        )..writeln();

        final errorsByLocale = (json.decode(errors) as Map).cast<String, int>();
        for (final entry in errorsByLocale.entries) {
          buffer.writeln('- ${entry.key}: ${entry.value} errors');
        }

        fail(buffer.toString());
      }
    }, timeout: const Timeout(Duration(minutes: 2)));
  });
}
