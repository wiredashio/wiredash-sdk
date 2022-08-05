import 'package:clock/clock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/_nps.dart';
import 'package:wiredash/src/metadata/build_info/device_id_generator.dart';

/// Decides when it is time to show the NPS survey
class NpsTrigger {
  NpsTrigger({
    required this.sharedPreferencesProvider,
    required this.options,
    required this.deviceIdGenerator,
  });

  final Future<SharedPreferences> Function() sharedPreferencesProvider;
  final NpsOptions options;
  final DeviceIdGenerator deviceIdGenerator;

  // TODO save together with deviceId? Currently that is calculated lazily at first usage
  static const userSince = 'io.wiredash.device_registered_date';

  Future<bool> shouldShowNps() async {
    final now = clock.now();

    // TODO calculate percentage at first show, then save last shown time and ask based on frequency

    // TODO unclear: When do we save createdUser? At all? What if the user sign in/out?
    // Let's scrap this feature for now.
    // This would also for the wiredash to access the sharedPrefs even when it is not triggered.

    return true;
  }
}
