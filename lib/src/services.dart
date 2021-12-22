import 'dart:ui';

import 'package:file/local.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/common/build_info/build_info_manager.dart';
import 'package:wiredash/src/common/build_info/device_id_generator.dart';
import 'package:wiredash/src/common/device_info/device_info_generator.dart';
import 'package:wiredash/src/common/network/wiredash_api.dart';
import 'package:wiredash/src/common/widgets/screencapture.dart';
import 'package:wiredash/src/feedback/backdrop/wiredash_backdrop.dart';
import 'package:wiredash/src/feedback/data/direct_feedback_submitter.dart';
import 'package:wiredash/src/feedback/data/feedback_submitter.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item_storage.dart';
import 'package:wiredash/src/feedback/data/retrying_feedback_submitter.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';
import 'package:wiredash/src/feedback/picasso/picasso.dart';
import 'package:wiredash/src/feedback/wiredash_model.dart';
import 'package:wiredash/wiredash.dart';

/// Internal service locator
class WiredashServices extends ChangeNotifier {
  WiredashServices() {
    _locator.inject<WiredashServices>((_) => this);

    _locator.inject<DeviceIdGenerator>((_) => DeviceIdGenerator());
    _locator.inject<BuildInfoManager>((_) => BuildInfoManager());
    _locator.inject<BackdropController>(
      (_) => BackdropController(),
      dispose: (model) => model.dispose(),
    );
    _locator.inject<PicassoController>(
      (_) => PicassoController(),
      dispose: (model) => model.dispose(),
    );
    _locator.inject<DeviceInfoGenerator>((_) => DeviceInfoGenerator(window));
    _locator.inject<WiredashOptionsData>(
      (locator) => wiredashWidget.options ?? const WiredashOptionsData(),
    );
    _locator.inject<ScreenCaptureController>(
      (locator) => ScreenCaptureController(),
      dispose: (model) => model.dispose(),
    );

    _locator.inject<WiredashModel>(
      (locator) => WiredashModel(this),
      dispose: (model) => model.dispose(),
    );

    _locator.inject<FeedbackModel>(
      (locator) => FeedbackModel(this),
      dispose: (model) => model.dispose(),
    );

    _locator.inject<WiredashApi>(
      (locator) {
        return WiredashApi(
          httpClient: Client(),
          projectId: wiredashWidget.projectId,
          secret: wiredashWidget.secret,
          deviceIdProvider: deviceIdGenerator.deviceId,
        );
      },
    );

    _locator.inject<FeedbackSubmitter>(
      (locator) {
        if (kIsWeb) {
          return DirectFeedbackSubmitter(api);
        }

        const fileSystem = LocalFileSystem();
        final storage = PendingFeedbackItemStorage(
          fileSystem,
          SharedPreferences.getInstance,
          () async => (await getApplicationDocumentsDirectory()).path,
        );
        final retryingFeedbackSubmitter =
            RetryingFeedbackSubmitter(fileSystem, storage, api);
        retryingFeedbackSubmitter.submitPendingFeedbackItems();
        return retryingFeedbackSubmitter;
      },
    );
  }

  final Locator _locator = Locator();

  @override
  void dispose() {
    _locator.dispose();
    super.dispose();
  }

  WiredashModel get wiredashModel => _locator.get();
  FeedbackModel get feedbackModel => _locator.get();
  BackdropController get backdropController => _locator.get();
  DeviceInfoGenerator get deviceInfoGenerator => _locator.get();
  PicassoController get picassoController => _locator.get();
  ScreenCaptureController get screenCaptureController => _locator.get();
  BuildInfoManager get buildInfoManager => _locator.get();
  FeedbackSubmitter get feedbackSubmitter => _locator.get();
  DeviceIdGenerator get deviceIdGenerator => _locator.get();
  Wiredash get wiredashWidget => _locator.get();
  WiredashOptionsData get wiredashOptions => _locator.get();
  WiredashApi get api => _locator.get();

  void updateWidget(Wiredash wiredashWidget) {
    _locator.inject<Wiredash>((_) => wiredashWidget);
    notifyListeners();
  }

  // TODO move somewhere else
  /// discards the current feedback and starts over
  void discardFeedback() {
    final old = feedbackModel;
    _locator.inject<FeedbackModel>((locator) => FeedbackModel(this));
    notifyListeners();
    // dispose old one after next frame. disposing it earlier would prevent the
    // FeedbackModelProvider from correctly remove the listeners
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      old.dispose();
    });
  }
}

class Locator {
  final Map<Type, _Provider> _registry = {};

  void dispose() {
    for (final item in _registry.values) {
      item.dispose?.call();
    }
  }

  T get<T>() {
    final provider = _registry[T];
    return provider!.instance as T;
  }

  _Provider<T> inject<T>(
    T Function(Locator) create, {
    Function(T)? dispose,
  }) {
    late _Provider<T> provider;
    provider = _Provider(this, create, () {
      final instance = provider._instance;
      if (instance != null && dispose != null) {
        dispose(instance);
      }
    });
    final existing = _registry[T];
    if (existing != null) {
      print("$existing changed, rebuilding dependencies:");
      print(existing.dependencies);
      provider.dependencies = existing.dependencies;
    }
    _registry[T] = provider;
    return provider;
  }
}

class _Provider<T> {
  static int _id = 0;

  _Provider(this.locator, this.create, this.dispose) {
    // locator.registry[id] = this;
  }

  final T Function(Locator) create;
  final Locator locator;

  final int id = _id++;
  T? _instance;

  List<_Provider> dependencies = [];

  final Function()? dispose;

  late final DependencyTracker _tracker = DependencyTracker(this);

  T get instance {
    if (_instance == null) {
      _tracker.create();
      final i = create(locator);
      _tracker.created();
      _instance = i;
    }
    return _instance!;
  }
}

class DependencyTracker {
  static int? _active;

  DependencyTracker(this.provider);

  final _Provider provider;
  Locator get locator => provider.locator;

  int? _prevActive;

  void create() {
    _prevActive = _active;
    print("> create $provider");
    _active = provider.id;
    if (_prevActive != null) {
      final listener = locator._registry.values
          .firstWhere((element) => element.id == _prevActive);
      provider.dependencies.add(listener);
    }
  }

  void created() {
    _active = _prevActive;
    print("< created $provider");
  }
}
