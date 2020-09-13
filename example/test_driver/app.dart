import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:wiredash/wiredash.dart';

void main() {
  final navigatorKey = GlobalKey<NavigatorState>();
  final currentLocale = ValueNotifier<Locale>(null);

  bool hasErrors = false;
  FlutterError.onError = (details) {
    hasErrors = true;
  };

  enableFlutterDriverExtension(
    handler: (message) async {
      if (message.startsWith('changeLocale:')) {
        final locale = message.split('changeLocale:').last;
        currentLocale.value = null;
        hasErrors = false;
        await Future.delayed(const Duration(milliseconds: 200));
        currentLocale.value = WiredashLocalizations.supportedLocales
            .singleWhere((l) => l.languageCode == locale);
        return null;
      }

      switch (message) {
        case 'getSupportedLocales':
          return WiredashLocalizations.supportedLocales
              .map((l) => l.languageCode)
              .join(',');
        case 'getLastError':
          if (hasErrors) {
            hasErrors = false;
            return '';
          }
          return null;
        default:
          throw ArgumentError.value(
            message,
            'message',
            'Unknown value for message.',
          );
      }
    },
  );

  runApp(
    ValueListenableBuilder<Locale>(
      valueListenable: currentLocale,
      builder: (context, locale, child) {
        if (locale == null) return const SizedBox();
        return Wiredash(
          projectId: '',
          secret: '',
          navigatorKey: navigatorKey,
          options: WiredashOptionsData(locale: locale),
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: Container(
              color: Colors.white,
              child: Center(
                child: Builder(
                  builder: (context) {
                    return RaisedButton(
                      key: const ValueKey(
                        'wiredash.example.show_wiredash_button',
                      ),
                      onPressed: () => Wiredash.of(context).show(),
                      child: Text('Show Wiredash'),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
