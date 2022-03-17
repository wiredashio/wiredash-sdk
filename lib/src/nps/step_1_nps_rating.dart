import 'package:flutter/material.dart';
import 'package:wiredash/src/_wiredash_ui.dart';
import 'package:wiredash/src/nps/nps_model.dart';
import 'package:wiredash/src/nps/nps_model_provider.dart';

class NpsStep1 extends StatelessWidget {
  const NpsStep1({
    Key? key,
    required this.onNext,
  }) : super(key: key);

  final void Function() onNext;

  @override
  Widget build(BuildContext context) {
    return StepPageScaffold(
      title: const Text('How likely are you to recommend us?'),
      // title: const Text('How likely are you to recommend us to your friends and colleagues?'),
      indicator: const StepIndicator(
        completed: false,
        currentStep: 1,
        total: 2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('0 = Not likely, 10 = most likely'),
          const SizedBox(height: 32),
          const NpsRater(),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TronButton(
                label: 'Next',
                trailingIcon: Wirecons.arrow_right,
                onTap: context.npsModel.score != null ? onNext : null,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class NpsRater extends StatelessWidget {
  const NpsRater({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.npsModel;
    return Align(
      alignment: context.theme.windowSize.width > 800
          ? Alignment.centerLeft
          : Alignment.center,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxItemWidth = constraints.maxWidth / 6;
          return Wrap(
            alignment: WrapAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final i in [0, 1, 2, 3, 4, 5])
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxItemWidth),
                      child: _RatingCard(
                        value: i,
                        checked: i == model.score?.intValue,
                        onTap: () {
                          if (model.score?.intValue == i) {
                            model.score = null;
                          } else {
                            model.score = createNpsRating(i);
                          }
                        },
                      ),
                    ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final i in [6, 7, 8, 9, 10])
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxItemWidth),
                      child: _RatingCard(
                        value: i,
                        checked: i == model.score?.intValue,
                        onTap: () {
                          if (model.score?.intValue == i) {
                            model.score = null;
                          } else {
                            model.score = createNpsRating(i);
                          }
                        },
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({
    Key? key,
    required this.value,
    required this.checked,
    required this.onTap,
  }) : super(key: key);

  final int value;
  final bool checked;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedClickTarget(
      onTap: onTap,
      builder: (context, state, anims) {
        final theme = context.theme;
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: theme.primaryColor.withOpacity(checked ? 1.0 : 0.25),
              width: 2,
            ),
          ),
          color: theme.primaryBackgroundColor,
          child: SizedBox(
            width: 48,
            height: 60,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      value.toString(),
                      style: TextStyle(
                        color: checked
                            ? theme.primaryTextColor
                            : theme.secondaryTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TronIcon(
                    checked ? Wirecons.check_circle : Wirecons.circle,
                    color: theme.primaryColor.withOpacity(checked ? 1.0 : 0.5),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
