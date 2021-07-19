class AppInfo {
  final bool appIsDebug;
  final String appLocale;

  const AppInfo({
    required this.appIsDebug,
    required this.appLocale,
  });

  @override
  String toString() {
    return 'AppInfo{'
        'appIsDebug: $appIsDebug, '
        'appLocale: $appLocale, '
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppInfo &&
          runtimeType == other.runtimeType &&
          appIsDebug == other.appIsDebug &&
          appLocale == other.appLocale;

  @override
  int get hashCode => appIsDebug.hashCode ^ appLocale.hashCode;
}
