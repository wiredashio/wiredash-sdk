import 'dart:ui';

import 'package:file/local.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/_ps.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/analytics/analytics.dart';
import 'package:wiredash/src/core/project_credential_validator.dart';
import 'package:wiredash/src/core/services/streampod.dart';
import 'package:wiredash/src/core/sync/app_telemetry_job.dart';
import 'package:wiredash/src/core/sync/event_upload_job.dart';
import 'package:wiredash/src/core/sync/ping_job.dart';
import 'package:wiredash/src/core/sync/sync_engine.dart';
import 'package:wiredash/src/core/sync/sync_feedback_job.dart';
import 'package:wiredash/src/core/telemetry/app_telemetry.dart';
import 'package:wiredash/src/core/telemetry/wiredash_telemetry.dart';
import 'package:wiredash/src/core/widgets/backdrop/wiredash_backdrop.dart';
import 'package:wiredash/src/feedback/data/direct_feedback_submitter.dart';
import 'package:wiredash/src/feedback/data/feedback_submitter.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item_storage.dart';
import 'package:wiredash/src/feedback/data/retrying_feedback_submitter.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';
import 'package:wiredash/src/feedback/picasso/picasso.dart';
import 'package:wiredash/src/feedback/ui/screencapture.dart';
import 'package:wiredash/src/metadata/meta_data_collector.dart';
import 'package:wiredash/src/utils/test_detector.dart';
import 'package:wiredash/wiredash.dart';

/// Internal service locator
class WiredashServices extends ChangeNotifier {
  factory WiredashServices() {
    WiredashServices? services;
    assert(
      () {
        if (debugServicesCreator != null) {
          services = debugServicesCreator!.call();
        }
        return true;
      }(),
    );

    return services ?? WiredashServices.setup(registerProdWiredashServices);
  }

  WiredashServices.setup(
    void Function(WiredashServices sl) setup,
  ) {
    setup(this);
  }

  /// Can be used to inject mock services for testing
  @visibleForTesting
  static WiredashServices Function()? debugServicesCreator;

  Locator get locator => _locator;

  final InjectableLocator _locator = InjectableLocator();

  WiredashModel get wiredashModel => _locator.watch();

  FeedbackModel get feedbackModel => _locator.watch();

  PsModel get psModel => _locator.watch();

  BackdropController get backdropController => _locator.watch();

  FlutterInfoCollector get flutterInfoCollector => _locator.watch();

  PicassoController get picassoController => _locator.watch();

  ScreenCaptureController get screenCaptureController => _locator.watch();

  FeedbackSubmitter get feedbackSubmitter => _locator.watch();

  WuidGenerator get wuidGenerator => _locator.watch();

  Wiredash get wiredashWidget => _locator.watch();

  WiredashOptionsData get wiredashOptions => _locator.watch();

  WiredashApi get api => _locator.watch();

  SyncEngine get syncEngine => _locator.watch();

  DiscardFeedbackUseCase get discardFeedback => _locator.watch();

  DiscardPsUseCase get discardPs => _locator.watch();

  ProjectCredentialValidator get projectCredentialValidator => _locator.watch();

  PsTrigger get psTrigger => _locator.watch();

  WiredashTelemetry get wiredashTelemetry => _locator.watch();

  AppTelemetry get appTelemetry => _locator.watch();

  MetaDataCollector get metaDataCollector => _locator.watch();

  TestDetector get testDetector => _locator.watch();

  EventSubmitter get eventSubmitter => _locator.watch();

  Future<SharedPreferences> Function() get sharedPreferencesProvider =>
      _locator.watch();

  void updateWidget(Wiredash wiredashWidget) {
    inject<Wiredash>((_) => wiredashWidget);
  }

  @override
  void dispose() {
    _locator.dispose();
    super.dispose();
  }

  InstanceFactory<T> inject<T>(
    T Function(Locator) create, {
    Function(T)? dispose,
  }) {
    final factory = _locator.injectProvider(
      (locator) => create(_locator),
      dispose: dispose,
    );
    notifyListeners();
    return factory;
  }
}

