// ignore_for_file: avoid_print

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/common/network/wiredash_api.dart';
import 'package:wiredash/src/common/utils/project_credential_validator.dart';
import 'package:wiredash/src/common/widgets/wirecons.dart';
import 'package:wiredash/src/feedback/data/direct_feedback_submitter.dart';
import 'package:wiredash/src/feedback/data/feedback_submitter.dart';
import 'package:wiredash/src/feedback/data/persisted_feedback_item.dart';
import 'package:wiredash/src/feedback/ui/feedback_flow.dart';
import 'package:wiredash/src/wiredash_widget.dart';
import 'package:wiredash/wiredash.dart';

import 'util/invocation_catcher.dart';

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

    testWidgets('Send feedback with screenshot', (tester) async {
      TestWidgetsFlutterBinding.ensureInitialized();
      const MethodChannel channel =
          MethodChannel('plugins.flutter.io/path_provider_macos');
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        return '.';
      });
      await tester.pumpWidget(
        Wiredash(
          projectId: 'test',
          secret: 'test',
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  floatingActionButton: FloatingActionButton(
                    onPressed: Wiredash.of(context).show,
                  ),
                );
              },
            ),
          ),
        ),
      );
      final wiredashWidget =
          find.byType(Wiredash).evaluate().first as StatefulElement;
      final services = (wiredashWidget.state as WiredashState).debugServices;
      final mockApi = _MockApi();
      services.inject<WiredashApi>((_) => mockApi);
      services.inject<FeedbackSubmitter>(
        (locator) => DirectFeedbackSubmitter(locator.api),
      );

      expect(find.byType(WiredashFeedbackFlow), findsNothing);

      // Open Wiredash
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(WiredashFeedbackFlow), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'feedback_text');
      await tester.pumpAndSettle();
      await tester.waitUntil(
        find.byIcon(Wirecons.arrow_narrow_right),
        findsOneWidget,
      );
      expect(find.byIcon(Wirecons.arrow_narrow_right), findsOneWidget);
      expect(find.byIcon(Wirecons.chevron_double_up), findsOneWidget);
      // next to screenshot overview
      await tester.tap(find.byIcon(Wirecons.arrow_narrow_right));
      await tester.pumpHardAndSettle();

      // Go to screenshot section
      await tester.tap(find.byIcon(Wirecons.arrow_narrow_right));
      await tester.waitUntil(find.byIcon(Wirecons.camera), findsOneWidget);
      // TODO check app is interactive

      // Click the screenshot button
      await tester.tap(find.byIcon(Wirecons.camera));
      await tester.pumpAndSettle();

      // Wait for edit screen
      await tester.waitUntil(find.byIcon(Wirecons.check), findsOneWidget);

      // Check for save screenshot button
      expect(find.byIcon(Wirecons.check), findsOneWidget);
      expect(find.byIcon(Wirecons.pencil), findsOneWidget);

      await tester.tap(find.byIcon(Wirecons.check));
      await tester.pumpAndSettle();

      await tester.waitUntil(
        find.byIcon(Wirecons.arrow_narrow_right),
        findsOneWidget,
      );

      // TODO check that we see the screenshot
      await tester.tap(find.byIcon(Wirecons.arrow_narrow_right));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'dash@wiredash.io');
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.byIcon(Wirecons.check));
      await tester.pump();
      await tester.waitUntil(
        find.text('Thanks for your feedback!'),
        findsOneWidget,
      );
      final latestCall = mockApi.sendFeedbackInvocations.latest;
      final submittedFeedback = latestCall[0] as PersistedFeedbackItem?;
      expect(submittedFeedback, isNotNull);
      expect(latestCall['images'], hasLength(1));
    });

    testWidgets('Send feedback with labels and screenshot', (tester) async {
      TestWidgetsFlutterBinding.ensureInitialized();
      const MethodChannel channel =
          MethodChannel('plugins.flutter.io/path_provider_macos');
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        return '.';
      });
      await tester.pumpWidget(
        Wiredash(
          projectId: 'test',
          secret: 'test',
          feedbackOptions: const WiredashFeedbackOptions(
            labels: [
              Label(id: 'lbl-1', title: 'One', description: 'First'),
              Label(id: 'lbl-2', title: 'Two', description: 'Second'),
            ],
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  floatingActionButton: FloatingActionButton(
                    onPressed: Wiredash.of(context).show,
                  ),
                );
              },
            ),
          ),
        ),
      );
      final wiredashWidget =
          find.byType(Wiredash).evaluate().first as StatefulElement;
      final services = (wiredashWidget.state as WiredashState).debugServices;
      final mockApi = _MockApi();
      services.inject<WiredashApi>((_) => mockApi);
      services.inject<FeedbackSubmitter>(
        (locator) => DirectFeedbackSubmitter(locator.api),
      );

      expect(find.byType(WiredashFeedbackFlow), findsNothing);

      // Open Wiredash
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(WiredashFeedbackFlow), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'feedback_text');
      await tester.pumpAndSettle();
      await tester.waitUntil(
        find.byIcon(Wirecons.arrow_narrow_right),
        findsOneWidget,
      );
      expect(find.byIcon(Wirecons.arrow_narrow_right), findsOneWidget);
      expect(find.byIcon(Wirecons.chevron_double_up), findsOneWidget);

      await tester.tap(find.byIcon(Wirecons.arrow_narrow_right));
      await tester.pumpHardAndSettle();
      // Check labels exist
      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);

      await tester.tap(find.text('Two'));
      await tester.pumpAndSettle();

      // screenshot overview
      await tester.tap(find.byIcon(Wirecons.arrow_narrow_right));
      await tester.pumpHardAndSettle();

      // Go to screenshot section
      await tester.tap(find.byIcon(Wirecons.arrow_narrow_right));
      await tester.waitUntil(find.byIcon(Wirecons.camera), findsOneWidget);
      // TODO check app is interactive

      // Click the screenshot button
      await tester.tap(find.byIcon(Wirecons.camera));
      await tester.pumpAndSettle();

      // Wait for edit screen
      await tester.waitUntil(find.byIcon(Wirecons.check), findsOneWidget);

      // Check for save screenshot button
      expect(find.byIcon(Wirecons.check), findsOneWidget);
      expect(find.byIcon(Wirecons.pencil), findsOneWidget);

      await tester.tap(find.byIcon(Wirecons.check));
      await tester.pumpAndSettle();

      await tester.waitUntil(
        find.byIcon(Wirecons.arrow_narrow_right),
        findsOneWidget,
      );

      // TODO check that we see the screenshot
      await tester.tap(find.byIcon(Wirecons.arrow_narrow_right));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'dash@wiredash.io');
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.byIcon(Wirecons.check));
      await tester.pump();
      await tester.waitUntil(
        find.text('Thanks for your feedback!'),
        findsOneWidget,
      );
      final latestCall = mockApi.sendFeedbackInvocations.latest;
      final submittedFeedback = latestCall[0] as PersistedFeedbackItem?;
      expect(submittedFeedback, isNotNull);
      expect(submittedFeedback!.labels, ['lbl-2']);
      expect(submittedFeedback.message, 'feedback_text');
      expect(submittedFeedback.email, 'dash@wiredash.io');
      expect(latestCall['images'], hasLength(1));
    });
  });
}

