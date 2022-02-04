// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/common/utils/project_credential_validator.dart';
import 'package:wiredash/src/wiredash_widget.dart';

import 'util/invocation_catcher.dart';
import 'util/robot.dart';

void main() {
  group('Wiredash', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
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

    testWidgets(
      'calls ProjectCredentialValidator.validate() initially',
      (tester) async {
        final _MockProjectCredentialValidator validator =
            _MockProjectCredentialValidator();
        debugProjectCredentialValidator = validator;
        addTearDown(() {
          debugProjectCredentialValidator = const ProjectCredentialValidator();
        });

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
    validateInvocations
        .addMethodCall(namedArgs: {'projectId': projectId, 'secret': secret});
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
