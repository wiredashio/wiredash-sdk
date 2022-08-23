import 'dart:ui';

import 'package:file/local.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/_nps.dart';
import 'package:wiredash/src/core/network/wiredash_api.dart';
import 'package:wiredash/src/core/project_credential_validator.dart';
import 'package:wiredash/src/core/services/streampod.dart';
import 'package:wiredash/src/core/sync/app_telemetry_job.dart';
import 'package:wiredash/src/core/sync/ping_job.dart';
import 'package:wiredash/src/core/sync/sync_engine.dart';
import 'package:wiredash/src/core/sync/sync_feedback_job.dart';
import 'package:wiredash/src/core/telemetry/app_telemetry.dart';
import 'package:wiredash/src/core/telemetry/wiredash_telemetry.dart';
import 'package:wiredash/src/core/widgets/backdrop/wiredash_backdrop.dart';
import 'package:wiredash/src/core/wiredash_model.dart';
import 'package:wiredash/src/feedback/data/direct_feedback_submitter.dart';
import 'package:wiredash/src/feedback/data/feedback_submitter.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item_storage.dart';
import 'package:wiredash/src/feedback/data/retrying_feedback_submitter.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';
import 'package:wiredash/src/feedback/picasso/picasso.dart';
import 'package:wiredash/src/feedback/ui/screencapture.dart';
import 'package:wiredash/src/metadata/build_info/device_id_generator.dart';
import 'package:wiredash/src/metadata/device_info/device_info_generator.dart';
import 'package:wiredash/src/nps/nps_trigger.dart';
import 'package:wiredash/src/utils/uuid.dart';
import 'package:wiredash/wiredash.dart';

/// Internal service locator
class WiredashServices extends ChangeNotifier {
  WiredashServices() {
    _setupServices(this);
  }

  final Locator _locator = Locator();

  WiredashModel get wiredashModel => _locator.watch();

  FeedbackModel get feedbackModel => _locator.watch();

  NpsModel get npsModel => _locator.watch();

  BackdropController get backdropController => _locator.watch();

  DeviceInfoGenerator get deviceInfoGenerator => _locator.watch();

  PicassoController get picassoController => _locator.watch();

  ScreenCaptureController get screenCaptureController => _locator.watch();

  FeedbackSubmitter get feedbackSubmitter => _locator.watch();

  DeviceIdGenerator get deviceIdGenerator => _locator.watch();

  Wiredash get wiredashWidget => _locator.watch();

  WiredashOptionsData get wiredashOptions => _locator.watch();

  WiredashApi get api => _locator.watch();

  SyncEngine get syncEngine => _locator.watch();

  DiscardFeedbackUseCase get discardFeedback => _locator.watch();

  DiscardNpsUseCase get discardNps => _locator.watch();

  ProjectCredentialValidator get projectCredentialValidator => _locator.watch();

  NpsTrigger get npsTrigger => _locator.watch();

  WiredashTelemetry get wiredashTelemetry => _locator.watch();

  AppTelemetry get appTelemetry => _locator.watch();

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

void _setupServices(WiredashServices sl) {
  sl.inject<WiredashServices>((_) => sl);

  sl.inject<Wiredash>(
    (_) => const Wiredash(
      projectId: '',
      secret: '',
      child: SizedBox(),
    ),
  );
  sl.inject<DeviceIdGenerator>((_) => DeviceIdGenerator());
  sl.inject<ProjectCredentialValidator>(
    (_) => const ProjectCredentialValidator(),
  );
  sl.inject<AppTelemetry>(
    (_) => PersistentAppTelemetry(SharedPreferences.getInstance),
  );
  sl.inject<WiredashTelemetry>(
    (_) => PersistentWiredashTelemetry(SharedPreferences.getInstance),
  );
  sl.inject<NpsTrigger>((_) {
    return NpsTrigger(
      deviceIdGenerator: sl.deviceIdGenerator,
      appTelemetry: sl.appTelemetry,
      wiredashTelemetry: sl.wiredashTelemetry,
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
  sl.inject<DeviceInfoGenerator>((_) => DeviceInfoGenerator(window));
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

  sl.inject<NpsModel>(
    (locator) => NpsModel(sl),
    dispose: (model) => model.dispose(),
  );

  sl.inject<WiredashApi>(
    (locator) {
      return WiredashApi(
        httpClient: Client(),
        projectId: sl.wiredashWidget.projectId,
        secret: sl.wiredashWidget.secret,
        deviceIdProvider: sl.deviceIdGenerator.deviceId,
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
        sharedPreferencesProvider: SharedPreferences.getInstance,
        dirPathProvider: () async =>
            (await getApplicationDocumentsDirectory()).path,
        uuidV4Generator: const UuidV4Generator(),
      );
      final retryingFeedbackSubmitter =
          RetryingFeedbackSubmitter(fileSystem, storage, sl.api);
      return retryingFeedbackSubmitter;
    },
  );

  sl.inject<SyncEngine>(
    (locator) {
      final engine = SyncEngine();

      engine.addJob(
        'ping',
        PingJob(
          apiProvider: locator.get,
          sharedPreferencesProvider: SharedPreferences.getInstance,
        ),
      );
      engine.addJob(
        'app-telemetry',
        AppTelemetryJob(
          telemetry: locator.get(),
        ),
      );
      engine.addJob(
        'feedback',
        UploadPendingFeedbackJob(
          feedbackSubmitterProvider: locator.get,
        ),
      );

      return engine;
    },
    dispose: (engine) => engine.onWiredashDispose(),
  );

  sl.inject<DiscardFeedbackUseCase>((_) => DiscardFeedbackUseCase(sl));
  sl.inject<DiscardNpsUseCase>((_) => DiscardNpsUseCase(sl));
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

/// Discards the current NPS
class DiscardNpsUseCase {
  DiscardNpsUseCase(this.services);

  final WiredashServices services;

  void call() {
    services.inject<NpsModel>(
      (locator) => NpsModel(services),
      dispose: (model) => model.dispose(),
    );
  }
}
