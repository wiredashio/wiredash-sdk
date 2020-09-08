import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';
import 'package:wiredash/src/wiredash_widget.dart';
import 'package:wiredash/wiredash.dart';

import 'feedback/data/pending_feedback_item_storage_test.dart';

void main() {
  group('Translation overflow tests', () {
    MockSharedPreferences mockSharedPreferences;

    setUpAll(() {
      mockSharedPreferences = MockSharedPreferences();
      when(mockSharedPreferences.containsKey(any)).thenReturn(false);

      debugObtainSharedPreferencesInstance = () async => mockSharedPreferences;
      debugCreateHttpClient =
          () => MockClient((request) async => Response('body', 200));
    });

    testWidgets(
        'none of the supported locales should cause overflow on iPhone SE',
        (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();

      // Sets the test window size to an iPhone SE from 2016.
      tester.binding.window.physicalSizeTestValue = const Size(320, 569);

      for (final locale in WiredashLocalizations.supportedLocales) {
        WiredashController controller;

        await tester.pumpWidget(
          Wiredash(
            projectId: 'null',
            secret: 'null',
            navigatorKey: navigatorKey,
            options: WiredashOptionsData(locale: locale),
            child: MaterialApp(
              navigatorKey: navigatorKey,
              home: Builder(
                builder: (context) {
                  controller = Wiredash.of(context);
                  return Container();
                },
              ),
            ),
          ),
        );

        controller.show();
        await tester.pump();

        expect(
          tester.takeException(),
          isNull,
          reason: 'The translations for locale $locale cause an overflow.',
        );
      }
    });
  });
}
