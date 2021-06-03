import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/build_info/build_info_manager.dart';
import 'package:wiredash/src/common/utils/build_info.dart';
import 'package:wiredash/src/feedback/data/feedback_submitter.dart';
import 'package:wiredash/src/feedback/data/retrying_feedback_submitter.dart';

class WiredashModel with ChangeNotifier {
  WiredashModel(
    this._feedbackSubmitter,
  );

  final FeedbackSubmitter _feedbackSubmitter;

  /// `true` when wiredash is active
  bool get isWiredashActive => _isWiredashActive;
  bool _isWiredashActive = false;

  bool get isAppInteractive => _isAppInteractive;
  bool _isAppInteractive = false;

  final BuildInfoManager buildInfoManager =
      BuildInfoManager(PlatformBuildInfo());

  // TODO save somewhere else
  String? userId;
  String? userEmail;

  /// Deletes pending feedbacks
  ///
  /// Usually only relevant for debug builds
  Future<void> clearPendingFeedbacks() async {
    debugPrint("Deleting pending feedbacks");
    final submitter = _feedbackSubmitter;
    if (submitter is RetryingFeedbackSubmitter) {
      await submitter.deletePendingFeedbacks();
    }
  }

  /// Opens wiredash behind the app
  void show() {
    _isWiredashActive = true;
    _isAppInteractive = false;
    notifyListeners();
  }

  /// Closes wiredash
  void hide() {
    _isWiredashActive = false;
    _isAppInteractive = true;
    notifyListeners();
  }

  // Future<void> _sendFeedback() async {
  //   final item = FeedbackItem(
  //     deviceInfo: _deviceInfoGenerator.generate(),
  //     email: _userManager.userEmail,
  //     message: feedbackMessage!,
  //     type: feedbackType.label,
  //     user: _userManager.userId,
  //   );
  //
  //   try {
  //     await _feedbackSubmitter.submit(item, screenshot);
  //   } catch (e) {
  //   }
  // }
}

extension ChangeNotifierAsValueNotifier<C extends ChangeNotifier> on C {
  ValueNotifier<T> asValueNotifier<T>(T Function(C c) selector) {
    _DisposableValueNotifier<T>? valueNotifier;
    void onChange() {
      valueNotifier!.value = selector(this);
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      valueNotifier.notifyListeners();
    }

    valueNotifier = _DisposableValueNotifier(selector(this), onDispose: () {
      this.removeListener(onChange);
    });
    this.addListener(onChange);

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
