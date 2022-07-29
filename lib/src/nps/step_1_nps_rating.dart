import 'package:flutter/material.dart';
import 'package:wiredash/src/_wiredash_ui.dart';
import 'package:wiredash/src/core/wiredash_model_provider.dart';
import 'package:wiredash/src/feedback/data/delay.dart';
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
          const Text('0 = Not likely, 10 = most likely'),
          const SizedBox(height: 32),
          _NpsRater(onSelected: onNext),
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

class _NpsRater extends StatefulWidget {
  const _NpsRater({
    Key? key,
    this.onSelected,
  }) : super(key: key);

  final void Function()? onSelected;

  @override
  State<_NpsRater> createState() => _NpsRaterState();
}

class _NpsRaterState extends State<_NpsRater> {
  Delay? _selectionDelay;

  void _onTap(int score) {
    final model = context.npsModel;
    _selectionDelay?.dispose();
    if (model.score?.intValue == score) {
      model.score = null;
    } else {
      model.score = createNpsRating(score);
      _fire();
    }
  }

  Future<void> _fire() async {
    _selectionDelay = Delay(const Duration(seconds: 1));
    await _selectionDelay!.future;
    if (!mounted) return;
    widget.onSelected?.call();
  }

  @override
  void dispose() {
    super.dispose();
    _selectionDelay?.dispose();
  }

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
                        onTap: () => _onTap(i),
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
                        onTap: () => _onTap(i),
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
  late AnimationController _controller;
  late Animation<Border?> _borderAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      debugLabel: 'RatingCard',
    )..addListener(() {
        setState(() {});
      });
    if (widget.checked) {
      _controller.forward(from: 1);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final borderTween = BorderTween(
      begin: Border.fromBorderSide(
        BorderSide(
          color: context.theme.primaryColor.withOpacity(0.25),
          width: 2,
        ),
      ),
      end: Border.fromBorderSide(
        BorderSide(
          color: context.theme.primaryColor.withOpacity(1.0),
          width: 2,
        ),
      ),
    );
    _borderAnimation = borderTween.animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant _RatingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.checked != widget.checked) {
      if (widget.checked) {
        _controller.forward();
      } else {
        _controller.reverse();
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
    return AnimatedClickTarget(
      onTap: widget.onTap,
      builder: (context, state, anims) {
        final theme = context.theme;
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: _borderAnimation.value!.top,
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
                    child: AnimatedDefaultTextStyle(
                      curve: Curves.easeInOut,
                      style: TextStyle(
                        color: widget.checked
                            ? theme.primaryTextOnBackgroundColor
                            : theme.secondaryTextOnBackgroundColor,
                      ),
                      duration: _controller.duration!,
                      child: Text(widget.value.toString()),
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedSwitcher(
                    duration: _controller.duration! * 2,
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    child: Icon(
                      widget.checked ? Wirecons.check_circle : Wirecons.circle,
                      key: ValueKey(widget.checked),
                      color: theme.primaryColor
                          .withOpacity(widget.checked ? 1.0 : 0.5),
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
