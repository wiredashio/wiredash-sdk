/// Service locator
///
/// Like riverpod, services can depend on each other and get recreated when
/// their dependencies change.
class Locator {
  final Map<Type, InstanceFactory> _registry = {};

  void dispose() {
    for (final item in _registry.values) {
      item.dispose?.call();
    }
  }

  /// Retrieve a instance of type [T]
  T get<T>() {
    final provider = _registry[T];
    return provider!.instance as T;
  }

  InstanceFactory<T> injectProvider<T>(
    T Function(Locator) create, {
    T Function(Locator, T oldInstance)? update,
    Function(T)? dispose,
  }) {
    late InstanceFactory<T> provider;
    provider = InstanceFactory(this, create, update, () {
      final instance = provider._instance;
      if (instance != null && dispose != null) {
        dispose(instance);
      }
    });
    final existing = _registry[T];
    if (existing != null) {
      provider.dependencies = existing.dependencies.toList();
      print("swap $T");
      existing.dispose?.call();

      // invalidate existing dependency instances
      for (final dep in provider.dependencies) {
        dep._oldInstance = dep._instance;
        dep._instance = null;
        // create instance
        dep.instance;
      }
    }
    _registry[T] = provider;
    return provider;
  }
}

class InstanceFactory<T> {
  static int _id = 0;

  InstanceFactory(
    this.locator,
    this.create,
    this.update,
    this.dispose,
  );

  final T Function(Locator) create;
  final T Function(Locator, T oldInstance)? update;
  final Locator locator;

  final int id = _id++;
  T? _instance;
  T? _oldInstance;

  List<InstanceFactory> dependencies = [];

  final Function()? dispose;

  late final DependencyTracker _tracker = DependencyTracker(this);

  T get instance {
    if (_instance == null) {
      _tracker.create();
      late final T i;
      if (_oldInstance != null && update != null) {
        // ignore: null_check_on_nullable_type_parameter
        i = update!.call(locator, _oldInstance!);
      } else {
        i = create(locator);
      }
      _tracker.created();
      _instance = i;
    }
    return _instance!;
  }
}

class DependencyTracker {
  static int? _active;

  DependencyTracker(this.provider);

  final InstanceFactory provider;
  Locator get locator => provider.locator;

  int? _prevActive;

  void create() {
    _prevActive = _active;
    _active = provider.id;
    if (_prevActive != null) {
      final listener = locator._registry.values
          .firstWhere((element) => element.id == _prevActive);
      provider.dependencies.add(listener);
    }
  }

  void created() {
    _active = _prevActive;
  }
}
