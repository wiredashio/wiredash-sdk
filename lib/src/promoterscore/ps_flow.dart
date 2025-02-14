import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/core/support/material_support_layer.dart';
import 'package:wiredash/src/core/widgets/larry_page_view.dart';
import 'package:wiredash/src/promoterscore/ps_model_provider.dart';
import 'package:wiredash/src/promoterscore/step_1_rating.dart';
import 'package:wiredash/src/promoterscore/step_2_message.dart';
import 'package:wiredash/src/promoterscore/step_3_thanks.dart';

class PromoterScoreFlow extends StatefulWidget {
  const PromoterScoreFlow({super.key});

  @override
  State<PromoterScoreFlow> createState() => _PromoterScoreFlowState();
}

class _PromoterScoreFlowState extends State<PromoterScoreFlow> {
  final GlobalKey<LarryPageViewState> _lpvKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final lpv = LarryPageView(
      key: _lpvKey,
      stepCount: () {
        if (context.watchPsModel.score == null) {
          return 1;
        }
        if (context.watchPsModel.submitting) {
          return 1;
        }
        return 2;
      }(),
      pageIndex: context.watchPsModel.index,
      onPageChanged: (index) {
        setState(() {
          context.readPsModel.index = index;
        });
      },
      builder: (context) {
        final psModel = context.watchPsModel;
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
