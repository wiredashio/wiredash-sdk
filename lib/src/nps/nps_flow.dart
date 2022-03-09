import 'package:flutter/widgets.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';

import 'package:wiredash/src/core/support/material_support_layer.dart';

class NpsFlow extends StatefulWidget {
  const NpsFlow({Key? key}) : super(key: key);

  @override
  State<NpsFlow> createState() => _NpsFlowState();
}

class _NpsFlowState extends State<NpsFlow> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final lpv = LarryPageView(
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
          return const NpsStep1();
        } else {
          return const NpsStep2();
        }
      },
    );

    return MaterialSupportLayer(
      locale:
          context.wiredashModel.services.wiredashWidget.options?.currentLocale,
      child: Stack(
        children: [
          Form(
            child: lpv,
          ),
        ],
      ),
    );
  }
}

class NpsStep1 extends StatelessWidget {
  const NpsStep1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('1'),
    );
  }
}

class NpsStep2 extends StatelessWidget {
  const NpsStep2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('2'),
    );
  }
}
