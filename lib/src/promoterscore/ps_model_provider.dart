import 'package:flutter/widgets.dart';
import 'package:wiredash/src/promoterscore/ps_model.dart';

class PsModelProvider extends InheritedNotifier<PsModel> {
  const PsModelProvider({
    super.key,
    required PsModel psModel,
    required super.child,
  }) : super(notifier: psModel);

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
