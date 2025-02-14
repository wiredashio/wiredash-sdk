import 'package:flutter/material.dart';
import 'package:wiredash/src/core/theme/wirecons.dart';
import 'package:wiredash/src/core/theme/wiredash_theme.dart';
import 'package:wiredash/src/core/widgets/backdrop/step_page_scaffold.dart';
import 'package:wiredash/src/core/wiredash_localizations_ext.dart';
import 'package:wiredash/src/promoterscore/ps_model.dart';
import 'package:wiredash/src/promoterscore/ps_model_provider.dart';

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
              final PromoterScoreRating rating = context.watchPsModel.score!;
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
