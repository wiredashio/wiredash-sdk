// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/options/wiredash_options_data.dart';
import 'package:wiredash/src/core/project_credential_validator.dart';
import 'package:wiredash/src/core/wiredash_widget.dart';

import 'util/invocation_catcher.dart';
import 'util/robot.dart';

void main() {
  group('Wiredash', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      debugServicesCreator = createMockServices;
      addTearDown(() => debugServicesCreator = null);
    });

    testWidgets('widget can be created', (tester) async {
      await tester.pumpWidget(
        const Wiredash(
          projectId: 'test',
          secret: 'test',
          child: SizedBox(),
        ),
      );

      expect(find.byType(Wiredash), findsOneWidget);
    });

    testWidgets('ping is send, even when the Widget gets updated',
        (tester) async {
      final robot = WiredashTestRobot(tester);
      robot.setupMocks();
      await tester.pumpWidget(
        const Wiredash(
          projectId: 'test',
          secret: 'invalid-secret',
          // this widget never settles, allowing us to jump in the future
          child: CircularProgressIndicator(),
        ),
      );
      final api1 = robot.mockServices.mockApi;
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      await tester.pump();

      expect(api1.pingInvocations.count, 0);
      await tester.pumpWidget(
        const Wiredash(
          projectId: 'test',
          secret: 'correct-secret',
          child: CircularProgressIndicator(),
        ),
      );
      final api2 = robot.mockServices.mockApi;
      expect(api1, isNot(api2)); // was updated
      await tester.pump();
      await tester.pump();

      expect(api2.pingInvocations.count, 0);
      print("wait 5s");
      await tester.pump(const Duration(seconds: 5));
      expect(api1.pingInvocations.count, 0);
      // makes sure the job doesn't die after being updated
      expect(api2.pingInvocations.count, 1);
    });

    testWidgets('reading Wiredash simply works and sends pings again',
        (tester) async {
      await tester.pumpWidget(
        const Wiredash(
          projectId: 'test',
          secret: 'test',
          // this widget never settles, allowing us to jump in the future
          child: CircularProgressIndicator(),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      final robot = WiredashTestRobot(tester);
      final api1 = robot.mockServices.mockApi;
      expect(api1.pingInvocations.count, 0);
      await tester.pump(const Duration(seconds: 5));
      expect(api1.pingInvocations.count, 1);

      // wait a bit, so we don't run in cases where the ping is not sent because
      // it was triggered too recently
      await tester.pump(const Duration(days: 1));

      // remove wiredash
      expect(find.byType(Wiredash), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      // add it a second time
      await tester.pumpWidget(
        const Wiredash(
          projectId: 'test',
          // new secret makes the api, thus the SyncEngine rebuild
          secret: 'new secret',
          child: SizedBox(),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      final api2 = robot.mockServices.mockApi;
      expect(api2.pingInvocations.count, 0);
      await tester.pump(const Duration(seconds: 5));
      expect(api2.pingInvocations.count, 1);
    });

    testWidgets('No custom metadata is submitted with ping()', (tester) async {
      final robot = WiredashTestRobot(tester);
      robot.setupMocks();
      await tester.pumpWidget(
        const Wiredash(
          projectId: 'test',
          secret: 'invalid-secret',
          // this widget never settles, allowing us to jump in the future
          child: CircularProgressIndicator(),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      await tester.pump();

      robot.wiredashController.modifyMetaData(
        (metaData) => metaData
          // ignore: deprecated_member_use_from_same_package
          ..buildNumber = 'customBuildNumber'
          // ignore: deprecated_member_use_from_same_package
          ..buildVersion = 'customBuildVersion'
          // ignore: deprecated_member_use_from_same_package
          ..buildCommit = 'customBuildCommit'
          ..userEmail = 'customUserEmail'
          ..userId = 'customUserId'
          ..custom = {'customKey': 'customValue'},
      );

      print("wait 5s");
      await tester.pump(const Duration(seconds: 5));
      final api = robot.mockServices.mockApi;
      expect(api.pingInvocations.count, 1);
      final body = api.pingInvocations.latest[0]! as PingRequestBody;
      // user is not able to inject any custom information into the ping
      final json = jsonEncode(body.toRequestJson());
      expect(json, isNot(contains('custom')));
    });

    testWidgets(
      'calls ProjectCredentialValidator.validate() initially',
      (tester) async {
        final _MockProjectCredentialValidator validator =
            _MockProjectCredentialValidator();

        debugServicesCreator = () => createMockServices()
          ..inject<ProjectCredentialValidator>((_) => validator);
        addTearDown(() => debugServicesCreator = null);

        await tester.pumpWidget(
          const Wiredash(
            projectId: 'my-project-id',
            secret: 'my-secret',
            child: SizedBox(),
          ),
        );

        validator.validateInvocations.verifyInvocationCount(1);
        final lastCall = validator.validateInvocations.latest;
        expect(lastCall['projectId'], 'my-project-id');
        expect(lastCall['secret'], 'my-secret');
      },
    );

    testWidgets('Do not lose state of app on open/close', (tester) async {
      final robot = await WiredashTestRobot(tester).launchApp(
        builder: (_) => const _FakeApp(),
      );
      expect(_FakeApp.initCount, 1);
      await robot.openWiredash();
      expect(_FakeApp.initCount, 1);
      await robot.closeWiredash();
      expect(_FakeApp.initCount, 1);
    });

    testWidgets('verify feedback options in show() overrides the options',
        (tester) async {
      const options = WiredashFeedbackOptions(
        email: EmailPrompt.hidden,
        screenshot: ScreenshotPrompt.hidden,
      );
      final robot = await WiredashTestRobot(tester).launchApp(
        feedbackOptions: const WiredashFeedbackOptions(
          email: EmailPrompt.optional,
          screenshot: ScreenshotPrompt.optional,
        ),
        builder: (context) {
          return Scaffold(
            body: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Wiredash.of(context).show(
                      options: options,
                    );
                  },
                  child: const Text('Feedback'),
                ),
              ],
            ),
          );
        },
        afterPump: () async {
          // The Localizations widget shows an empty Container while the
          // localizations are loaded (which is async)
          await tester.pumpAndSettle();
        },
      );

      await robot.openWiredash();
      expect(robot.services.wiredashModel.feedbackOptions, options);

      await robot.enterFeedbackMessage('test message');
      await robot.goToNextStep();

      // Verify that screenshot and email are hidden
      expect(
        robot.services.feedbackModel.feedbackFlowStatus,
        FeedbackFlowStatus.submit,
      );
    });

    group('localization', () {
      testWidgets(
          'Wiredash on top of MaterialApp does not override existing Localizations',
          (tester) async {
        final robot = await WiredashTestRobot(tester).launchApp(
          appLocalizationsDelegates: const [
            _AppLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          builder: (context) {
            final _AppLocalizations l10n =
                Localizations.of(context, _AppLocalizations)!;
            return Scaffold(
              body: Column(
                children: [
                  Text(l10n.customAppString),
                  GestureDetector(
                    onTap: () {
                      Wiredash.of(context).show();
                    },
                    child: const Text('Feedback'),
                  ),
                ],
              ),
            );
          },
          afterPump: () async {
            // The Localizations widget shows an empty Container while the
            // localizations are loaded (which is async)
            await tester.pumpAndSettle();
          },
        );

        expect(find.text('custom app string'), findsOneWidget);

        await robot.openWiredash();

        expect(find.text('custom app string'), findsOneWidget);
      });

      testWidgets(
          'Wiredash below MaterialApp does not override existing Localizations',
          (tester) async {
        final robot = await WiredashTestRobot(tester).launchApp(
          appLocalizationsDelegates: const [
            _AppLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          builder: (context) {
            // Wrap screen with Wiredash, because that should work too
            return Wiredash(
              projectId: 'test',
              secret: 'test',
              options: WiredashOptionsData(
                locale: const Locale('test'),
                localizationDelegate: WiredashTestLocalizationDelegate(),
              ),
              child: Builder(
                builder: (context) {
                  // Access localization with context below
                  final _AppLocalizations l10n =
                      Localizations.of(context, _AppLocalizations)!;
                  return Scaffold(
                    body: Column(
                      children: [
                        Text(l10n.customAppString),
                        GestureDetector(
                          onTap: () {
                            Wiredash.of(context).show();
                          },
                          child: const Text('Feedback'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
          afterPump: () async {
            // The Localizations widget shows an empty Container while the
            // localizations are loaded (which is async)
            await tester.pumpAndSettle();
          },
        );

        expect(find.text('custom app string'), findsOneWidget);

        await robot.openWiredash();

        expect(find.text('custom app string'), findsOneWidget);
      });
    });

    testWidgets('Track telemetry', (tester) async {
      final robot = await WiredashTestRobot(tester).launchApp();
      await robot.openWiredash();
      final appStartCount = await robot.services.appTelemetry.appStartCount();
      expect(appStartCount, 1);
      final firstAppStart = await robot.services.appTelemetry.firstAppStart();
      expect(firstAppStart, isNotNull);
    });
  });
}

class _MockProjectCredentialValidator extends Fake
    implements ProjectCredentialValidator {
  final MethodInvocationCatcher validateInvocations =
      MethodInvocationCatcher('validate');

  @override
  Future<void> validate({
    required String projectId,
    required String secret,
  }) async {
    return validateInvocations.addAsyncMethodCall(
      namedArgs: {
        'projectId': projectId,
        'secret': secret,
      },
    )?.future;
  }
}

class _FakeApp extends StatefulWidget {
  const _FakeApp();

  @override
  State<_FakeApp> createState() => _FakeAppState();

  static int initCount = 0;
}

class _FakeAppState extends State<_FakeApp> {
  @override
  void initState() {
    _FakeApp.initCount++;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              Wiredash.of(context).show();
            },
            child: const Text('Feedback'),
          ),
        ],
      ),
    );
  }
}

class _AppLocalizations {
  final Locale locale;

  const _AppLocalizations({required this.locale});

  String get customAppString => 'custom app string';

  static const LocalizationsDelegate<_AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<_AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<_AppLocalizations> load(Locale locale) async {
    return _AppLocalizations(locale: locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
