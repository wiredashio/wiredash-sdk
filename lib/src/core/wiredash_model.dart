import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/support/widget_binding_support.dart';
import 'package:wiredash/src/feedback/data/retrying_feedback_submitter.dart';
import 'package:wiredash/src/metadata/meta_data_collector.dart';
import 'package:wiredash/wiredash.dart';

class WiredashModel with ChangeNotifier {
  WiredashModel(this.services);

  // TODO make private?
  final WiredashServices services;

  SessionMetaData? _metaData = CustomizableWiredashMetaData();

  WiredashFlow? get activeFlow => _activeFlow;
  WiredashFlow? _activeFlow;

  /// Cache of the current metadata, may include user values from
  /// [WiredashFeedbackOptions.collectMetaData] or [PsOptions.collectMetaData]
  SessionMetaData? get metaData {
    return _metaData;
  }

  /// Override the current metadata that will be attached to feedbacks
  set metaData(SessionMetaData? metaData) {
    _metaData = metaData;
    notifyListeners();
  }

  bool _isWiredashActive = false;

  /// True when wiredash is opening/open/closing
  bool get isWiredashActive => _isWiredashActive;

  set isWiredashActive(bool isWiredashActive) {
    _isWiredashActive = isWiredashActive;
    notifyListeners();
  }

  /// Temporary theme that overrides the `Wiredash.theme` property for the
  /// current 'show' session
  ///
  /// Also see
  /// - [Wiredash.of]
  /// - [WiredashController.show]
  WiredashThemeData? _themeFromContext;

  WiredashThemeData? get themeFromContext => _themeFromContext;

  set themeFromContext(WiredashThemeData? themeFromContext) {
    _themeFromContext = themeFromContext;
    notifyListeners();
  }

  /// The locale of the application where `Wiredash.of(context)` got called
  Locale? _appLocaleFromContext;

  Locale? get appLocaleFromContext => _appLocaleFromContext;

  set appLocaleFromContext(Locale? appLocale) {
    _appLocaleFromContext = appLocale;
    notifyListeners();
  }

  Brightness? _appBrightnessFromContext;

  Brightness? get appBrightnessFromContext => _appBrightnessFromContext;

  set appBrightnessFromContext(Brightness? appBrightness) {
    _appBrightnessFromContext = appBrightness;
    notifyListeners();
  }

  /// The feedback options passed into `Wiredash.of(context).show()` call
  WiredashFeedbackOptions? _feedbackOptionsOverride;

  WiredashFeedbackOptions? get feedbackOptionsOverride =>
      _feedbackOptionsOverride;

  set feedbackOptionsOverride(WiredashFeedbackOptions? feedbackOptions) {
    _feedbackOptionsOverride = feedbackOptions;
    notifyListeners();
  }

  WiredashFeedbackOptions? get feedbackOptions =>
      _feedbackOptionsOverride ?? services.wiredashWidget.feedbackOptions;

  /// The ps options passed into `Wiredash.of(context).showPromoterSurvey()` call
  PsOptions? _psOptionsOverride;

  PsOptions? get psOptionsOverride => _psOptionsOverride;

  set psOptionsOverride(PsOptions? psOptions) {
    _psOptionsOverride = psOptions;
    notifyListeners();
  }

  PsOptions get psOptions =>
      _psOptionsOverride ??
      services.wiredashWidget.psOptions ??
      defaultPsOptions;

  /// Called during initialization of the [Wiredash] widget
  Future<void> initializeMetadata() async {
    metaData = await _createPopulatedSessionMetadata();
    notifyListeners();
  }

  /// Deletes pending feedbacks
  ///
  /// Usually only relevant for debug builds
  Future<void> clearPendingFeedbacks() async {
    debugPrint('Deleting pending feedbacks');
    final submitter = services.feedbackSubmitter;
    if (submitter is RetryingFeedbackSubmitter) {
      await submitter.deletePendingFeedbacks();
    }
  }

