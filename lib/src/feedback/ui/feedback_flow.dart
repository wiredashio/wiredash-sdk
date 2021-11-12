import 'package:flutter/material.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/widgets/wiredash_icons.dart';
import 'package:wiredash/src/feedback/data/label.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';
import 'package:wiredash/src/feedback/ui/big_blue_button.dart';
import 'package:wiredash/src/feedback/ui/email_input.dart';
import 'package:wiredash/src/feedback/ui/grey_scale_filter.dart';
import 'package:wiredash/src/feedback/ui/labeled_button.dart';
import 'package:wiredash/src/feedback/ui/larry_page_view.dart';
import 'package:wiredash/src/feedback/ui/more_menu.dart';
import 'package:wiredash/src/responsive_layout.dart';

const _labels = [
  Label(id: 'bug', name: 'Bug'),
  Label(id: 'improvement', name: 'Improvement'),
  Label(id: 'praise', name: 'Praise 🎉'),
];

class WiredashFeedbackFlow extends StatefulWidget {
  const WiredashFeedbackFlow({Key? key}) : super(key: key);

  @override
  State<WiredashFeedbackFlow> createState() => _WiredashFeedbackFlowState();
}

class _WiredashFeedbackFlowState extends State<WiredashFeedbackFlow>
    with TickerProviderStateMixin {
  final GlobalKey<LarryPageViewState> stepFormKey =
      GlobalKey<LarryPageViewState>();
  final ValueNotifier<Set<Label>> _selectedLabels = ValueNotifier({});
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    // labels
    final part2 = ValueListenableBuilder<Set<Label>>(
      valueListenable: _selectedLabels,
      builder: (context, selectedLabels, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveLayout.horizontalMargin,
                vertical: 16,
              ),
              child: const Text(
                'What category fits best with your feedback?',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveLayout.horizontalMargin,
                vertical: 16,
              ),
              child: _LabelRecommendations(
                isAnyLabelSelected: selectedLabels.isNotEmpty,
                isLabelSelected: selectedLabels.contains,
                toggleSelection: (label) {
                  setState(() {
                    if (selectedLabels.contains(label)) {
                      selectedLabels.remove(label);
                    } else {
                      selectedLabels.add(label);
                    }
                  });
                },
              ),
            ),
            Builder(
              builder: (context) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsiveLayout.horizontalMargin,
                    vertical: 16,
                  ),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 225),
                    // ignore: deprecated_member_use
                    vsync: this,
                    clipBehavior: Clip.none,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 225),
                      reverseDuration: const Duration(milliseconds: 170),
                      switchInCurve: Curves.fastOutSlowIn,
                      switchOutCurve: Curves.fastOutSlowIn,
                      child: () {
                        if (selectedLabels.isEmpty) {
                          return LabeledButton(
                            child: const Text('Skip'),
                            onTap: () {
                              StepInformation.of(context)
                                  .pageView
                                  .moveToNextPage();
                            },
                          );
                        }

                        return BigBlueButton(
                          child: const Icon(Icons.arrow_right_alt),
                          onTap: () {
                            StepInformation.of(context)
                                .pageView
                                .moveToNextPage();
                          },
                        );
                      }(),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );

    // email
    final part3 = Builder(builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EmailInput(),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsiveLayout.horizontalMargin,
              vertical: 16,
            ),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 225),
              // ignore: deprecated_member_use
              vsync: this,
              clipBehavior: Clip.none,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 225),
                reverseDuration: const Duration(milliseconds: 170),
                switchInCurve: Curves.fastOutSlowIn,
                switchOutCurve: Curves.fastOutSlowIn,
                child: () {
                  if (context.feedbackModel.userEmail?.isEmpty != false) {
                    return LabeledButton(
                      child: const Text('Skip'),
                      onTap: () {
                        StepInformation.of(context).pageView.moveToNextPage();
                      },
                    );
                  }

                  return BigBlueButton(
                    child: const Icon(Icons.arrow_right_alt),
                    onTap: () {
                      StepInformation.of(context).pageView.moveToNextPage();
                    },
                  );
                }(),
              ),
            ),
          ),
        ],
      );
    });

    // screenshot
    final part4 = Builder(builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsiveLayout.horizontalMargin,
              vertical: 16,
            ),
            child: const Text(
              'For a better understanding. Do you want to take a screenshot of it?',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsiveLayout.horizontalMargin,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BigBlueButton(
                  child: const Text("Yes"),
                  onTap: () {
                    context.feedbackModel.enterCaptureMode();
                  },
                ),
                const SizedBox(height: 64),
                LabeledButton(
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text("I'm done"),
                  ),
                  onTap: () {
                    StepInformation.of(context).pageView.moveToNextPage();
                  },
                ),
              ],
            ),
          ),
        ],
      );
    });

    // submit
    final part5 = Builder(builder: (context) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveLayout.horizontalMargin,
          vertical: 16,
        ),
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Summary',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Message: ${context.feedbackModel.feedbackMessage}\n'
                  '\n'
                  'Labels: ${_selectedLabels.value.map((e) => e.name)}\n'
                  '\n'
                  'Email: ${context.feedbackModel.userEmail}\n'
                  '\n'
                  'Screenshots: 0\n'
                  '\n'
                  'AppVersion: TODO\n'
                  'Browser Version: TODO\n'
                  'Whatever is useful\n',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Center(
                  child: BigBlueButton(
                    text: const Text('Submit'),
                    onTap: () {
                      context.feedbackModel.submitFeedback();
                    },
                    child: const Icon(WiredashIcons.submit),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });

    return GestureDetector(
      onTap: () {
        Focus.maybeOf(context)?.unfocus();
      },
      child: LarryPageView(
        viewInsets: MediaQuery.of(context).padding,
        stepCount: 5,
        initialPage: _page,
        onPageChanged: (index) {
          setState(() {
            _page = index;
          });
        },
        builder: (context) {
          final index = _page;
          final stepWidget = () {
            if (index == 0) {
              return const FeedbackMessageStepPage();
            }
            if (index == 1) {
              return ScrollBox(
                child: part2,
              );
            }
            if (index == 2) {
              return ScrollBox(
                child: part3,
              );
            }
            if (index == 3) {
              return ScrollBox(
                child: part4,
              );
            }
            if (index == 4) {
              return ScrollBox(
                child: part5,
              );
            }
            throw 'Index out of bounds $index';
          }();
          final step = StepInformation.of(context);
          return GreyScaleFilter(
            greyScale: step.animation.value,
            child: stepWidget,
          );
        },
      ),
    );
  }
}

