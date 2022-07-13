import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';
import 'package:wiredash/src/core/support/widget_binding_support.dart';
import 'package:wiredash/src/core/widgets/measure_size.dart';

/// The default layout of a step in [LarryPageView]
class StepPageScaffold extends StatefulWidget {
  const StepPageScaffold({
    this.currentStep,
    this.totalSteps,
    this.title,
    this.breadcrumbTitle,
    this.description,
    required this.child,
    this.indicator,
    this.discardLabel,
    this.discardConfirmLabel,
    Key? key,
    this.onClose,
    this.alignemnt,
    this.minHeight,
  }) : super(key: key);

  final int? currentStep;
  final int? totalSteps;

  final Widget? indicator;
  final Widget? title;
  final Widget? breadcrumbTitle;
  final Widget? description;
  final Widget? discardLabel;
  final Widget? discardConfirmLabel;
  final void Function()? onClose;
  final StepPageAlignemnt? alignemnt;
  final double? minHeight;

  final Widget child;

  @override
  State<StepPageScaffold> createState() => StepPageScaffoldState();

  static StepPageScaffoldState? of(BuildContext context) {
    return context.findAncestorStateOfType<StepPageScaffoldState>();
  }
}

class StepPageScaffoldState extends State<StepPageScaffold> {
  Timer? _reallyTimer;
  bool _animateNextSizeChange = true;

  void animateNextSizeChange() {
    _animateNextSizeChange = true;
  }

  /// Remembers the true actual height reported to Backdrop. When this changes,
  /// reset the [_animateNextSizeChange], even if rounding results in the same
  /// value
  double _lastReportedHeight = 0.0;

  Size _measuredSize = Size.zero;

  Widget _buildTitle(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          DefaultTextStyle(
            style: context.text.onBackground.headlineMediumTextStyle,
            child: widget.title!,
          ),
        if (widget.description != null)
          const SizedBox(
            height: 8,
          ),
        if (widget.description != null)
          DefaultTextStyle(
            style: context.text.onBackground.bodyMediumTextStyle,
            child: widget.description!,
          )
      ],
    );
  }

  @override
  void didUpdateWidget(covariant StepPageScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.minHeight != widget.minHeight) {
      widgetsBindingInstance.addPostFrameCallback((_) {
        _reportWidgetHeight();
      });
    }
  }

  double _minHeight = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newMinHeight = context.theme.minContentHeight;
    if (_minHeight != newMinHeight) {
      _minHeight = newMinHeight;
      widgetsBindingInstance.addPostFrameCallback((_) {
        _reportWidgetHeight();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: ScrollBox(
        child: MeasureSize(
          onChange: (size, rect) {
            _measuredSize = size;
            _reportWidgetHeight();
          },
          child: SafeArea(
            minimum: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: () {
                switch (widget.alignemnt) {
                  case StepPageAlignemnt.center:
                    return CrossAxisAlignment.center;
                  case StepPageAlignemnt.end:
                    return CrossAxisAlignment.end;
                  case StepPageAlignemnt.start:
                  default:
                    return CrossAxisAlignment.start;
                }
              }(),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: () {
                    final leftPart = Row(
                      children: [
                        if (widget.indicator != null)
                          ClipRect(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 150),
                              child: widget.indicator,
                            ),
                          ),
                        if (widget.breadcrumbTitle != null &&
                            context.theme.windowSize.width > 400) ...[
                          SizedBox(
                            height: 16,
                            child: VerticalDivider(
                              color:
                                  context.theme.secondaryTextOnBackgroundColor,
                            ),
                          ),
                          Expanded(
                            child: DefaultTextStyle(
                              style: context.text.onBackground.captionTextStyle
                                  .copyWith(
                                color: context
                                    .theme.secondaryTextOnBackgroundColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              child: widget.breadcrumbTitle!,
                            ),
                          )
                        ]
                      ],
                    );

                    final rightPart = Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
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
                                  context.theme.primaryTextOnBackgroundColor,
                                  context.theme.secondaryTextOnBackgroundColor,
                                  anims.hoveredAnim.value,
                                ),
                              );
                            },
                          )
                        else if (widget.discardLabel != null) ...[
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
                                  context.wiredashModel
                                      .hide(discardFeedback: true);
                                  _reallyTimer = null;
                                }
                              });
                            },
                            child: _reallyTimer == null
                                ? DefaultTextStyle(
                                    style: context
                                        .text.onBackground.captionTextStyle
                                        .copyWith(
                                      color: context
                                          .theme.secondaryTextOnBackgroundColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    child: widget.discardLabel!,
                                  )
                                : DefaultTextStyle(
                                    style: context
                                        .text.onBackground.captionTextStyle
                                        .copyWith(
                                      color: context.theme.errorColor,
                                    ),
                                    child: widget.discardConfirmLabel ??
                                        const Text('Really?'),
                                  ),
                          ),
                        ]
                      ],
                    );
                    return [
                      Expanded(child: leftPart),
                      rightPart,
                    ];
                  }(),
                ),
                const SizedBox(height: 24),
                _buildTitle(context),
                const SizedBox(height: 32),
                widget.child,
              ],
            ),
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

  void _reportWidgetHeight() {
    if (_measuredSize == Size.zero) {
      // not yet measured
      return;
    }
    // make height a multiple of 64 (round up) to prevent micro animations
    const double multipleOf = 64;
    final multipleHeight =
        (_measuredSize.height / multipleOf).ceil() * multipleOf;

    final minHeight = widget.minHeight ?? context.theme.minContentHeight;
    final height = math.max(multipleHeight, minHeight);

    if (mounted) {
      final backdropController = WiredashBackdrop.maybeOf(context);
      if (backdropController != null) {
        if (_animateNextSizeChange == true) {
          backdropController.animateSizeChange = true;
        }
        backdropController.contentSize = Size(_measuredSize.width, height);
        if (height == _lastReportedHeight) {
          _animateNextSizeChange = false;
          return;
        }
        _lastReportedHeight = height;
      }
    }
    if (_animateNextSizeChange) {
      _animateNextSizeChange = false;
    }
  }
}

enum StepPageAlignemnt {
  start,
  center,
  end,
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
      clipBehavior: Clip.none,
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
        Flexible(
          child: Text(
            context.l10n.feedbackStepXOfY(currentStep, total),
            style: context.text.onBackground.captionTextStyle.copyWith(
              color: context.theme.secondaryTextOnBackgroundColor,
            ),
          ),
        ),
      ],
    );
  }
}
