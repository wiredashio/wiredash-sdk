import 'package:flutter/material.dart';
import 'package:wiredash/src/_ps.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';

class PsStep3Thanks extends StatelessWidget {
  const PsStep3Thanks({super.key});

  @override
  Widget build(BuildContext context) {
    return StepPageScaffold(
      minHeight: 0,
      alignment: StepPageAlignment.center,
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
              final rating = context.watchPsModel.score!;
              switch (rating) {
                case PromoterScoreRating.rating0:
                case PromoterScoreRating.rating1:
                case PromoterScoreRating.rating2:
                case PromoterScoreRating.rating3:
                case PromoterScoreRating.rating4:
                case PromoterScoreRating.rating5:
                case PromoterScoreRating.rating6:
                  return context.l10n.promoterScoreStep3ThanksMessageDetractors;
                case PromoterScoreRating.rating7:
                case PromoterScoreRating.rating8:
                  return context.l10n.promoterScoreStep3ThanksMessagePassives;
                case PromoterScoreRating.rating9:
                case PromoterScoreRating.rating10:
                  return context.l10n.promoterScoreStep3ThanksMessagePromoters;
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
