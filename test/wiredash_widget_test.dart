// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

    testWidgets('ping is send when the Widget gets updated', (tester) async {
      await tester.pumpWidget(
        const Wiredash(
          projectId: 'test',
          secret: 'invalid-secret',
          // this widget never settles, allowing us to jump in the future
          child: CircularProgressIndicator(),
        ),
      );
      final robot = WiredashTestRobot(tester);
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
      await tester.pump();
      await tester.pump();

      expect(api1.pingInvocations.count, 0);
      print("wait 5s");
      await tester.pump(const Duration(seconds: 5));
      expect(api1.pingInvocations.count, 1);
    });

    testWidgets('readding Wiredash simply works and sends pings again',
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
      final robot = await WiredashTestRobot.launchApp(
        tester,
        builder: (_) => const _FakeApp(),
      );
      expect(_FakeApp.initCount, 1);
      await robot.openWiredash();
      expect(_FakeApp.initCount, 1);
      await robot.closeWiredash();
      expect(_FakeApp.initCount, 1);
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
  const _FakeApp({Key? key}) : super(key: key);

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
      floatingActionButton: FloatingActionButton(
        onPressed: Wiredash.of(context).show,
      ),
    );
  }
}
