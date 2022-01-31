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
import 'package:wiredash/src/common/services/streampod.dart';
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
    _setupServices(this);
  }

  final Locator _locator = Locator();

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

  DiscardFeedbackUseCase get discardFeedback => _locator.get();

  void updateWidget(Wiredash wiredashWidget) {
    inject<Wiredash>((_) => wiredashWidget);
  }

  @override
  void dispose() {
    _locator.dispose();
    super.dispose();
  }

  InstanceFactory<T> inject<T>(
    T Function(WiredashServices) create, {
    T Function(WiredashServices, T oldInstance)? update,
    Function(T)? dispose,
  }) {
    final factory = _locator.injectProvider(
      (locator) => create(this),
      update: update == null
          ? null
          : (_, T oldInstance) => update(this, oldInstance),
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
  sl.inject<BuildInfoManager>((_) => BuildInfoManager());
  sl.inject<BackdropController>(
    (_) => BackdropController(),
    dispose: (model) => model.dispose(),
  );
  sl.inject<PicassoController>(
    (_) => PicassoController(),
    dispose: (model) => model.dispose(),
  );
  sl.inject<DeviceInfoGenerator>((_) => DeviceInfoGenerator(window));
  sl.inject<WiredashOptionsData>(
    (locator) => locator.wiredashWidget.options ?? const WiredashOptionsData(),
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

  sl.inject<WiredashApi>(
    (locator) {
      return WiredashApi(
        httpClient: Client(),
        projectId: locator.wiredashWidget.projectId,
        secret: locator.wiredashWidget.secret,
        deviceIdProvider: locator.deviceIdGenerator.deviceId,
      );
    },
  );

  sl.inject<FeedbackSubmitter>(
    (locator) {
      if (kIsWeb) {
        return DirectFeedbackSubmitter(locator.api);
      }

      const fileSystem = LocalFileSystem();
      final storage = PendingFeedbackItemStorage(
        fileSystem,
        SharedPreferences.getInstance,
        () async => (await getApplicationDocumentsDirectory()).path,
      );
      final retryingFeedbackSubmitter =
          RetryingFeedbackSubmitter(fileSystem, storage, locator.api);
      if (kDebugMode) {
        retryingFeedbackSubmitter.deletePendingFeedbacks();
      }
      // TODO make sure this is triggered at app start
      retryingFeedbackSubmitter.submitPendingFeedbackItems();
      return retryingFeedbackSubmitter;
    },
  );

  sl.inject<DiscardFeedbackUseCase>((_) => DiscardFeedbackUseCase(sl));
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
