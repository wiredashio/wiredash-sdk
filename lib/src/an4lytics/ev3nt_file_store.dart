import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:file/file.dart';
import 'package:flutter/foundation.dart';
import 'package:nanoid2/nanoid2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/an4lytics/ev3nt_store.dart';
import 'package:wiredash/src/core/services/error_report.dart';

/// Stores [AnalyticsEvent]s as one file per event on disk.
///
/// Unlike [SharedPreferencesAnalyticsEventStore] (which uses `shared_preferences`),
/// this store reads straight from disk on every call, so an event a background
/// isolate writes is immediately visible to the main isolate that uploads it.
/// `shared_preferences` can't do that on Linux/Windows: it keeps a per-isolate
/// in-memory cache over its JSON file that `reload()` does not refresh.
///
/// One file per event (named after the event key) means isolates never rewrite
/// a shared file from a stale snapshot, so concurrent writes can't clobber each
/// other.
///
/// Used on every platform except web, which has no background isolates and
/// keeps using [SharedPreferencesAnalyticsEventStore].
class FileAnalyticsEventStore implements AnalyticsEventStore {
  FileAnalyticsEventStore({
    required this.fileSystem,
    required this.directoryProvider,
    this.sharedPreferences,
  });

  static const Duration outdatedAfter = Duration(days: 3);
  static const String defaultProjectId = 'default';
  static const int maximumDiskSizeInBytes = 1024 * 1024; // 1MB
  static final RegExp eventKeyRegex =
      RegExp(r'^io\.wiredash\.events\.([\w-]+)\|(\d+)\|([\w-]+)$');

  final FileSystem fileSystem;

  /// Returns the parent directory in which the `wiredash/events` directory is
  /// created, usually the application support directory.
  final Future<String> Function() directoryProvider;

  /// Only used once to migrate events written by older SDK versions that stored
  /// them in `shared_preferences`. `null` disables the migration (tests).
  final Future<SharedPreferences> Function()? sharedPreferences;

  /// Test hook that points every store instance at one shared backing.
  ///
  /// `Wiredash.trackEvent` creates its own [WiredashServices], so the store that
  /// saves an event and the store that reads it back are different instances.
  /// In production they share the on-disk directory; in tests there is no disk,
  /// so set these (and reset them afterwards) to share an in-memory file system,
  /// the same way `SharedPreferences.setMockInitialValues` works.
  @visibleForTesting
  static FileSystem? debugFileSystem;

  /// See [debugFileSystem].
  @visibleForTesting
  static String? debugDirectory;

  bool _migrated = false;

  FileSystem get _fileSystem => debugFileSystem ?? fileSystem;

  Future<String> _baseDirectory() async =>
      debugDirectory ?? await directoryProvider();

