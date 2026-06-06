import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/wiredash.dart';
import 'package:wiredash_theming/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'event tracked from a background isolate is written to disk '
      'where the main isolate can read it', (tester) async {
    final eventsDir = await _resetEventState();

    final token = ServicesBinding.rootIsolateToken!;
    await tester.runAsync(() async {
      await compute(_trackEventOnBackgroundIsolate, token);
    });

    // The main isolate reads the file the background isolate wrote, fresh from
    // disk. With shared_preferences on Linux and Windows the main isolate's
    // in-memory cache doesn't pick up that write until the process restarts, so
    // the upload was delayed until the next app launch instead of being prompt.
    final eventFiles = _eventFiles(eventsDir);
    expect(eventFiles, hasLength(1));

    // The event keeps the environment it was given on the background isolate, so
    // it is later submitted to the API with that exact environment.
    final event = jsonDecode(eventFiles.single.readAsStringSync())
        as Map<String, Object?>;
    expect(event['eventName'], 'test_event');
    expect(event['environment'], 'background-isolate-env');
  });

  testWidgets(
      'event tracked from a background isolate reaches the mounted Wiredash '
      'widget on the main isolate and is uploaded to the backend',
      (tester) async {
    await _resetEventState();

    // Intercept the real dart:io HttpClient (package:http's default Client uses
    // it under the hood) so we can observe the actual network request without
    // hitting the backend.
    final captured = Completer<_CapturedRequest>();
    HttpOverrides.global = _CapturingHttpOverrides((request) {
      final isSendEvents = request.url.path.endsWith('/sendEvents');
      if (isSendEvents &&
          request.body.contains('test_event') &&
          !captured.isCompleted) {
        captured.complete(request);
      }
    });
    addTearDown(() => HttpOverrides.global = null);

    // Mount the real app so a Wiredash instance is registered on the main
    // isolate and listens for the background isolate's wake-up ping.
    await tester.pumpWidget(WiredashExampleApp());
    await tester.pump();

    final token = ServicesBinding.rootIsolateToken!;
    late final _CapturedRequest request;
    await tester.runAsync(() async {
      // Track on a background isolate. After saving the event the SDK pings the
      // main isolate, which reloads the event from disk and uploads it without
      // waiting for the next lifecycle flush.
      await compute(_trackEventOnBackgroundIsolate, token);
      request = await captured.future.timeout(const Duration(seconds: 20));
    });

    // Full circle: the event the background isolate wrote left the device as a
    // POST to the Wiredash backend, carrying the event name and the exact
    // environment it was given on the background isolate.
    expect(request.method, 'POST');
    expect(request.url.host, 'api.wiredash.io');
    expect(request.url.path, endsWith('/sendEvents'));
    expect(request.headers['project'], isNotEmpty);
    expect(request.body, contains('test_event'));
    expect(request.body, contains('background-isolate-env'));
  });
}

/// Tracks a single event from a background isolate.
///
/// Top-level so it can be passed to [compute], which can only run functions that
/// are sendable across isolates.
Future<void> _trackEventOnBackgroundIsolate(RootIsolateToken token) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(token);
  await Wiredash.trackEvent(
    'test_event',
    environment: 'background-isolate-env',
  );
}

/// Clears any events left over from a previous run and suppresses the automatic
/// first-launch event, so the tracked event is the only one in play.
Future<Directory> _resetEventState() async {
  final supportDir = await getApplicationSupportDirectory();
  final eventsDir = Directory(p.join(supportDir.path, 'wiredash', 'events'));
  if (eventsDir.existsSync()) {
    eventsDir.deleteSync(recursive: true);
  }
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('_wiredashAppUsageID', 'asdfasdfasdfasdf');
  return eventsDir;
}

List<File> _eventFiles(Directory eventsDir) {
  if (!eventsDir.existsSync()) {
    return [];
  }
  return eventsDir
      .listSync()
      .whereType<File>()
      .where((file) => p.basename(file.path).contains('io.wiredash.events'))
      .toList();
}

/// What the SDK actually sent over the wire, captured by [_CapturingHttpOverrides].
class _CapturedRequest {
  _CapturedRequest({
    required this.method,
    required this.url,
    required this.headers,
    required this.body,
  });

  final String method;
  final Uri url;
  final Map<String, String> headers;
  final String body;
}

/// Routes every dart:io HttpClient request through a fake that records it and
/// answers with an empty `200`, so no request leaves the machine.
class _CapturingHttpOverrides extends HttpOverrides {
  _CapturingHttpOverrides(this.onRequest);

  final void Function(_CapturedRequest request) onRequest;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _FakeHttpClient(onRequest);
  }
}

class _FakeHttpClient implements HttpClient {
  _FakeHttpClient(this.onRequest);

  final void Function(_CapturedRequest request) onRequest;

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return _FakeHttpClientRequest(method, url, onRequest);
  }

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientRequest implements HttpClientRequest {
  _FakeHttpClientRequest(this.method, this.uri, this._onRequest);

  @override
  final String method;

  @override
  final Uri uri;

  final void Function(_CapturedRequest request) _onRequest;

  @override
  final HttpHeaders headers = _FakeHttpHeaders();

  final List<int> _body = [];

  @override
  bool followRedirects = true;

  @override
  int maxRedirects = 5;

  @override
  int contentLength = -1;

  @override
  bool persistentConnection = true;

  @override
  void add(List<int> data) => _body.addAll(data);

  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    await for (final chunk in stream) {
      _body.addAll(chunk);
    }
  }

  @override
  Future<HttpClientResponse> close() async {
    _onRequest(
      _CapturedRequest(
        method: method,
        url: uri,
        headers: (headers as _FakeHttpHeaders).values,
        body: utf8.decode(_body),
      ),
    );
    return _FakeHttpClientResponse();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpHeaders implements HttpHeaders {
  final Map<String, String> values = {};

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    values[name] = value.toString();
  }

  @override
  void forEach(void Function(String name, List<String> values) action) {
    values.forEach((name, value) => action(name, [value]));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientResponse extends StreamView<List<int>>
    implements HttpClientResponse {
  _FakeHttpClientResponse() : super(Stream.value(utf8.encode('{}')));

  @override
  int get statusCode => 200;

  @override
  String get reasonPhrase => 'OK';

  @override
  int get contentLength => -1;

  @override
  bool get isRedirect => false;

  @override
  bool get persistentConnection => false;

  @override
  HttpHeaders get headers => _FakeHttpHeaders();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
