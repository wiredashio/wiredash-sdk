import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/options/feedback_options.dart';
import 'package:wiredash/src/feedback/data/retrying_feedback_submitter.dart';
import 'package:wiredash/src/services.dart';

class WiredashModel with ChangeNotifier {
  WiredashModel(this.services);

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
    if (services.backdropController.isWiredashActive) return;
    await services.backdropController.animateToOpen();
  }

  /// Closes wiredash
  Future<void> hide() async {
    await services.backdropController.animateToClosed();
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
