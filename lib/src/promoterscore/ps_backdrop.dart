import 'package:flutter/widgets.dart';
import 'package:wiredash/src/core/widgets/backdrop/wiredash_backdrop.dart';
import 'package:wiredash/src/core/wiredash_model.dart';
import 'package:wiredash/src/promoterscore/ps_flow.dart';

/// The backdrop for [WiredashFlow.promoterScore]
class PsBackdrop extends StatelessWidget {
  const PsBackdrop({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return WiredashBackdrop(
      controller: context.wiredashModel.services.backdropController,
      padding: context.wiredashModel.services.wiredashWidget?.padding,
      app: child,
      contentBuilder: (context) {
        return const PromoterScoreFlow();
      },
    );
  }
}
