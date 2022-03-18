import 'package:flutter/widgets.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';
import 'package:wiredash/src/nps/nps_flow.dart';

/// The backdrop for [WiredashFlow.nps]
class NpsBackdrop extends StatelessWidget {
  const NpsBackdrop({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return WiredashBackdrop(
      controller: context.wiredashModel.services.backdropController,
      app: child,
      contentBuilder: (context) {
        return const NpsFlow();
      },
    );
  }
}
