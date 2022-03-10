import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';

import 'package:wiredash/src/core/support/material_support_layer.dart';
import 'package:wiredash/src/nps/step_1_nps_rating.dart';
import 'package:wiredash/src/nps/step_2_message.dart';

class NpsFlow extends StatefulWidget {
  const NpsFlow({Key? key}) : super(key: key);

  @override
  State<NpsFlow> createState() => _NpsFlowState();
}

class _NpsFlowState extends State<NpsFlow> {
  int _index = 0;

  final GlobalKey<LarryPageViewState> _lpvKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final lpv = LarryPageView(
      key: _lpvKey,
      stepCount: 2,
      initialPage: _index,
      pageIndex: _index,
      onPageChanged: (index) {
        setState(() {
          _index = index;
        });
      },
      builder: (context) {
        if (_index == 0) {
          return NpsStep1(
            onNext: () {
              _lpvKey.currentState!.moveToNextPage();
            },
          );
        } else {
          return NpsStep2Message(
            onSubmit: () {
              // TODO submit
            },
            onBack: () {
              _lpvKey.currentState!.moveToPreviousPage();
            },
          );
        }
      },
    );

    return MaterialSupportLayer(
      locale:
          context.wiredashModel.services.wiredashWidget.options?.currentLocale,
      child: lpv,
    );
  }
}