void registerProdWiredashServices(WiredashServices sl) {
  sl.inject<WiredashServices>((_) => sl);

  sl.inject<Future<SharedPreferences> Function()>(
    (_) => SharedPreferences.getInstance,
  );

  sl.inject<Wiredash>(
    (_) => const Wiredash(
      projectId: '',
      secret: '',
      child: SizedBox(),
    ),
  );
  sl.inject<WuidGenerator>(
    (_) => SharedPrefsWuidGenerator(
      sharedPrefsProvider: sl.sharedPreferencesProvider,
    ),
  );
  sl.inject<ProjectCredentialValidator>(
    (_) => const ProjectCredentialValidator(),
  );
  sl.inject<AppTelemetry>(
    (_) => PersistentAppTelemetry(sl.sharedPreferencesProvider),
  );
  sl.inject<WiredashTelemetry>(
    (_) => PersistentWiredashTelemetry(sl.sharedPreferencesProvider),
  );
  sl.inject<PsTrigger>((_) {
    return PsTrigger(
      wuidGenerator: sl.wuidGenerator,
      appTelemetry: sl.appTelemetry,
      wiredashTelemetry: sl.wiredashTelemetry,
    );
  });
  sl.inject<EventSubmitter>((_) {
    return PendingEventSubmitter(
      api: sl.api,
      sharedPreferences: sl.sharedPreferencesProvider,
      projectId: () => sl.wiredashWidget.projectId,
    );
  });

  sl.inject<BackdropController>(
    (_) => BackdropController(),
    dispose: (model) => model.dispose(),
  );
  sl.inject<PicassoController>(
    (locator) {
      final controller = PicassoController();
      locator.listen<Wiredash>((wiredashWidget) {
        controller.color ??= wiredashWidget.theme?.firstPenColor;
      });

      return controller;
    },
    dispose: (model) => model.dispose(),
  );
  // Replace with FlutterView when we drop support for Flutter v3.7.0-32.0.pre.
  // ignore: deprecated_member_use
  sl.inject<FlutterInfoCollector>((_) => FlutterInfoCollector(window));
  sl.inject<BuildInfo>((_) => getBuildInformation());
  sl.inject<WiredashOptionsData>(
    (_) => sl.wiredashWidget.options ?? const WiredashOptionsData(),
  );
  sl.inject<ScreenCaptureController>(
    (locator) => ScreenCaptureController(),
    dispose: (model) => model.dispose(),
  );

  sl.inject<WiredashModel>(
    (locator) => WiredashModel(sl),
    dispose: (model) => model.dispose(),
  );

  sl.inject<FeedbackModel>(
    (locator) => FeedbackModel(sl),
    dispose: (model) => model.dispose(),
  );

  sl.inject<PsModel>(
    (locator) => PsModel(sl),
    dispose: (model) => model.dispose(),
  );

  sl.inject<WiredashApi>(
    (locator) {
      return WiredashApi(
        httpClient: Client(),
        projectId: sl.wiredashWidget.projectId,
        secret: sl.wiredashWidget.secret,
      );
    },
  );

  sl.inject<FeedbackSubmitter>(
    (locator) {
      if (kIsWeb) {
        return DirectFeedbackSubmitter(sl.api);
      }

      const fileSystem = LocalFileSystem();
      final storage = PendingFeedbackItemStorage(
        fileSystem: fileSystem,
        sharedPreferencesProvider: sl.sharedPreferencesProvider,
        dirPathProvider: () async =>
            (await getApplicationDocumentsDirectory()).path,
        wuidGenerator: sl.wuidGenerator,
      );
      final retryingFeedbackSubmitter =
          RetryingFeedbackSubmitter(fileSystem, storage, sl.api);
      return retryingFeedbackSubmitter;
    },
  );

  sl.inject<MetaDataCollector>((sl) {
    return MetaDataCollector(
      deviceInfoCollector: sl.get,
      buildInfoProvider: sl.get,
    );
  });

  sl.inject<SyncEngine>(
    (locator) {
      final engine = SyncEngine();

      // app start
      engine.addJob(
        'app-telemetry',
        AppTelemetryJob(
          telemetry: locator.get(),
        ),
      );

      // app start delayed
      engine.addJob(
        'ping',
        PingJob(
          apiProvider: () => sl.api,
          wuidGenerator: () => sl.wuidGenerator,
          metaDataCollector: () => sl.metaDataCollector,
          sharedPreferencesProvider: sl.sharedPreferencesProvider,
        ),
      );
      engine.addJob(
        'feedback',
        UploadPendingFeedbackJob(
          feedbackSubmitterProvider: locator.get,
        ),
      );

      final job = EventUploadJob(
        sharedPreferencesProvider: sl.sharedPreferencesProvider,
        eventSubmitter: () => sl.eventSubmitter,
      );
      engine.addJob('upload_events', job);

      return engine;
    },
    dispose: (engine) => engine.onWiredashDispose(),
  );

  sl.inject<DiscardFeedbackUseCase>((_) => DiscardFeedbackUseCase(sl));
  sl.inject<DiscardPsUseCase>((_) => DiscardPsUseCase(sl));
  sl.inject<TestDetector>((_) => TestDetector());
}

/// Discards the current feedback
class DiscardFeedbackUseCase {
  DiscardFeedbackUseCase(this.services);

  final WiredashServices services;

  void call() {
    services.inject<FeedbackModel>(
      (locator) => FeedbackModel(services),
      dispose: (model) => model.dispose(),
    );
  }
}

/// Discards the current promoter score by recreating the [PsModel]
class DiscardPsUseCase {
  DiscardPsUseCase(this.services);

  final WiredashServices services;

  void call() {
    services.inject<PsModel>(
      (locator) => PsModel(services),
      dispose: (model) => model.dispose(),
    );
  }
}
