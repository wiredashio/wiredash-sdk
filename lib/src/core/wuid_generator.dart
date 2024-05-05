// ignore: depend_on_referenced_packages
import 'dart:async';

import 'package:async/async.dart' show ResultFuture;
import 'package:nanoid2/nanoid2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/utils/disposable.dart';

/// Wiredash Unique Identifier Generator
abstract class WuidGenerator {
  /// Generates a unique random secure id of [length]. Every call returns a new id
  String generateId(int length);

  /// Generates a unique random secure id of [length] and persists it in shared preferences
  ///
  /// Calling it a second time with the same [key] will return the same id
  Future<String> generatePersistedId(String key, int length);

  /// Adds a listener that is called when a new key is created
  Disposable addOnKeyCreatedListener(void Function(String key) listener);
}

/// Persistent implementation of [WuidGenerator] that uses shared preferences
class SharedPrefsWuidGenerator
    with OnKeyCreatedNotifier
    implements WuidGenerator {
  final Future<SharedPreferences> Function() sharedPrefsProvider;

  SharedPrefsWuidGenerator({
    required this.sharedPrefsProvider,
  });

  final Map<String, ResultFuture<String>> _cache = {};

  /// Generates a random secure nanoid with 36 characters and persists it in
  /// shared preferences with the given [key]
  ///
  /// The identifier stored in shared preferences is only deleted when the app
  /// is reinstalled
  ///
  /// https://zelark.github.io/nano-id-cc/
  /// ```
  /// 36 chars / length: 8 => 238K IDs needed, in order to have a 1% probability of at least one collision.
  /// 36 chars / length: 12 => 308M IDs needed, in order to have a 1% probability of at least one collision.
  /// 36 chars / length: 16 => 399B IDs needed, in order to have a 1% probability of at least one collision.
  /// 36 chars / length: 32 => More than 1 quadrillion years or 1,128,353,804,460T IDs needed, in order to have a 1% probability of at least one collision.
  /// ```
  @override
  String generateId(int length) {
    return nanoid(length: length, alphabet: Alphabet.noDoppelgangerSafe);
  }

  @override
  Future<String> generatePersistedId(String key, int length) async {
    final cachedFuture = _cache[key];

    if (cachedFuture != null) {
      if (!cachedFuture.isComplete) {
        return cachedFuture;
      }
      // do not cache errored futures, instead try again
      if (cachedFuture.isComplete && cachedFuture.result!.isError) {
        _cache.remove(key);
      }
    }

    final id = loadFromPrefs(key, length);
    _cache[key] = ResultFuture(id);
    return id;
  }

  Future<String> loadFromPrefs(String key, int length) async {
    try {
      final prefs = await sharedPrefsProvider().timeout(_sharedPrefsTimeout);
      if (prefs.containsKey(key)) {
        final recovered = prefs.getString(key);
        if (recovered != null) {
          // recovered id from prefs
          return recovered;
        }
      }
    } catch (e, stack) {
      // might fail when users manipulate shared prefs. Creating a new id in
      // that case
      reportWiredashInfo(e, stack, 'Could not read $key from shared prefs');
    }

    // first time generation or fallback in case of sharedPrefs error
    final deviceId = generateId(length);
    Future(() => notifyKeyCreated(key));
    try {
      final prefs = await sharedPrefsProvider().timeout(_sharedPrefsTimeout);
      await prefs.setString(key, deviceId).timeout(_sharedPrefsTimeout);
    } catch (e, stack) {
      reportWiredashInfo(e, stack, 'Could not write $key to shared prefs');
    }
    return deviceId;
  }

  /// A rather short timeout for shared preferences
  ///
  /// Usually shared preferences shouldn't fail. But if they do or don't react
  /// the deviceId fallback should generate in finite time
  static const _sharedPrefsTimeout = Duration(seconds: 2);
}

/// Allows notifying listeners when a new key is created
///
/// Used by [SharedPrefsWuidGenerator] and `IncrementalIdGenerator` in tests
mixin OnKeyCreatedNotifier {
  final List<void Function(String key)> _onKeyCreatedListeners = [];

  Disposable addOnKeyCreatedListener(void Function(String key) listener) {
    _onKeyCreatedListeners.add(listener);
    return Disposable(() => _onKeyCreatedListeners.remove(listener));
  }

  void notifyKeyCreated(String key) {
    for (final listener in _onKeyCreatedListeners.toList()) {
      try {
        listener(key);
      } catch (e, stack) {
        reportWiredashError(e, stack, 'Error in onKeyCreatedListener');
      }
    }
  }
}

/// Handles the persistent unique id for feedback
extension SubmitIdGenerator on WuidGenerator {
  /// Returns the unique id that is used for submitting feedback and promoter score
  ///
  /// The id is either a 16 character long nanoid (SDK 1.8.0+)
  /// or a 32 character long uuid when created with SDK <1.8.0
  ///
  /// The Future is lazy created an then cached, thus returns very fast when
  /// called multiple times
  Future<String> submitId() {
    return generatePersistedId('_wiredashDeviceID', 16);
  }
}

/// Handles the persistent unique id for analytics
extension AppUsageIdGenerator on WuidGenerator {
  /// Returns the unique id that is used for tracking app usage
  ///
  /// The Future is lazy created an then cached, thus returns very fast when
  /// called multiple times
  Future<String> appUsageId() {
    return generatePersistedId('_wiredashAppUsageID', 16);
  }
}

/// Creates the local uuids for feedback
extension PersistedFeedbackIds on WuidGenerator {
  /// Feedbacks that are saved locally (offline) until they are sent to the server
  String localFeedbackId() => generateId(8);
}

/// Creates the local uuids for screenshots
extension UniqueScreenshotName on WuidGenerator {
  /// screenshot attachment name (png)
  String screenshotFilename() => generateId(8);
}

/// Converts a uuid to a nanoid
String uuidToNanoId(String uuid, {int maxLength = 21}) {
  return uuid.replaceAll('-', '').takeFirst(maxLength);
}

extension on String {
  String takeFirst(int length) {
    if (length >= this.length) return this;
    return substring(0, length);
  }
}
