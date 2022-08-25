import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/_ps.dart';
import 'package:wiredash/src/_wiredash_ui.dart';
import 'package:wiredash/src/core/support/material_support_layer.dart';

class PromoterScoreFlow extends StatefulWidget {
  const PromoterScoreFlow({Key? key}) : super(key: key);

  @override
  State<PromoterScoreFlow> createState() => _PromoterScoreFlowState();
}

class _PromoterScoreFlowState extends State<PromoterScoreFlow> {
  final GlobalKey<LarryPageViewState> _lpvKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final psModel = context.psModel;
    final lpv = LarryPageView(
      key: _lpvKey,
      stepCount: () {
        if (psModel.score == null) {
          return 1;
        }
        if (psModel.submitting) {
          return 1;
        }
        return 2;
      }(),
      pageIndex: psModel.index,
      onPageChanged: (index) {
        setState(() {
          psModel.index = index;
        });
      },
      builder: (context) {
        if (psModel.submitting) {
          return const PsStep3Thanks();
        }
        switch (psModel.index) {
          case 0:
            return const PsStep1Rating();
          case 1:
            return const PsStep2Message();
          default:
            throw "Unexpected index: ${psModel.index}";
        }
      },
    );

    return MaterialSupportLayer(
      child: lpv,
    );
  }
}
