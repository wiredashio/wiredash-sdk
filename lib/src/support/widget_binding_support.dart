import 'package:flutter/cupertino.dart';

/// Returns a non-null instance of [WidgetsBinding] on all Flutter versions
///
/// Flutter versions 2.11 and earlier returned a nullable [WidgetsBinding] when
/// getting calling [WidgetsBinding.instance]. This getter prevents warnings
/// for Wiredash users on newer Flutter versions while maintaining compatibility
/// with the old API.
WidgetsBinding get widgetsBindingInstance {
  // ignore: unnecessary_cast
  final WidgetsBinding? wb = WidgetsBinding.instance as WidgetsBinding?;
  if (wb == null) {
    throw 'Binding has not yet been initialized.';
  }
  return wb;
}
