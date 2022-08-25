import 'package:flutter/widgets.dart';
import 'package:wiredash/src/promoterscore/ps_model.dart';

class PsModelProvider extends InheritedNotifier<PsModel> {
  const PsModelProvider({
    Key? key,
    required PsModel psModel,
    required Widget child,
  }) : super(key: key, notifier: psModel, child: child);

  static PsModel of(BuildContext context, {bool listen = true}) {
    if (listen) {
      return context
          .dependOnInheritedWidgetOfExactType<PsModelProvider>()!
          .notifier!;
    } else {
      return context
          .findAncestorWidgetOfExactType<PsModelProvider>()!
          .notifier!;
    }
  }
}

extension PsModelExtension on BuildContext {
  PsModel get psModel => PsModelProvider.of(this);
}
