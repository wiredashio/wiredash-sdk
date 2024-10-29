import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import 'wiredash_tester.dart';

enum PumpFunctions {
  plainFlutter,
  spot,
}

void main() {
  testWidgets('warmup', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MaterialApp(home: _SyncChange())),
    );
    await act.tap(spotText('Start'));
    await tester.pump();
  });

  final pumpFunctions = [PumpFunctions.plainFlutter, PumpFunctions.spot];

  for (final pumpFn in pumpFunctions) {
    group('pump function $pumpFn', () {
      testWidgets('sync state change - no explicit pump', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: _SyncChange()));
        await act.tap(spotText('Start'));
        spotText('Hello').existsOnce();
      });

      testWidgets('ChangeNotifier - no explicit pump', (tester) async {
        await tester
            .pumpWidget(const MaterialApp(home: _ChangeNotifierChange()));
        await act.tap(spotText('Start'));
        spotText('Hello').existsOnce();
      });

      testWidgets('postFrame callback - requires extra pump', (tester) async {
        await tester
            .pumpWidget(const MaterialApp(home: _PostFrameCallbackChange()));
        await act.tap(spotText('Start'));
        spotText('Hello').doesNotExist();
        switch (pumpFn) {
          case PumpFunctions.plainFlutter:
            await tester.pump();
            break;
          case PumpFunctions.spot:
            await tester.pumpSmart();
            break;
        }
        spotText('Hello').existsOnce();
      });

      testWidgets('Future - requires triggering timers + pump', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: _FutureChange()));
        await act.tap(spotText('Start'));
        spotText('Hello').doesNotExist();
        switch (pumpFn) {
          case PumpFunctions.plainFlutter:
            await tester.binding.delayed(Duration.zero);
            await tester.pump();
            break;
          case PumpFunctions.spot:
            await tester.pumpSmart();
            break;
        }
        spotText('Hello').existsOnce();
      });

      testWidgets('Timer - requires elapse time + pump', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: _TimerChange(
              duration: const Duration(seconds: 2),
            ),
          ),
        );
        await act.tap(spotText('Start'));
        spotText('Hello').doesNotExist();
        switch (pumpFn) {
          case PumpFunctions.plainFlutter:
            await tester.binding.delayed(const Duration(seconds: 2));
            await tester.pump();
            break;
          case PumpFunctions.spot:
            await tester.pumpBetter(const Duration(seconds: 2));
            break;
        }
        spotText('Hello').existsOnce();
      });
    });
  }
}

class _SyncChange extends StatefulWidget {
  const _SyncChange({super.key});

  @override
  State<_SyncChange> createState() => _SyncChangeState();
}

class _SyncChangeState extends State<_SyncChange> {
  bool showGreeting = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showGreeting) const Text('Hello'),
        ElevatedButton(
          onPressed: () {
            setState(() {
              showGreeting = true;
            });
          },
          child: const Text('Start'),
        ),
      ],
    );
  }
}

class _PostFrameCallbackChange extends StatefulWidget {
  const _PostFrameCallbackChange({super.key});

  @override
  State<_PostFrameCallbackChange> createState() =>
      _PostFrameCallbackChangeState();
}

class _PostFrameCallbackChangeState extends State<_PostFrameCallbackChange> {
  bool showGreeting = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showGreeting) const Text('Hello'),
        ElevatedButton(
          onPressed: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                showGreeting = true;
              });
            });
          },
          child: const Text('Start'),
        ),
      ],
    );
  }
}

class _FutureChange extends StatefulWidget {
  const _FutureChange({super.key});

  @override
  State<_FutureChange> createState() => _FutureChangeState();
}

class _FutureChangeState extends State<_FutureChange> {
  bool showGreeting = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showGreeting) const Text('Hello'),
        ElevatedButton(
          onPressed: () {
            Future.delayed(Duration.zero, () {
              setState(() {
                showGreeting = true;
              });
            });
          },
          child: const Text('Start'),
        ),
      ],
    );
  }
}

class _TimerChange extends StatefulWidget {
  _TimerChange({required this.duration});

  final Duration duration;

  @override
  State<_TimerChange> createState() => _TimerChangeState();
}

class _TimerChangeState extends State<_TimerChange> {
  bool showGreeting = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showGreeting) const Text('Hello'),
        ElevatedButton(
          onPressed: () {
            Future.delayed(widget.duration, () {
              setState(() {
                showGreeting = true;
              });
            });
          },
          child: const Text('Start'),
        ),
      ],
    );
  }
}

class _ChangeNotifierChange extends StatefulWidget {
  const _ChangeNotifierChange({super.key});

  @override
  State<_ChangeNotifierChange> createState() => _ChangeNotifierChangeState();
}

class _ChangeNotifierChangeState extends State<_ChangeNotifierChange> {
  final _GreetingChangeNotifier _changeNotifier = _GreetingChangeNotifier();

  @override
  void initState() {
    super.initState();
    _changeNotifier.addListener(() {
      print('notifier changed');
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_changeNotifier.showGreeting) const Text('Hello'),
        ElevatedButton(
          onPressed: () {
            _changeNotifier.show();
          },
          child: const Text('Start'),
        ),
      ],
    );
  }
}

class _GreetingChangeNotifier extends ChangeNotifier {
  bool showGreeting = false;

  void show() {
    showGreeting = true;
    notifyListeners();
  }
}
