import 'package:test/test.dart';
import 'package:wiredash/src/core/services/streampod.dart';

void main() {
  test('provider rebuild when dependencies change', () {
    final sl = Locator();
    final apiKeyAProvider = sl.injectProvider<_ApiKey>((_) => _ApiKey('a'));
    final apiProvider =
        sl.injectProvider<_Api>((locator) => _Api(locator.get()));
    expect(sl.get<_Api>().key.value, 'a');
    expect(apiProvider.dependencies, [apiKeyAProvider]);
    expect(apiKeyAProvider.listeners, [apiProvider]);

    final apiKeyBProvider = sl.injectProvider<_ApiKey>((_) => _ApiKey('b'));
    expect(sl.get<_Api>().key.value, 'b');
    expect(apiProvider.dependencies, [apiKeyBProvider]);
    expect(apiKeyAProvider.listeners, []);
    expect(apiKeyBProvider.listeners, [apiProvider]);
  });

  test('multi level rebuild', () {
    final sl = Locator();
    final keyProviderA = sl.injectProvider<_ApiKey>((_) => _ApiKey('a'));
    final apiProvider =
        sl.injectProvider<_Api>((locator) => _Api(locator.get()));
    final repoProvider = sl.injectProvider<_Repo>((locator) {
      return _Repo(locator.get());
    });
    expect(sl.get<_Repo>().apiKey, 'a');
    expect(repoProvider.dependencies, [apiProvider]);
    expect(repoProvider.listeners, []);
    expect(apiProvider.dependencies, [keyProviderA]);
    expect(apiProvider.listeners, [repoProvider]);
    expect(keyProviderA.dependencies, []);
    expect(keyProviderA.listeners, [apiProvider]);

    final keyProviderB = sl.injectProvider<_ApiKey>((_) => _ApiKey('b'));
    expect(sl.get<_Repo>().apiKey, 'b');
    expect(repoProvider.dependencies, [apiProvider]);
    expect(repoProvider.listeners, []);
    expect(apiProvider.dependencies, [keyProviderB]);
    expect(apiProvider.listeners, [repoProvider]);
    expect(keyProviderB.dependencies, []);
    expect(keyProviderB.listeners, [apiProvider]);

    // the old one was disposed
    expect(keyProviderA.dependencies, []);
    expect(keyProviderA.listeners, []);
  });
}

class _ApiKey {
  _ApiKey(this.value);

  final String value;
}

class _Api {
  final _ApiKey key;

  _Api(this.key);
}

class _Repo {
  final _Api api;

  _Repo(this.api);

  String get apiKey => api.key.value;
}
