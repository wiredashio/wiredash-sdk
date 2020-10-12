import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/network/network_manager.dart';
import 'package:wiredash/src/common/user/user_manager.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';

class WiredashProvider extends InheritedWidget {
  const WiredashProvider({
    Key key,
    @required this.networkManager,
    @required this.userManager,
    @required this.feedbackModel,
    @required Widget child,
  })  : assert(child != null),
        super(key: key, child: child);

  final NetworkManager networkManager;
  final UserManager userManager;
  final FeedbackModel feedbackModel;

  static WiredashProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<WiredashProvider>();
  }

  @override
  bool updateShouldNotify(WiredashProvider old) {
    return feedbackModel != old.feedbackModel ||
        networkManager != old.networkManager ||
        userManager != old.userManager;
  }
}

extension WiredashExtensions on BuildContext {
  FeedbackModel get feedbackModel => WiredashProvider.of(this).feedbackModel;

  NetworkManager get networkManager => WiredashProvider.of(this).networkManager;

  UserManager get userManager => WiredashProvider.of(this).userManager;
}
