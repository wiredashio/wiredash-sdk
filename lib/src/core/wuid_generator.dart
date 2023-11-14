// ignore: depend_on_referenced_packages
import 'package:async/async.dart' show ResultFuture;
import 'package:nanoid2/nanoid2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/_wiredash_internal.dart';

/// Wiredash Unique Identifier Generator
abstract class WuidGenerator {
  /// Generates a unique random secure id of [length]. Every call returns a new id
  String generateId(int length);

  /// Generates a unique random secure id of [length] and persists it in shared preferences
  ///
  /// Calling it a second time with the same [key] will return the same id
  Future<String> generatePersistedId(String key, int length);
}

/// Persistent implementation of [WuidGenerator] that uses shared preferences
class SharedPrefsWuidGenerator implements WuidGenerator {
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
      reportWiredashError(e, stack, 'Could not read $key from shared prefs');
    }

    // first time generation or fallback in case of sharedPrefs error
    final deviceId = generateId(length);
    try {
      final prefs = await sharedPrefsProvider().timeout(_sharedPrefsTimeout);
      await prefs.setString(key, deviceId).timeout(_sharedPrefsTimeout);
    } catch (e, stack) {
      reportWiredashError(e, stack, 'Could not write $key to shared prefs');
    }
    return deviceId;
  }

  /// A rather short timeout for shared preferences
  ///
  /// Usually shared preferences shouldn't fail. But if they do or don't react
  /// the deviceId fallback should generate in finite time
  static const _sharedPrefsTimeout = Duration(seconds: 2);
}

extension SubmitIdGenerator on WuidGenerator {
  /// Returns the unique id that is used for submitting feedback and promoter score
  ///
  /// The Future is lazy created an then cached, thus returns very fast when
  /// called multiple times
  Future<String> submitId() {
    return generatePersistedId('_wiredashDeviceID', 16);
  }
}

extension AppUsageIdGenerator on WuidGenerator {
  /// Returns the unique id that is used for tracking app usage
  ///
  /// The Future is lazy created an then cached, thus returns very fast when
  /// called multiple times
  Future<String> appUsageId() {
    return generatePersistedId('_wiredashAppUsageID', 16);
  }
}

extension PersistedFeedbackIds on WuidGenerator {
  /// Feedbacks that are saved locally (offline) until they are sent to the server
  String localFeedbackId() => generateId(8);
}

extension UniqueScreenshotName on WuidGenerator {
  /// screenshot attachment name (png)
  String screenshotFilename() => generateId(8);
}
