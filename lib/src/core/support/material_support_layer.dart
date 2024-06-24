// ignore_for_file: join_return_with_assignment

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wiredash/src/core/theme/wiredash_theme.dart';
import 'package:wiredash/src/utils/semver.dart';

/// Provides parent Widgets that are required by material widgets that are
/// not wrapped into an [MaterialApp]
class MaterialSupportLayer extends StatefulWidget {
  const MaterialSupportLayer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<MaterialSupportLayer> createState() => _MaterialSupportLayerState();
}

class _MaterialSupportLayerState extends State<MaterialSupportLayer> {
  OverlayEntry? _entry;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && Platform.isMacOS) {
      // We can't check the flutter version, instead we check the version
      // of the embedded dart sdk. Good enough
      final dartVersion = _parseDartVersion(Platform.version);
      if (dartVersion != null) {
        if (dartVersion <= _removalOfDefaultTextEditingShortcuts) {
          debugPrint(_missingDefaultTextEditingShortcuts);
        }
      }
    }
  }

  @override
  void didUpdateWidget(covariant MaterialSupportLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Rebuild wrapped widget tree when something changes
    // This fixes Hot-Reload
    _entry?.markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) {
    //Overlay is required for text edit functions such as copy/paste on mobile
    _entry = OverlayEntry(
      builder: (context) {
        // use a stateful widget as direct child or hot reload will not
        // work for that widget
        return widget.child;
      },
    );

    Widget child = Overlay(initialEntries: [_entry!]);

    // Localizations required for Flutter UI widgets.
    // I.e. copy/paste dialogs for TextFields
    child = Localizations.override(
      context: context,
      delegates: [
        ...GlobalMaterialLocalizations.delegates,
        // fallback to english for unsupported locales
        _EnglishFallbackMatieralLocalizationsDelegate(),
        _EnglishFallbackCupertinoLocalizationsDelegate(),
        _EnglishFallbackWidgetLocalizationsDelegate(),
      ],
      child: child,
    );

    final wiredashTheme = context.theme;
    final materialTheme = wiredashTheme.brightness == Brightness.dark
        ? ThemeData.dark()
        : ThemeData.light();
    child = Theme(
      data: materialTheme,
      child: child,
    );

    // Make Wiredash a Material widget to support TextFields, etc.
    child = Material(
      textStyle: DefaultTextStyle.of(context).style,
      color: Colors.transparent,
      child: child,
    );

    // allow text editing (i.e. select all, delete on macos)
    child = DefaultTextEditingShortcuts(
      child: child,
    );

    return child;
  }
}

/// Parses the dart version of the [Platform.version] String
///
/// The version string looks like this:
/// 2.16.0-80.1.beta (beta) (Mon Dec 13 11:59:02 2021 +0100) on "macos_x64"
Version? _parseDartVersion(String versionString) {
  // the first space separates the version from more meta information
  final versionPart = versionString.split(' ').first;
  try {
    return Version.parse(versionPart);
  } catch (_) {
    return null;
  }
}

/// Dart 2.16.0-80.1.beta matches Flutter 2.9.0-0.1.pre where keyboard actions
/// are working without the removed DefaultTextEditingShortcuts widget
final _removalOfDefaultTextEditingShortcuts =
    Version(2, 16, 0, preRelease: ['80', '1', 'beta']);

/// Error when using Flutter below [_removalOfDefaultTextEditingShortcuts]
const String _missingDefaultTextEditingShortcuts = '''
WARNING: Wiredash is partially incompatible with your Flutter version on macOS.
===========================================================
Text editing, like backspace aren't supported with your Flutter (old) version.
This bug is limited to macOS and caused by major refactoring of Actions for 
desktop in the Flutter SDK. Mobile platforms aren't affected.
For details check https://github.com/flutter/flutter/pull/90684

If you're seeing this message, upgrade your Flutter SDK to 2.9.0-0.0.pre 
(with Dart 2.16.0-80.1.beta) or newer.

You can ignore this message when you use macOS for development only.
===========================================================
''';

/// For unsupported locales, it returns english
class _EnglishFallbackMatieralLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    return GlobalMaterialLocalizations.delegate.load(const Locale('en'));
  }

  @override
  bool shouldReload(_) => false;

  @override
  String toString() {
    return '_EnglishFallbackMatieralLocalizationsDelegate{}';
  }
}

class _EnglishFallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return GlobalCupertinoLocalizations.delegate.load(const Locale('en'));
  }

  @override
  bool shouldReload(_) => false;

  @override
  String toString() {
    return '_EnglishFallbackCupertinoLocalizationsDelegate{}';
  }
}

class _EnglishFallbackWidgetLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<WidgetsLocalizations> load(Locale locale) {
    return GlobalWidgetsLocalizations.delegate.load(const Locale('en'));
  }

  @override
  bool shouldReload(_) => false;

  @override
  String toString() {
    return '_EnglishFallbackWidgetLocalizationsDelegate{}';
  }
}