  Future<Directory> _eventsDirectory() async {
    final fileSystem = _fileSystem;
    final path =
        fileSystem.path.join(await _baseDirectory(), 'wiredash', 'events');
    final directory = fileSystem.directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  String _fileName(String key) => '${Uri.encodeComponent(key)}.json';

  String? _keyForFile(File file) {
    final name = _fileSystem.path.basename(file.path);
    if (!name.endsWith('.json')) {
      return null;
    }
    final String key;
    try {
      key = Uri.decodeComponent(name.substring(0, name.length - 5));
    } catch (_) {
      // Not a file we wrote (malformed percent-encoding); ignore it.
      return null;
    }
    if (!eventKeyRegex.hasMatch(key)) {
      return null;
    }
    return key;
  }

  @override
  Future<void> saveEvent(AnalyticsEvent event, String? projectId) async {
    final project = projectId ?? defaultProjectId;
    final millis = event.createdAt!.millisecondsSinceEpoch;
    final discriminator = nanoid(length: 6);
    final key = "io.wiredash.events.$project|$millis|$discriminator";
    assert(
      eventKeyRegex.hasMatch(key),
      'Invalid event key: $key',
    );

    final directory = await _eventsDirectory();
    // Write to a temp file and rename it into place. Rename is atomic, so a
    // concurrent reader (e.g. the main isolate uploading) never sees a
    // half-written file and mistakes it for a corrupt event. The '.tmp' suffix
    // also keeps it out of [_keyForFile], which only matches '.json'.
    final file = directory.childFile(_fileName(key));
    final tempFile = directory.childFile('${_fileName(key)}.tmp');
    await tempFile.writeAsString(jsonEncode(serializeEventV1(event)));
    await tempFile.rename(file.path);
  }

  @override
  Future<Map<String, AnalyticsEvent>> getEvents(String? projectId) async {
    await _migrateFromSharedPreferences();
    final directory = await _eventsDirectory();

    final Map<String, AnalyticsEvent> result = {};
    for (final entity in await directory.list().toList()) {
      if (entity is! File) {
        continue;
      }
      final key = _keyForFile(entity);
      if (key == null) {
        continue;
      }
      final eventProjectId = eventKeyRegex.firstMatch(key)!.group(1);
      if (eventProjectId != defaultProjectId && eventProjectId != projectId) {
        continue;
      }
      try {
        final eventJson = await entity.readAsString();
        result[key] =
            deserializeEventV1(jsonDecode(eventJson) as Map<String, Object?>);
      } catch (e, stack) {
        reportWiredashInfo(
          e,
          stack,
          'Error when parsing event $key. Removing.',
        );
        await entity.delete();
      }
    }
    return result;
  }

  @override
  Future<void> removeEvent(String key) async {
    final directory = await _eventsDirectory();
    final file = directory.childFile(_fileName(key));
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<void> deleteOutdatedEvents() async {
    final directory = await _eventsDirectory();
    final unixThreeDaysAgo =
        clock.now().subtract(outdatedAfter).millisecondsSinceEpoch;

    for (final entity in await directory.list().toList()) {
      if (entity is! File) {
        continue;
      }
      final key = _keyForFile(entity);
      if (key == null) {
        continue;
      }
      final millis = int.parse(eventKeyRegex.firstMatch(key)!.group(2)!);
      if (millis < unixThreeDaysAgo) {
        await entity.delete();
      }
    }
  }

  @override
  Future<void> trimToDiskLimit() async {
    final directory = await _eventsDirectory();
    final eventFiles = <File>[];
    for (final entity in await directory.list().toList()) {
      if (entity is File && _keyForFile(entity) != null) {
        eventFiles.add(entity);
      }
    }

    int millisOf(File file) =>
        int.parse(eventKeyRegex.firstMatch(_keyForFile(file)!)!.group(2)!);
    // newest first, so the oldest events are dropped when over the limit
    eventFiles.sort((a, b) => millisOf(b).compareTo(millisOf(a)));

    int limit = maximumDiskSizeInBytes;
    final Set<String> keep = {};
    for (final file in eventFiles) {
      limit -= await file.length();
      if (limit < 0) {
        break;
      }
      keep.add(file.path);
    }

    for (final file in eventFiles) {
      if (!keep.contains(file.path)) {
        await file.delete();
      }
    }
  }

  @override
  Future<void> wipe() async {
    final directory = await _eventsDirectory();
    for (final entity in await directory.list().toList()) {
      if (entity is File && _keyForFile(entity) != null) {
        await entity.delete();
      }
    }
  }

  /// Moves events written by older SDK versions from `shared_preferences` into
  /// this store, once. Best-effort: failures are reported and ignored.
  ///
  /// Runs on [getEvents] only, which the submitter calls on the main isolate, so
  /// it never writes `shared_preferences` from a background isolate.
  Future<void> _migrateFromSharedPreferences() async {
    if (_migrated) {
      return;
    }
    _migrated = true;
    final prefsProvider = sharedPreferences;
    if (prefsProvider == null) {
      return;
    }
    try {
      final prefs = await prefsProvider();
      await prefs.reload();
      final keys = prefs.getKeys().where(eventKeyRegex.hasMatch).toList();
      if (keys.isEmpty) {
        return;
      }
      final directory = await _eventsDirectory();
      for (final key in keys) {
        final eventJson = prefs.getString(key);
        if (eventJson != null) {
          await directory.childFile(_fileName(key)).writeAsString(eventJson);
        }
        await prefs.remove(key);
      }
    } catch (e, stack) {
      reportWiredashInfo(
        e,
        stack,
        'Failed to migrate analytics events from shared_preferences',
      );
    }
  }
}
