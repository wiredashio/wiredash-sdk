import 'package:flutter/widgets.dart';
import 'package:wiredash/src/_ps.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';

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
