import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wiredash/wiredash.dart';

import '../util/flutter_error.dart';

void main() {
  group('issue 341', () {
    testWidgets('no LocalizationsDelegate', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(TestWidget.createCount, 1);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(TestWidget.createCount, 1); // Nice!
    });

    testWidgets('LocalizationsDelegate with SynchronousFuture', (tester) async {
      await tester.pumpWidget(const MyApp(asyncDelegate: false));
      await tester.pumpAndSettle();
      expect(TestWidget.createCount, 1);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(TestWidget.createCount, 1); // Nice!
    });

    testWidgets('async LocalizationsDelegate', (tester) async {
      final errors = captureFlutterErrors();
      await tester.pumpWidget(const MyApp(asyncDelegate: true));
      await tester.pumpAndSettle();
      expect(TestWidget.createCount, 1);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      errors.restoreDefaultErrorHandlers();
      // This causes the TestWidget to lose its state
      expect(TestWidget.createCount, 2);
      expect(errors.presentErrorText, contains("SynchronousFuture"));
      expect(
        errors.presentErrorText,
        contains("AsyncCustomWiredashTranslationsDelegate"),
      );
      expect(errors.presentError.length, 1);
    });
  });
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    this.asyncDelegate,
  });

  @override
  State<MyApp> createState() => _MyAppState();

  final bool? asyncDelegate;
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Wiredash(
      projectId: "xxxxx",
      secret: "xxxxx",
      options: WiredashOptionsData(
        localizationDelegate: widget.asyncDelegate == null
            ? null
            : widget.asyncDelegate == true
                ? const AsyncCustomWiredashTranslationsDelegate()
                : const SyncCustomWiredashTranslationsDelegate(),
      ),
      child: const MaterialApp(
        home: TestWidget(),
      ),
    );
  }
}

class TestWidget extends StatefulWidget {
  const TestWidget({super.key});

  @override
  State<TestWidget> createState() => _TestWidgetState();

  static int createCount = 0;
}

class _TestWidgetState extends State<TestWidget> {
  @override
  void initState() {
    super.initState();
    debugPrint("TestWidget initState");
    addTearDown(() {
      TestWidget.createCount = 0;
    });
    TestWidget.createCount++;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Placeholder(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Wiredash.of(context).show(),
      ),
    );
  }
}

class AsyncCustomWiredashTranslationsDelegate
    extends LocalizationsDelegate<WiredashLocalizations> {
  const AsyncCustomWiredashTranslationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en'].contains(locale.languageCode);
  }

  @override
  Future<WiredashLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'en':
        return _EnOverrides();
      default:
        throw "Unsupported locale $locale";
    }
  }

  @override
  bool shouldReload(AsyncCustomWiredashTranslationsDelegate old) => false;
}

class SyncCustomWiredashTranslationsDelegate
    extends LocalizationsDelegate<WiredashLocalizations> {
  const SyncCustomWiredashTranslationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en'].contains(locale.languageCode);
  }

  @override
  Future<WiredashLocalizations> load(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return SynchronousFuture(_EnOverrides());
      default:
        throw "Unsupported locale $locale";
    }
  }

  @override
  bool shouldReload(SyncCustomWiredashTranslationsDelegate old) => false;
}

class _EnOverrides extends WiredashLocalizationsEn {
  @override
  String get feedbackStep1MessageHint => 'Test';
}
