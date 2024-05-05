import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/wiredash.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('track event from isolate', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // do not fire first launch event
    await prefs.setString('_wiredashAppUsageID', 'asdfasdfasdfasdf');

    final token = ServicesBinding.rootIsolateToken!;
    await tester.runAsync(() async {
      await compute(
        (RootIsolateToken token) async {
          BackgroundIsolateBinaryMessenger.ensureInitialized(token);
          await Wiredash.trackEvent('test_event');
        },
        token,
      );
    });

    await tester.pumpAndSettle(Duration(seconds: 1));

    // has recorded one event from isolate
    await prefs.reload();
    final events = prefs
        .getKeys()
        .where((element) => element.startsWith('io.wiredash.events.default'))
        .toList();
    expect(events, hasLength(1));
  });
}
