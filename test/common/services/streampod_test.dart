import 'dart:async';

import 'package:test/test.dart';
import 'package:wiredash/src/core/services/streampod.dart';
import 'package:wiredash/src/utils/changenotifier2.dart';
import 'package:wiredash/src/utils/disposable.dart';

void main() {
  test('provider rebuild when dependencies change', () {
    final sl = InjectableLocator();
    final apiKeyAProvider = sl.injectProvider<_ApiKey>((_) => _ApiKey('a'));
    final apiProvider =
        sl.injectProvider<_Api>((locator) => _Api(locator.watch()));
    expect(sl.watch<_Api>().key.value, 'a');
    expect(apiProvider.dependencies, [apiKeyAProvider]);
    expect(apiKeyAProvider.consumers, [apiProvider]);

    final apiKeyBProvider = sl.injectProvider<_ApiKey>((_) => _ApiKey('b'));
    expect(sl.watch<_Api>().key.value, 'b');
    expect(apiProvider.dependencies, [apiKeyBProvider]);
    expect(apiKeyAProvider.consumers, []);
    expect(apiKeyBProvider.consumers, [apiProvider]);
  });

  test('provider update when dependencies change', () {
    final sl = InjectableLocator();
    final apiKeyAProvider = sl.injectProvider<_ApiKey>((_) => _ApiKey('a'));
    final listenerValues = [];
    final apiProvider = sl.injectProvider<_Api>(
      (locator) {
        final api = _Api(_ApiKey('x'));

        sl.listen<_ApiKey>((key) {
          listenerValues.add(key.value);
          api.key = key;
        });

        return api;
      },
    );
    final aApi = sl.watch<_Api>();
    expect(aApi.key.value, 'a');
    expect(apiProvider.dependencies, []);
    expect(apiKeyAProvider.consumers, []);
    expect(apiKeyAProvider.listeners.length, 1);
    expect(listenerValues, ['a']);

    final apiKeyBProvider = sl.injectProvider<_ApiKey>((_) => _ApiKey('b'));

    final bApi = sl.watch<_Api>();
    expect(bApi.key.value, 'b');
    expect(apiProvider.dependencies, []);
    expect(apiKeyAProvider.consumers, []);
    expect(apiKeyBProvider.consumers, []);
    expect(apiKeyAProvider.listeners.length, 0);
    expect(apiKeyBProvider.listeners.length, 1);
    expect(listenerValues, ['a', 'b']);

    // same instance, because update was used
    expect(bApi, same(aApi));
  });

  test('multi level rebuild - watch', () {
    final sl = InjectableLocator();
    final keyProviderA = sl.injectProvider<_ApiKey>((_) => _ApiKey('a'));
    final apiProvider =
        sl.injectProvider<_Api>((locator) => _Api(locator.watch()));
    final repoProvider = sl.injectProvider<_Repo>((locator) {
      return _Repo(locator.watch());
    });
    expect(sl.watch<_Repo>().apiKey, 'a');
    expect(repoProvider.dependencies, [apiProvider]);
    expect(repoProvider.consumers, []);
    expect(apiProvider.dependencies, [keyProviderA]);
    expect(apiProvider.consumers, [repoProvider]);
    expect(keyProviderA.dependencies, []);
    expect(keyProviderA.consumers, [apiProvider]);

    final keyProviderB = sl.injectProvider<_ApiKey>((_) => _ApiKey('b'));
    expect(sl.watch<_Repo>().apiKey, 'b');
    expect(repoProvider.dependencies, [apiProvider]);
    expect(repoProvider.consumers, []);
    expect(apiProvider.dependencies, [keyProviderB]);
    expect(apiProvider.consumers, [repoProvider]);
    expect(keyProviderB.dependencies, []);
    expect(keyProviderB.consumers, [apiProvider]);

    // the old one was disposed
    expect(keyProviderA.dependencies, []);
    expect(keyProviderA.consumers, []);
  });

  test('multi level rebuild - read', () {
    final sl = InjectableLocator();
    final keyProviderA = sl.injectProvider<_ApiKey>((_) => _ApiKey('a'));
    final apiProvider =
        sl.injectProvider<_Api>((locator) => _Api(locator.watch()));
    final repoProvider = sl.injectProvider<_Repo>((locator) {
      return _Repo(locator.watch());
    });
    expect(sl.watch<_Repo>().apiKey, 'a');
    expect(repoProvider.dependencies, [apiProvider]);
    expect(repoProvider.consumers, []);
    expect(apiProvider.dependencies, [keyProviderA]);
    expect(apiProvider.consumers, [repoProvider]);
    expect(keyProviderA.dependencies, []);
    expect(keyProviderA.consumers, [apiProvider]);

    final keyProviderB = sl.injectProvider<_ApiKey>((_) => _ApiKey('b'));
    expect(sl.get<_Repo>().apiKey, 'b');
    expect(repoProvider.dependencies, [apiProvider]);
    expect(repoProvider.consumers, []);
    expect(apiProvider.dependencies, [keyProviderB]);
    expect(apiProvider.consumers, [repoProvider]);
    expect(keyProviderB.dependencies, []);
    expect(keyProviderB.consumers, [apiProvider]);

    // the old one was disposed
    expect(keyProviderA.dependencies, []);
    expect(keyProviderA.consumers, []);
  });

  test('auto-dispose', () {
    final sl = InjectableLocator();
    // ChangeNotifier
    sl.injectProvider<ChangeNotifier2>((_) => ChangeNotifier2());
    final cn = sl.get<ChangeNotifier2>();

    // dynamic close()
    sl.injectProvider<StreamController<int>>((p0) => StreamController());
    final streamController = sl.get<StreamController<int>>();

    // dynamic dispose()
    sl.injectProvider<Disposable>((_) => Disposable(() {}));
    final disposable = sl.get<Disposable>();

    // dynamic cancel()
    sl.injectProvider<Timer>((_) => Timer(const Duration(days: 1), () {}));
    final timer = sl.get<Timer>();
    sl.dispose();

    expect(cn.isDisposed, isTrue);
    expect(streamController.isClosed, isTrue);
    expect(disposable.isDisposed, isTrue);
    expect(timer.isActive, isFalse);
  });
}

class _ApiKey {
  _ApiKey(this.value);

  final String value;
}

class _Api {
  _ApiKey key;

  _Api(this.key);
}

class _Repo {
  final _Api api;

  _Repo(this.api);

  String get apiKey => api.key.value;
}