extension on WidgetTester {
  /// Pumps and also drains the event queue, then pumps again and settles
  Future<void> pumpHardAndSettle([
    Duration duration = const Duration(milliseconds: 1),
  ]) async {
    await pumpAndSettle();
    // pump event queue, trigger timers
    await runAsync(() => Future.delayed(duration));
  }

  Future<void> waitUntil(
    Finder finder,
    Matcher matcher, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    // print('waitUntil $finder matches within $timeout');
    final stack = StackTrace.current;
    final start = DateTime.now();
    // await pumpAndSettle();
    var attempt = 0;
    while (true) {
      attempt++;
      if (matcher.matches(finder, {})) {
        break;
      }
      if (finder.runtimeType.toString().contains('_TextFinder')) {
        print('Text on screen (${DateTime.now().difference(start)}):');
        print(allWidgets.whereType<Text>().map((e) => e.data).toList());
      }

      final now = DateTime.now();
      if (now.isAfter(start.add(timeout))) {
        print(stack);
        if (finder.runtimeType.toString().contains('_TextFinder')) {
          print('Text on screen:');
          print(allWidgets.whereType<Text>().map((e) => e.data).toList());
        }
        throw 'Did not find $finder after $timeout (attempt: $attempt)';
      }

      final duration =
          Duration(milliseconds: math.pow(attempt, math.e).toInt());
      if (duration > const Duration(seconds: 1)) {
        // show continuous updates
        print(
          'Waiting for (attempt: $attempt)\n'
          '\tFinder: $finder to match\n'
          '\tMatcher: $matcher',
        );
      }
      if (attempt < 10) {
        await pumpAndSettle(duration);
      } else {
        await pumpHardAndSettle(duration);
      }
    }
  }
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

class _MockApi implements WiredashApi {
  List<PersistedFeedbackItem> submissions = [];
  MethodInvocationCatcher sendFeedbackInvocations =
      MethodInvocationCatcher('sendFeedback');
  @override
  Future<void> sendFeedback(
    PersistedFeedbackItem feedback, {
    List<ImageBlob> images = const [],
  }) async {
    return sendFeedbackInvocations
        .addMethodCall(namedArgs: {'images': images}, args: [feedback]);
  }

  @override
  Future<ImageBlob> sendImage(Uint8List screenshot) async {
    return ImageBlob({});
  }
}
