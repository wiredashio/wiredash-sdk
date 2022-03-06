import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/options/feedback_options.dart';
import 'package:wiredash/src/common/services/services.dart';
import 'package:wiredash/src/common/theme/wiredash_theme_data.dart';
import 'package:wiredash/src/feedback/data/retrying_feedback_submitter.dart';
import 'package:wiredash/src/support/widget_binding_support.dart';
import 'package:wiredash/src/wiredash_controller.dart';
import 'package:wiredash/src/wiredash_widget.dart';

class WiredashModel with ChangeNotifier {
  WiredashModel(this.services);

  // TODO make private?
  final WiredashServices services;

  CustomizableWiredashMetaData? _metaData;

  CustomizableWiredashMetaData get metaData {
    if (_metaData == null) {
      _metaData = CustomizableWiredashMetaData();

      // prepopulate
      final buildInfo = services.buildInfoManager.buildInfo;
      _metaData!.buildVersion = buildInfo.buildVersion;
      _metaData!.buildNumber = buildInfo.buildNumber;
      _metaData!.buildCommit = buildInfo.buildCommit;
    }
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
  Future<void> show() async {
    if (isWiredashActive) return;

    isWiredashActive = true;

    // wait for backdropController to have a valid state
    await _postFrameCallbackStream()
        .map((element) => services.backdropController.hasState)
        .firstWhere((element) => element);

    await services.backdropController.animateToOpen();
  }

  /// Closes wiredash
  Future<void> hide({bool discardFeedback = false}) async {
    await services.backdropController.animateToClosed();
    isWiredashActive = false;
    if (discardFeedback) {
      services.discardFeedback();
    }
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
  _DisposableValueNotifier(T value, {required this.onDispose}) : super(value);
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
