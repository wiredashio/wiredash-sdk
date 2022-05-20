import 'package:flutter/widgets.dart';
import 'package:wiredash/src/_wiredash_internal.dart';

extension WiredashLocalizationsExt on BuildContext {
  /// Accesses the [WiredashLocalizations] via [BuildContext]
  WiredashLocalizations get l10n =>
      Localizations.of<WiredashLocalizations>(this, WiredashLocalizations)!;
}
