import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/build_info/build_info_manager.dart';
import 'package:wiredash/src/feedback/data/persisted_feedback_item.dart';
import 'package:wiredash/src/feedback/data/retrying_feedback_submitter.dart';
import 'package:wiredash/src/wiredash_widget.dart';

class WiredashModel with ChangeNotifier {
  WiredashModel(this.state);

  final WiredashState state;

  /// `true` when Wiredash is visible
  ///
  /// Also true during the wiredash enter/exit transition
  bool get isWiredashActive => _isWiredashVisible;
  bool _isWiredashVisible = false;
  bool get isWiredashOpening => _isWiredashOpening;
  bool _isWiredashOpening = false;
  bool get isWiredashClosing => _isWiredashClosing;
  bool _isWiredashClosing = false;

  bool get isAppInteractive => _isAppInteractive;
  bool _isAppInteractive = false;

  final BuildInfoManager buildInfoManager = BuildInfoManager();

  String? get feedbackMessage => _feedbackMessage;
  // TODO move in a separate class?
  String? _feedbackMessage;

  set feedbackMessage(String? feedbackMessage) {
    final trimmed = feedbackMessage?.trim();
    if (trimmed == '') {
      _feedbackMessage = null;
    } else {
      _feedbackMessage = trimmed;
    }
    notifyListeners();
  }

  String? get userEmail => _userEmail;
  // TODO move in a separate class?
  String? _userEmail;

  set userEmail(String? userEmail) {
    final trimmed = userEmail?.trim();
    if (trimmed == '') {
      _userEmail = null;
    } else {
      _userEmail = trimmed;
    }
    notifyListeners();
  }

  bool get capturingScreenshot => _capturingScreenshot;
  bool _capturingScreenshot = false;

  // TODO save somewhere else
  String? userId;

  /// Deletes pending feedbacks
  ///
  /// Usually only relevant for debug builds
  Future<void> clearPendingFeedbacks() async {
    debugPrint("Deleting pending feedbacks");
    final submitter = state.feedbackSubmitter;
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
    await state.backdropController.showWiredash();
    _isWiredashOpening = false;
    notifyListeners();
  }

  /// Closes wiredash
  Future<void> hide() async {
    _isWiredashOpening = false;
    _isWiredashClosing = true;
    notifyListeners();

    // wait until fully closed
    await state.backdropController.hideWiredash();
    _isWiredashVisible = false;
    _isWiredashClosing = false;
    _isAppInteractive = true;
    notifyListeners();
  }

  // ignore: unused_element
  Future<void> _sendFeedback() async {
    final deviceId = await state.deviceIdGenerator.deviceId();

    final item = PersistedFeedbackItem(
      deviceId: deviceId,
      appInfo: AppInfo(
        appLocale: state.options.currentLocale.toLanguageTag(),
      ),
      buildInfo: state.buildInfoManager.buildInfo,
      deviceInfo: state.deviceInfoGenerator.generate(),
      email: userEmail,
      // TODO collect message and labels
      message: 'Message',
      type: 'labelXYZ',
      userId: userId,
    );

    try {
      // TODO add screenshot
      await state.feedbackSubmitter.submit(item, null);
    } catch (e) {
      // TODO show error UI
    }
  }

  void enterCaptureMode() {
    _capturingScreenshot = true;
    notifyListeners();
  }

  void exitCaptureMode() {
    _capturingScreenshot = false;
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

    valueNotifier = _DisposableValueNotifier(selector(this), onDispose: () {
      removeListener(onChange);
    });
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
