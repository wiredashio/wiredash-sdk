import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/support/widget_binding_support.dart';
import 'package:wiredash/src/core/wiredash_widget.dart';
import 'package:wiredash/src/feedback/data/retrying_feedback_submitter.dart';
import 'package:wiredash/src/metadata/meta_data_collector.dart';
import 'package:wiredash/wiredash.dart';

class WiredashModel with ChangeNotifier {
  WiredashModel(this.services);

  // TODO make private?
  final WiredashServices services;

  WiredashFlow? get activeFlow => _activeFlow;
  WiredashFlow? _activeFlow;

  CustomizableWiredashMetaData _customizableMetaData =
      CustomizableWiredashMetaData();

  /// Cache of the current metadata, may include user values from
  /// [Wiredash.collectMetaData]
  CustomizableWiredashMetaData get customizableMetaData {
    return _customizableMetaData;
  }

  /// Override the current metadata that will be attached to feedbacks
  set customizableMetaData(CustomizableWiredashMetaData metaData) {
    _customizableMetaData = metaData;
    notifyListeners();
  }

  /// Automatically captures information about the buildContext that was used to open Wiredash
  SessionMetaData? _sessionMetaData;

  SessionMetaData? get sessionMetaData {
    return _sessionMetaData ?? const SessionMetaData();
  }

  set sessionMetaData(SessionMetaData? sessionMetaData) {
    _sessionMetaData = sessionMetaData;
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
    try {
      await services.backdropController.animateToClosed();

      isWiredashActive = false;
      // reset options from show() call
      themeFromContext = null;
      feedbackOptionsOverride = null;
    } catch (e) {
      // might fail when the user holds the app open while hide is called
    } finally {
      if (discardFeedback) {
        services.discardFeedback();
      }
      // always discard promoter score rating on close
      services.discardPs();
      notifyListeners();
    }
  }

  /// Collects metadata from the user via [Wiredash.collectMetaData] or
  /// [fallbackCollector] which can be [WiredashFeedbackOptions.collectMetaData]
  /// or [PsOptions.collectMetaData]
  Future<CustomizableWiredashMetaData> collectSessionMetaData(
    CustomMetaDataCollector? fallbackCollector,
  ) async {
    final collector =
        services.wiredashWidget.collectMetaData ?? fallbackCollector;

    if (collector != null) {
      try {
        final before = customizableMetaData.copyWith();
        final after = await collector(before);
        return customizableMetaData = after.copyWith();
      } catch (e, stack) {
        reportWiredashInfo(
          e,
          stack,
          'Failed to collect custom metadata',
        );
      }
    }
    return customizableMetaData;
  }

  /// Submits pending analytics events
  ///
  /// Usually, events are submitted automatically, batched every 30 seconds, and
  /// when the app goes to the background.
  /// This methods allows manually submitting events at any time.
  Future<void> forceSubmitAnalyticsEvents() async {
    try {
      await services.eventSubmitter.submitEvents(force: true);
    } catch (e, stack) {
      reportWiredashInfo(e, stack, 'Unexpected error while submitting events');
    }
  }

  String get environment {
    final widgetEnv = services.wiredashWidget.environment;
    if (widgetEnv != null) {
      return widgetEnv;
    }
    if (kReleaseMode) {
      return 'prod';
    }
    return 'dev';
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
