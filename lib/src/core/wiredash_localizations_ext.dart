import 'package:flutter/widgets.dart';
import 'package:wiredash/assets/l10n/wiredash_localizations_en.g.dart';
import 'package:wiredash/src/_wiredash_internal.dart';

extension WiredashLocalizationsExt on BuildContext {
  /// Accesses the [WiredashLocalizations] via [BuildContext]
  WiredashLocalizations get l10n {
    final localizationsFromContext =
        Localizations.of<WiredashLocalizations>(this, WiredashLocalizations);

    if (localizationsFromContext == null) {
      // The Localizations widget registers Localizations asynchronously (https://github.com/flutter/flutter/blob/74aef9ff8786951fe0c4bd4c96dcb7b80caec219/packages/flutter/lib/src/widgets/localizations.dart#L550-L558)
      // Usually, they are available at the very next frame, but it might take
      // a few more on some devices. Fallback to en_US until the localizations
      // in the right locale are loaded
      return WiredashLocalizationsEn();
    }

    return localizationsFromContext;
  }
}
