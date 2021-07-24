/// Information about the user app
class AppInfo {
  final String appLocale;

  const AppInfo({
    required this.appLocale,
  });

  @override
  String toString() {
    return 'AppInfo{'
        'appLocale: $appLocale, '
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppInfo &&
          runtimeType == other.runtimeType &&
          appLocale == other.appLocale;

  @override
  int get hashCode => appLocale.hashCode;
}
