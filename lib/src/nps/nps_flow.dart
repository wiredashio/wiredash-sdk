import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/_nps.dart';
import 'package:wiredash/src/_wiredash_ui.dart';
import 'package:wiredash/src/core/support/material_support_layer.dart';

class NpsFlow extends StatefulWidget {
  const NpsFlow({Key? key}) : super(key: key);

  @override
  State<NpsFlow> createState() => _NpsFlowState();
}

class _NpsFlowState extends State<NpsFlow> {
  final GlobalKey<LarryPageViewState> _lpvKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final npsModel = context.npsModel;
    final lpv = LarryPageView(
      key: _lpvKey,
      stepCount: () {
        if (npsModel.score == null) {
          return 1;
        }
        if (npsModel.submitting) {
          return 1;
        }
        return 2;
      }(),
      pageIndex: npsModel.index,
      onPageChanged: (index) {
        setState(() {
          npsModel.index = index;
        });
      },
      builder: (context) {
        if (npsModel.submitting) {
          return const NpsStep3Thanks();
        }
        switch (npsModel.index) {
          case 0:
            return const NpsStep1Rating();
          case 1:
            return const NpsStep2Message();
          default:
            throw "Unexpected index: ${npsModel.index}";
        }
      },
    );

    return MaterialSupportLayer(
      child: lpv,
    );
  }
}