/// Scrollable area with scrollbar
class ScrollBox extends StatefulWidget {
  const ScrollBox({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  State<ScrollBox> createState() => _ScrollBoxState();
}

class _ScrollBoxState extends State<ScrollBox> {
  @override
  Widget build(BuildContext context) {
    final controller = StepInformation.of(context).innerScrollController;
    return Theme(
      data: ThemeData(brightness: Brightness.light),
      child: Scrollbar(
        interactive: false,
        controller: controller,
        isAlwaysShown: true,
        child: SingleChildScrollView(
          controller: controller,
          child: widget.child,
        ),
      ),
    );
  }
}

class StepPageScaffold extends StatelessWidget {
  const StepPageScaffold({
    required this.body,
    this.bottomBarBuilder,
    Key? key,
  }) : super(key: key);

  final Widget body;
  final Widget Function(BuildContext context)? bottomBarBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ScrollBox(
            child: body,
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.fastOutSlowIn,
          switchOutCurve: Curves.fastOutSlowIn,
          child: bottomBarBuilder?.call(context),
        )
      ],
    );
  }
}

class FeedbackMessageStepPage extends StatefulWidget {
  const FeedbackMessageStepPage({Key? key}) : super(key: key);

  @override
  State<FeedbackMessageStepPage> createState() =>
      _FeedbackMessageStepPageState();
}

