library _wiredash_interal;

import 'package:wiredash/src/metadata/user_meta_data.dart';

export 'package:wiredash/assets/l10n/wiredash_localizations.g.dart';
export 'package:wiredash/src/core/network/wiredash_api.dart';
export 'package:wiredash/src/core/services/error_report.dart';
export 'package:wiredash/src/core/services/services.dart';
export 'package:wiredash/src/core/wiredash_controller.dart';
export 'package:wiredash/src/core/wiredash_localizations_ext.dart';
export 'package:wiredash/src/core/wiredash_model.dart';
export 'package:wiredash/src/core/wiredash_model_provider.dart';
export 'package:wiredash/src/metadata/all_meta_data.dart';
export 'package:wiredash/src/metadata/build_info/app_info.dart';
export 'package:wiredash/src/metadata/build_info/build_info.dart';
export 'package:wiredash/src/metadata/build_info/uid_generator.dart';
export 'package:wiredash/src/metadata/device_info/device_info.dart';
export 'package:wiredash/src/metadata/device_info/device_info_generator.dart';
export 'package:wiredash/src/utils/object_util.dart';
export 'package:wiredash/src/utils/standard_kt.dart';

/// `true` when Wiredash is in development mode, enables enhanced logging
const bool kDevMode = false;

/// [WiredashMetaData] is used in the public API, [SessionMetaData] internally
/// to distinguish between [FixedMetaData] and [SessionMetaData]
typedef SessionMetaData = WiredashMetaData;
