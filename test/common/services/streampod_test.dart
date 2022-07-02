import 'package:test/test.dart';
import 'package:wiredash/src/core/services/streampod.dart';

void main() {
  test('provider rebuild when dependencies change', () {
    final sl = Locator();
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
    final sl = Locator();
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

  test('multi level rebuild', () {
    final sl = Locator();
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
