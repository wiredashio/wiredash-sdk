import 'package:flutter/material.dart';
import 'package:wiredash/src/_nps.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';

class NpsStep3Thanks extends StatelessWidget {
  const NpsStep3Thanks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StepPageScaffold(
      minHeight: 0,
      alignemnt: StepPageAlignemnt.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Wirecons.check,
            size: 48,
            color: context.theme.primaryColor,
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            () {
              final rating = context.npsModel.score!;
              switch (rating) {
                case NpsScore.rating0:
                case NpsScore.rating1:
                case NpsScore.rating2:
                case NpsScore.rating3:
                case NpsScore.rating4:
                case NpsScore.rating5:
                case NpsScore.rating6:
                  return context.l10n.npsStep3ThanksMessageDetractors;
                case NpsScore.rating7:
                case NpsScore.rating8:
                  return context.l10n.npsStep3ThanksMessagePassives;
                case NpsScore.rating9:
                case NpsScore.rating10:
                  return context.l10n.npsStep3ThanksMessagePromoters;
              }
            }(),
            textAlign: TextAlign.center,
            style: context.text.title.onBackground,
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }
}
