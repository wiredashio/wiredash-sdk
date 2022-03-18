import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';

/// The default layout of a step in [LarryPageView]
class StepPageScaffold extends StatefulWidget {
  const StepPageScaffold({
    this.currentStep,
    this.totalSteps,
    required this.title,
    this.shortTitle,
    this.description,
    required this.child,
    this.indicator,
    this.discardLabel,
    this.discardConfirmLabel,
    Key? key,
    this.onClose,
  }) : super(key: key);

  final int? currentStep;
  final int? totalSteps;

  final Widget? indicator;
  final Widget title;
  final Widget? shortTitle;
  final Widget? description;
  final Widget? discardLabel;
  final Widget? discardConfirmLabel;
  final void Function()? onClose;

  final Widget child;

  @override
  State<StepPageScaffold> createState() => _StepPageScaffoldState();
}

class _StepPageScaffoldState extends State<StepPageScaffold> {
  Timer? _reallyTimer;

  Widget _buildTitle(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefaultTextStyle(
          style: context.theme.headlineTextStyle,
          child: widget.title,
        ),
        if (widget.description != null)
          const SizedBox(
            height: 8,
          ),
        if (widget.description != null)
          DefaultTextStyle(
            style: context.theme.bodyTextStyle,
            child: widget.description!,
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      child: ScrollBox(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (widget.indicator != null) widget.indicator!,
                  if (widget.shortTitle != null &&
                      context.theme.windowSize.width > 400) ...[
                    SizedBox(
                      height: 16,
                      child: VerticalDivider(
                        color: context.theme.captionTextStyle.color,
                      ),
                    ),
                    Expanded(
                      child: DefaultTextStyle(
                        style: context.theme.captionTextStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        child: widget.shortTitle!,
                      ),
                    )
                  ] else
                    const Spacer(),
                  if (widget.onClose != null)
                    AnimatedClickTarget(
                      onTap: widget.onClose,
                      builder: (
                        BuildContext context,
                        TargetState state,
                        TargetStateAnimations anims,
                      ) {
                        return TronIcon(
                          Wirecons.x,
                          color: Color.lerp(
                            context.theme.secondaryTextColor,
                            context.theme.primaryTextColor,
                            anims.hoveredAnim.value,
                          ),
                        );
                      },
                    )
                  else if (widget.discardLabel != null)
                    TronLabeledButton(
                      onTap: () {
                        setState(() {
                          if (_reallyTimer == null) {
                            setState(() {
                              _reallyTimer =
                                  Timer(const Duration(seconds: 3), () {
                                if (mounted) {
                                  setState(() {
                                    _reallyTimer = null;
                                  });
                                } else {
                                  _reallyTimer = null;
                                }
                              });
                            });
                          } else {
                            context.wiredashModel.hide(discardFeedback: true);
                            _reallyTimer = null;
                          }
                        });
                      },
                      child: _reallyTimer == null
                          ? widget.discardLabel!
                          : DefaultTextStyle(
                              style: TextStyle(color: context.theme.errorColor),
                              child: widget.discardConfirmLabel ??
                                  const Text('Really?'),
                            ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTitle(context),
              const SizedBox(height: 32),
              widget.child,
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _reallyTimer?.cancel();
    super.dispose();
  }
}

/// Scrollable area with scrollbar
class ScrollBox extends StatefulWidget {
  const ScrollBox({
    Key? key,
    required this.child,
    this.padding,
  }) : super(key: key);

  final Widget child;

  final EdgeInsetsGeometry? padding;

  @override
  State<ScrollBox> createState() => _ScrollBoxState();
}

class _ScrollBoxState extends State<ScrollBox> {
  @override
  Widget build(BuildContext context) {
    final controller = StepInformation.of(context).innerScrollController;
    Widget child = SingleChildScrollView(
      controller: controller,
      padding: widget.padding,
      child: widget.child,
    );
    final targetPlatform = Theme.of(context).platform;
    final bool isTouchInput = targetPlatform == TargetPlatform.iOS ||
        targetPlatform == TargetPlatform.android;
    if (isTouchInput) {
      child = Scrollbar(
        interactive: false,
        controller: controller,
        // ignore: deprecated_member_use
        isAlwaysShown: false,
        child: child,
      );
    }

    return child;
  }
}

class StepIndicator extends StatelessWidget {
  const StepIndicator({
    Key? key,
    required this.completed,
    required this.total,
    required this.currentStep,
  }) : super(key: key);

  final bool completed;
  final int total;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TronProgressIndicator(
          currentStep: completed ? total : currentStep - 1,
          totalSteps: total,
        ),
        const SizedBox(width: 12),
        Text(
          'Step $currentStep of $total',
          style: context.theme.captionTextStyle,
        ),
      ],
    );
  }
}
