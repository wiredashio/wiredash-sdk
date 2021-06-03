import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/build_info/build_info_manager.dart';
import 'package:wiredash/src/common/utils/build_info.dart';
import 'package:wiredash/src/feedback/data/feedback_submitter.dart';
import 'package:wiredash/src/feedback/data/retrying_feedback_submitter.dart';
import 'package:wiredash/src/wiredash_backdrop.dart';

class WiredashModel with ChangeNotifier {
  WiredashModel(
    this._feedbackSubmitter,
    this._backdropController,
  );

  final BackdropController _backdropController;
  final FeedbackSubmitter _feedbackSubmitter;

  /// `true` when Wiredash is visible
  ///
  /// Also true during the wiredash enter/exit transition
  bool get isWiredashActive => _isWiredashVisible;
  bool _isWiredashVisible = false;
  bool _isWiredashOpening = false;
  bool _isWiredashClosing = false;

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
  Future<void> show() async {
    _isWiredashOpening = true;
    _isWiredashVisible = true;
    _isAppInteractive = false;
    notifyListeners();

    // wait until fully opened
    await _backdropController.showWiredash();
    _isWiredashOpening = false;
    notifyListeners();
  }

  /// Closes wiredash
  Future<void> hide() async {
    _isWiredashClosing = true;
    notifyListeners();

    // wait until fully closed
    await _backdropController.hideWiredash();
    _isWiredashVisible = false;
    _isWiredashClosing = false;
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
