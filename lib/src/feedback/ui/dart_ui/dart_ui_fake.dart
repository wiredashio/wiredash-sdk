// ignore_for_file: camel_case_types

class platformViewRegistry {
  const platformViewRegistry._();

  /// Shim for registerViewFactory
  /// https://github.com/flutter/engine/blob/master/lib/web_ui/lib/ui.dart#L72
  static void registerViewFactory(
    String viewTypeId,
    dynamic Function(int viewId) viewFactory,
  ) {}

  static Object getViewById(int viewId) {
    throw UnimplementedError();
  }
}