class _FeedbackMessageStepPageState extends State<FeedbackMessageStepPage>
    with TickerProviderStateMixin {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: FeedbackModelProvider.of(context, listen: false).feedbackMessage,
    )..addListener(() {
        final text = _controller.text;
        if (context.feedbackModel.feedbackMessage != text) {
          context.feedbackModel.feedbackMessage = text;
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StepPageScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: context.responsiveLayout.horizontalMargin,
              left: context.responsiveLayout.horizontalMargin,
              right: context.responsiveLayout.horizontalMargin,
            ),
            child: _FeedbackMessageInput(
              controller: _controller,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsiveLayout.horizontalMargin,
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return AnimatedSize(
                  // ignore: deprecated_member_use
                  vsync: this,
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.fastOutSlowIn,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 225),
                    reverseDuration: const Duration(milliseconds: 170),
                    switchInCurve: Curves.fastOutSlowIn,
                    switchOutCurve: Curves.fastOutSlowIn,
                    child: Container(
                      key: ValueKey(_controller.text.isEmpty),
                      child: () {
                        if (_controller.text.isEmpty) {
                          return const MoreMenu();
                        }
                        return const SizedBox();
                      }(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomBarBuilder: (context) {
        if (_controller.text.isEmpty) {
          return const SizedBox();
        }
        return Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: BigBlueButton(
            child: const Icon(Icons.arrow_right_alt),
            onTap: () {
              Focus.maybeOf(context)?.unfocus();
              StepInformation.of(context).pageView.moveToNextPage();
            },
          ),
        );
      },
    );
  }
}

class _FeedbackMessageInput extends StatefulWidget {
  const _FeedbackMessageInput({required this.controller, Key? key})
      : super(key: key);

  final TextEditingController controller;

  @override
  _FeedbackMessageInputState createState() => _FeedbackMessageInputState();
}

class _FeedbackMessageInputState extends State<_FeedbackMessageInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Give us feedback',
            style: context.responsiveLayout.titleTextStyle,
          ),
        ),
        TextField(
          controller: widget.controller,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          maxLength: 2048,
          buildCounter: _getCounterText,
          minLines: 3,
          style: context.responsiveLayout.bodyTextStyle,
          decoration: const InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            hintText: 'e.g. there’s a bug when ... or I really enjoy ...',
            contentPadding: EdgeInsets.only(
              top: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _LabelRecommendations extends StatelessWidget {
  const _LabelRecommendations({
    required this.isAnyLabelSelected,
    required this.isLabelSelected,
    required this.toggleSelection,
    Key? key,
  }) : super(key: key);

  final bool isAnyLabelSelected;
  final bool Function(Label) isLabelSelected;
  final void Function(Label) toggleSelection;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _labels.map((label) {
          return _Label(
            label: label,
            isAnyLabelSelected: isAnyLabelSelected,
            selected: isLabelSelected(label),
            toggleSelection: () => toggleSelection(label),
          );
        }).toList(),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({
    required this.label,
    required this.isAnyLabelSelected,
    required this.selected,
    required this.toggleSelection,
    Key? key,
  }) : super(key: key);

  final Label label;
  final bool isAnyLabelSelected;
  final bool selected;
  final VoidCallback toggleSelection;

  // If this label is selected, or if this label is deselected AND no other
  // labels have been selected, we want to display the tint color.
  //
  // However, if this label is deselected but some other labels are selected, we
  // want to display a gray color with less contrast so that this label really
  // looks different from the selected ones.
  Color _resolveTextColor() {
    return selected || !isAnyLabelSelected
        ? const Color(0xFF1A56DB) // tint
        : const Color(0xFFA0AEC0); // gray / 500
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleSelection,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 225),
        curve: Curves.ease,
        constraints: const BoxConstraints(maxHeight: 41, minHeight: 41),
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFFE8EEFB),
          borderRadius: BorderRadius.circular(10),
          border: selected
              ? Border.all(
                  width: 2,
                  // tint
                  color: const Color(0xFF1A56DB),
                )
              : Border.all(
                  width: 2,
                  color: Colors.transparent,
                ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        child: Align(
          widthFactor: 1,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 225),
            curve: Curves.ease,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: _resolveTextColor(), // gray / 500
            ),
            child: Text(label.name),
          ),
        ),
      ),
    );
  }
}

Widget? _getCounterText(
  /// The build context for the TextField.
  BuildContext context, {

  /// The length of the string currently in the input.
  required int currentLength,

  /// The maximum string length that can be entered into the TextField.
  required int? maxLength,

  /// Whether or not the TextField is currently focused.  Mainly provided for
  /// the [liveRegion] parameter in the [Semantics] widget for accessibility.
  required bool isFocused,
}) {
  final max = maxLength ?? 2048;
  final remaining = max - currentLength;

  Color _getCounterColor() {
    if (remaining >= 150) {
      return Colors.green.shade400.withOpacity(0.8);
    } else if (remaining >= 50) {
      return Colors.orange.withOpacity(0.8);
    }
    return Theme.of(context).errorColor;
  }

  return Text(
    remaining > 150 ? '' : remaining.toString(),
    style: WiredashTheme.of(context)!
        .inputErrorStyle
        .copyWith(color: _getCounterColor()),
  );
}
