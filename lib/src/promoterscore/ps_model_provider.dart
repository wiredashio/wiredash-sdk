import 'package:flutter/widgets.dart';
import 'package:wiredash/src/promoterscore/ps_model.dart';

class PsModelProvider extends InheritedNotifier<PsModel> {
  const PsModelProvider({
    super.key,
    required PsModel psModel,
    required super.child,
  }) : super(notifier: psModel);
}

extension PsModelExtension on BuildContext {
  PsModel get watchPsModel =>
      dependOnInheritedWidgetOfExactType<PsModelProvider>()!.notifier!;
  PsModel get readPsModel =>
      findAncestorWidgetOfExactType<PsModelProvider>()!.notifier!;
}
