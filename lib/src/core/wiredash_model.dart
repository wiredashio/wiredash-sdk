import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/support/widget_binding_support.dart';
import 'package:wiredash/src/feedback/data/retrying_feedback_submitter.dart';
import 'package:wiredash/wiredash.dart';

class WiredashModel with ChangeNotifier {
  WiredashModel(this.services);

  // TODO make private?
  final WiredashServices services;

  CustomizableWiredashMetaData? _metaData;

  WiredashFlow? get activeFlow => _activeFlow;
  WiredashFlow? _activeFlow;

  CustomizableWiredashMetaData get metaData {
    _metaData ??= CustomizableWiredashMetaData.populated();
    return _metaData!;
  }

  set metaData(CustomizableWiredashMetaData? metaData) {
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
