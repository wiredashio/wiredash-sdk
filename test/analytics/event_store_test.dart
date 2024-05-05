import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/analytics/event_store.dart';

import '../util/flutter_error.dart';

void main() {
  test('ignore invalid events on disk', () async {
    SharedPreferences.setMockInitialValues({});
    final errors = captureFlutterErrors();
    final eventStore = PersistentAnalyticsEventStore(
      sharedPreferences: SharedPreferences.getInstance,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'io.wiredash.events.default|1234567890|abc',
      '{"invalid": "event"}',
    );
    final events = await eventStore.getEvents(null);

    errors.restoreDefaultErrorHandlers();

    expect(events, hasLength(0));
    // reported warning
    expect(
      errors.warningText,
      contains(
        'Error when parsing event io.wiredash.events.default|1234567890|abc. Removing',
      ),
    );
    expect(
      prefs.getString('io.wiredash.events.default|1234567890|abc'),
      isNull,
      reason: 'Invalid event should be removed from disk',
    );
  });
}
