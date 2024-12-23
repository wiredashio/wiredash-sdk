import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:wiredash/src/_ps.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';
import 'package:wiredash/src/utils/delay.dart';

class PsStep1Rating extends StatefulWidget {
  const PsStep1Rating({
    super.key,
  });

  @override
  State<PsStep1Rating> createState() => _PsStep1RatingState();
}

class _PsStep1RatingState extends State<PsStep1Rating> {
  @override
  Widget build(BuildContext context) {
    final question = context.l10n.promoterScoreStep1Question;
    context.readPsModel.questionInUI = question;

    return StepPageScaffold(
      title: Text(question),
      discardLabel: Text(context.l10n.feedbackCloseButton),
      discardConfirmLabel: Text(context.l10n.feedbackDiscardConfirmButton),
      indicator: const StepIndicator(
        completed: false,
        currentStep: 1,
        total: 2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.promoterScoreStep1Description),
          const SizedBox(height: 32),
          _PsRater(
            score: context.watchPsModel.score?.intValue,
            onSelected: (score) async {
              final rating = score?.let((it) => createPsRating(it));
              context.watchPsModel.score = rating;

              if (rating != null) {
                final lpv =
                    context.findAncestorStateOfType<LarryPageViewState>();
                await Future.delayed(const Duration(milliseconds: 250));
                if (!mounted) return;
                lpv!.moveToNextPage();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _PsRater extends StatefulWidget {
  const _PsRater({
    required this.score,
    required this.onSelected,
  });

  final void Function(int? score) onSelected;
  final int? score;

  @override
  State<_PsRater> createState() => _PsRaterState();
}

class _PsRaterState extends State<_PsRater> {
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
                child: RatingCard(
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
                child: RatingCard(
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

class RatingCard extends StatefulWidget {
  const RatingCard({
    super.key,
    required this.value,
    required this.checked,
    required this.onTap,
  });

  final int value;
  final bool checked;
  final void Function() onTap;

  @override
  State<RatingCard> createState() => _RatingCardState();
}

class _RatingCardState extends State<RatingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late final Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() {
        setState(() {});
      });
    _bounceAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void didUpdateWidget(RatingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.checked != oldWidget.checked) {
      if (widget.checked) {
        _controller.forward();
      } else {
        _controller.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const animDuration = Duration(milliseconds: 210);

    final colorTween = ColorTween(
      // ignore: deprecated_member_use
      begin: context.theme.primaryColor.withOpacity(0.25),
      // ignore: deprecated_member_use
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

        final luminance = color.computeLuminance();
        final blackOrWhite =
            luminance < 0.4 ? const Color(0xffffffff) : const Color(0xff000000);

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
            child: ColoredBox(
              color: state.selected ? color : const Color(0x00000000),
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
                              ? blackOrWhite
                              : theme.secondaryTextOnBackgroundColor,
                        ),
                        duration: animDuration,
                        child: Text(widget.value.toString()),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 22,
                      child: AnimatedSwitcher(
                        duration: animDuration * 2,
                        child: ScaleTransition(
                          scale: _controller.isAnimating
                              ? _bounceAnim
                              : const AlwaysStoppedAnimation(1),
                          child: Icon(
                            widget.checked ? Wirecons.check : Wirecons.circle,
                            key: ValueKey(widget.checked),
                            color: state.selected ? blackOrWhite : color,
                            size: widget.checked ? 22 : 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