  /// Opens wiredash behind the app
  Future<void> show({required WiredashFlow flow}) async {
    // TODO eventually switch flow when _activeFlow != flow
    if (isWiredashActive) return;

    _activeFlow = flow;
    isWiredashActive = true;
    notifyListeners();

    // wait for backdropController to have a valid state
    await _postFrameCallbackStream()
        .map((element) => services.backdropController.hasState)
        .firstWhere((element) => element);

    unawaited(services.syncEngine.onUserOpenedWiredash());

    await services.backdropController.animateToOpen();
  }

  /// Closes wiredash
  Future<void> hide({
    bool discardFeedback = false,
  }) async {
    await services.backdropController.animateToClosed();
    isWiredashActive = false;

    // reset options from show() call
    themeFromContext = null;
    appLocaleFromContext = null;
    feedbackOptionsOverride = null;

    if (discardFeedback) {
      services.discardFeedback();
    }
    // always discard promoter score rating on close
    services.discardPs();
    notifyListeners();
  }

  /// Collects metadata from the user via [Wiredash.collectMetaData] or
  /// [fallbackCollector] which can be [WiredashFeedbackOptions.collectMetaData]
  /// or [PsOptions.collectMetaData]
  Future<SessionMetaData> collectSessionMetaData(
    CustomMetaDataCollector? fallbackCollector,
  ) async {
    final metadata = metaData ?? await _createPopulatedSessionMetadata();

    final collector =
        services.wiredashWidget.collectMetaData ?? fallbackCollector;

    if (collector != null) {
      try {
        final collected = await collector(metadata.makeCustomizable());
        metaData = collected;
      } catch (e, stack) {
        reportWiredashError(
          e,
          stack,
          'Failed to collect custom metadata',
        );
      }
    }
    return metadata;
  }

  /// Creates [SessionMetaData] pre-populated with data already collected
  Future<SessionMetaData> _createPopulatedSessionMetadata() async {
    final fixedMetaData =
        await services.metaDataCollector.collectFixedMetaData();

    final metadata = CustomizableWiredashMetaData();
    metadata.appLocale = appLocaleFromContext?.toLanguageTag();
    metadata.appBrightness = appBrightnessFromContext;

    // buildInfo (values injected via dart-define take precedence) over values captured with native APIs
    // ignore: deprecated_member_use_from_same_package
    metadata.buildVersion =
        fixedMetaData.buildInfo.buildVersion ?? fixedMetaData.appInfo.version;
    // ignore: deprecated_member_use_from_same_package
    metadata.buildNumber = fixedMetaData.buildInfo.buildNumber ??
        fixedMetaData.appInfo.buildNumber;

    // can only be set via dart-define
    // ignore: deprecated_member_use_from_same_package
    metadata.buildCommit = fixedMetaData.buildInfo.buildCommit;

    return metadata;
  }
}

extension ChangeNotifierAsValueNotifier<C extends ChangeNotifier> on C {
  ValueNotifier<T> asValueNotifier<T>(T Function(C c) selector) {
    _DisposableValueNotifier<T>? valueNotifier;
    void onChange() {
      valueNotifier!.value = selector(this);
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      valueNotifier.notifyListeners();
    }

    valueNotifier = _DisposableValueNotifier(
      selector(this),
      onDispose: () {
        removeListener(onChange);
      },
    );
    addListener(onChange);

    return valueNotifier;
  }
}

class _DisposableValueNotifier<T> extends ValueNotifier<T> {
  _DisposableValueNotifier(super.value, {required this.onDispose});
  void Function() onDispose;

  @override
  void dispose() {
    onDispose();
    super.dispose();
  }
}

Stream<Duration> _postFrameCallbackStream() async* {
  while (true) {
    final completer = Completer<Duration>();
    widgetsBindingInstance.addPostFrameCallback((Duration timestamp) {
      completer.complete(timestamp);
    });
    yield await completer.future;
  }
}

enum WiredashFlow {
  feedback,
  promoterScore,
}
