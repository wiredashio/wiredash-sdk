import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';
import 'package:wiredash/src/nps/nps_model.dart';
import 'package:wiredash/src/nps/nps_model_provider.dart';
import 'package:wiredash/src/utils/delay.dart';

class NpsStep1Rating extends StatefulWidget {
  const NpsStep1Rating({
    Key? key,
  }) : super(key: key);

  @override
  State<NpsStep1Rating> createState() => _NpsStep1RatingState();
}

class _NpsStep1RatingState extends State<NpsStep1Rating> {
  @override
  Widget build(BuildContext context) {
    return StepPageScaffold(
      title: Text(context.l10n.npsStep1Question),
      onClose: () {
        context.wiredashModel.hide(discardNps: true);
      },
      indicator: const StepIndicator(
        completed: false,
        currentStep: 1,
        total: 2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.npsStep1Description),
          const SizedBox(height: 32),
          _NpsRater(
            score: context.npsModel.score?.intValue,
            onSelected: (score) async {
              final rating = score?.let((it) => createNpsRating(it));
              context.npsModel.score = rating;

              if (rating != null) {
                final lpv =
                    context.findAncestorStateOfType<LarryPageViewState>();
                await Future.delayed(const Duration(milliseconds: 250));
                if (!mounted) return;
                lpv!.moveToNextPage();
              }
            },
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TronButton(
                label: context.l10n.npsNextButton,
                trailingIcon: Wirecons.arrow_right,
                onTap: context.npsModel.score != null
                    ? () {
                        context
                            .findAncestorStateOfType<LarryPageViewState>()!
                            .moveToNextPage();
                      }
                    : null,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _NpsRater extends StatefulWidget {
  const _NpsRater({
    Key? key,
    required this.score,
    required this.onSelected,
  }) : super(key: key);

  final void Function(int? score) onSelected;
  final int? score;

  @override
  State<_NpsRater> createState() => _NpsRaterState();
}

class _NpsRaterState extends State<_NpsRater> {
  static const double _twoLineBreakpoint = 600;
  static const double _minItemWidth = 44;

  Delay? _selectionDelay;

  // score between pressed and submitted to callback
  int? _inflightScore;

  void _onTap(int score) {
    setState(() {
      if ((_inflightScore ?? widget.score) == score) {
        _inflightScore = null;
      } else {
        _inflightScore = score;
      }
    });
    _fire();
  }

  Future<void> _fire() async {
    _selectionDelay?.dispose();
    _selectionDelay = Delay(const Duration(milliseconds: 400));
    await _selectionDelay!.future;
    if (!mounted) return;
    widget.onSelected.call(_inflightScore);
    _inflightScore = null;
  }

  @override
  void dispose() {
    super.dispose();
    _selectionDelay?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxItemWidth;
        final int rows;
        final itemSpace = constraints.maxWidth / 11;
        if (itemSpace < _minItemWidth) {
          // make two rows
          final two = constraints.maxWidth / 6;
          rows = 2;
          maxItemWidth = two;
        } else {
          // show everything in a single line
          rows = 1;
          maxItemWidth = itemSpace;
        }
        final selectedScore = _inflightScore ?? widget.score;
        final row1 = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final i in [0, 1, 2, 3, 4, 5])
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxItemWidth),
                child: _RatingCard(
                  value: i,
                  checked: i == selectedScore,
                  onTap: () => _onTap(i),
                ),
              ),
          ],
        );
        final row2 = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final i in [6, 7, 8, 9, 10])
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxItemWidth),
                child: _RatingCard(
                  value: i,
                  checked: i == selectedScore,
                  onTap: () => _onTap(i),
                ),
              ),
          ],
        );

        return Align(
          alignment: rows == 1 ? Alignment.centerLeft : Alignment.center,
          child: Builder(
            builder: (context) {
              if (rows == 1) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [...row1.children, ...row2.children],
                );
              } else {
                return Column(
                  children: [
                    row1,
                    row2,
                  ],
                );
              }
            },
          ),
        );
      },
    );
  }
}

class _RatingCard extends StatefulWidget {
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
  _RatingCardState createState() => _RatingCardState();
}

class _RatingCardState extends State<_RatingCard>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    const animDuration = Duration(milliseconds: 210);

    final colorTween = ColorTween(
      begin: context.theme.primaryColor.withOpacity(0.25),
      end: context.theme.primaryColor.withOpacity(1.0),
    );

    return AnimatedClickTarget(
      onTap: widget.onTap,
      selected: widget.checked,
      duration: animDuration,
      hoverDuration: animDuration,
      builder: (context, state, anims) {
        final theme = context.theme;
        final color = () {
          final hover = anims.hoveredAnim.value * 0.5;
          final selected = anims.selectedAnim.value * 0.8;
          double combined = 0.0;
          if (anims.hoveredAnim.value > 0 && anims.selectedAnim.value > 0) {
            combined =
                anims.hoveredAnim.value * 0.5 + anims.selectedAnim.value * 0.5;
          }

          final t = max(combined, max(hover, selected));
          return colorTween.transform(t)!;
        }();
        return Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: theme.primaryBackgroundColor,
            border: Border.all(
              color: color,
              width: 2,
            ),
          ),
          child: SizedBox(
            width: 48,
            height: 60,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: AnimatedDefaultTextStyle(
                      curve: Curves.easeInOut,
                      style: TextStyle(
                        color: widget.checked
                            ? theme.primaryTextOnBackgroundColor
                            : theme.secondaryTextOnBackgroundColor,
                      ),
                      duration: animDuration,
                      child: Text(widget.value.toString()),
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedSwitcher(
                    duration: animDuration * 2,
                    child: Icon(
                      widget.checked ? Wirecons.check_circle : Wirecons.circle,
                      key: ValueKey(widget.checked),
                      color: color,
                      size: 18,
                    ),
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
