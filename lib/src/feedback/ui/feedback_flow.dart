import 'package:flutter/material.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/widgets/wiredash_icons.dart';
import 'package:wiredash/src/feedback/data/label.dart';
import 'package:wiredash/src/feedback/ui/big_blue_button.dart';
import 'package:wiredash/src/feedback/ui/email_input.dart';
import 'package:wiredash/src/feedback/ui/more_menu.dart';
import 'package:wiredash/src/feedback/ui/step_form.dart';
import 'package:wiredash/src/responsive_layout.dart';
import 'package:wiredash/src/scroll_wizard.dart';
import 'package:wiredash/src/wiredash_provider.dart';

const _labels = [
  Label(id: 'bug', name: 'Bug'),
  Label(id: 'improvement', name: 'Improvement'),
  Label(id: 'praise', name: 'Praise 🎉'),
];

class WiredashFeedbackFlow extends StatefulWidget {
  const WiredashFeedbackFlow({this.focusNode, Key? key}) : super(key: key);

  final FocusNode? focusNode;

  @override
  State<WiredashFeedbackFlow> createState() => _WiredashFeedbackFlowState();
}

class _WiredashFeedbackFlowState extends State<WiredashFeedbackFlow>
    with TickerProviderStateMixin {
  final ValueNotifier<Set<Label>> _selectedLabels = ValueNotifier({});
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: WiredashProvider.of(context, listen: false).feedbackMessage,
    )..addListener(() {
        final text = _controller.text;
        if (context.wiredashModel.feedbackMessage != text) {
          context.wiredashModel.feedbackMessage = text;
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
    final scrollWizardController =
        ScrollWizardController(viewportFraction: 0.4);

    void nextPage() {
      scrollWizardController.nextPage(
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 300),
      );
    }

    // message
    final part1 = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveLayout.horizontalMargin,
          ),
          child: _FeedbackMessageInput(
            controller: _controller,
            focusNode: widget.focusNode,
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
                      return Container(
                        alignment: Alignment.topLeft,
                        child: ElevatedButton(
                          child: Icon(Icons.arrow_right_alt),
                          onPressed: () {
                            nextPage();
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                        ),
                      );
                    }(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );

    // labels
    final part2 = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveLayout.horizontalMargin,
          ),
          child: Text(
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
          child: ValueListenableBuilder<Set<Label>>(
            valueListenable: _selectedLabels,
            builder: (context, selectedLabels, child) {
              return _LabelRecommendations(
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
              );
            },
          ),
        ),
        AnimatedBuilder(
          animation: scrollWizardController,
          builder: (context, _) {
            const listIndex = 1;
            // final index = scrollWizardController.page ?? -2;
            final index = -2;
            final pageOffset = index - listIndex;
            if (pageOffset > -1 && pageOffset < 1) {
              print("offset $pageOffset");
            }
            final f = pageOffset.abs();
            return ColorFiltered(
              colorFilter: ColorFilter.matrix([
                0.2126 * f + (1 - f), 0.7152 * f, 0.0722 * f, 0, 0, //
                0.2126 * f, 0.7152 * f + (1 - f), 0.0722 * f, 0, 0, //
                0.2126 * f, 0.7152 * f, 0.0722 * f + (1 - f), 0, 0, //
                0, 0, 0, 1 - (f / 2), 0, //
              ]),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveLayout.horizontalMargin,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Color(0xFFC6D5F6)),
                        foregroundColor:
                            MaterialStateProperty.all(Color(0xFF1A56DB)),
                      ),
                      child: Text('Skip'),
                      onPressed: () {
                        nextPage();
                      },
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      child: Icon(Icons.arrow_right_alt),
                      onPressed: () {
                        nextPage();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );

    // email
    final part3 = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EmailInput(),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveLayout.horizontalMargin,
            vertical: 16,
          ),
          child: Row(
            children: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xFFC6D5F6)),
                  foregroundColor: MaterialStateProperty.all(Color(0xFF1A56DB)),
                ),
                child: Text('Skip'),
                onPressed: () {
                  nextPage();
                },
              ),
              SizedBox(width: 8),
              ElevatedButton(
                child: Icon(Icons.arrow_right_alt),
                onPressed: () {
                  nextPage();
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              ),
            ],
          ),
        ),
      ],
    );

    // screenshot
    final part4 = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveLayout.horizontalMargin,
            vertical: 16,
          ),
          child: Text(
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
          child: Row(
            children: [
              ElevatedButton(
                child: Text('Yes'),
                onPressed: () {
                  nextPage();
                },
              ),
              SizedBox(width: 8),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xFFC6D5F6)),
                  foregroundColor: MaterialStateProperty.all(Color(0xFF1A56DB)),
                ),
                child: Text('Skip'),
                onPressed: () {
                  nextPage();
                },
              ),
            ],
          ),
        ),
      ],
    );

    // submit
    final part5 = Padding(
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
              Text(
                'Summary',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Message: ${context.wiredashModel.feedbackMessage}\n'
                '\n'
                'Labels: ${_selectedLabels.value.map((e) => e.name)}\n'
                '\n'
                'Email: ${context.wiredashModel.userEmail}\n'
                '\n'
                'Screenshots: 0\n'
                '\n'
                'AppVersion: TODO\n'
                'Browser Version: TODO\n'
                'Whatever is useful\n',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: StepForm(
        builder: (index) {
          // print("building index $index");
          if (index == 0) {
            return part1;
          }
          if (index == 1) {
            return part2;
          }
          if (index == 2) {
            return part3;
          }
          if (index == 3) {
            return part4;
          }
          if (index == 4) {
            return part5;
          }
          return null;
        },
      ),
    );

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: ScrollWizard(
        controller: scrollWizardController,
        scrollDirection: Axis.vertical,
        children: [
          SingleChildScrollView(child: part1),
          SingleChildScrollView(child: part2),
          SingleChildScrollView(child: part3),
          SingleChildScrollView(child: part4),
          ScrollBox(child: part5),
          ScrollBox(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveLayout.horizontalMargin,
                  vertical: 16,
                ),
                child: BigBlueButton(
                  icon: Icon(WiredashIcons.submit),
                  text: Text("Submit"),
                  onTap: context.wiredashModel.feedbackMessage == null
                      ? null
                      : () {
                          // TODO handle error
                          context.wiredashModel.submitFeedback();
                        },
                ),
              ),
            ),
          ),
        ],
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
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(brightness: Brightness.light),
      child: Scrollbar(
        interactive: false,
        controller: _controller,
        isAlwaysShown: true,
        child: SingleChildScrollView(
          controller: _controller,
          child: widget.child,
        ),
      ),
    );
  }
}

class _FeedbackMessageInput extends StatefulWidget {
  const _FeedbackMessageInput(
      {required this.controller, this.focusNode, Key? key})
      : super(key: key);

  final TextEditingController controller;
  final FocusNode? focusNode;

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
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            'Give us feedback',
            style: TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          maxLength: 2048,
          buildCounter: _getCounterText,
          style: const TextStyle(fontSize: 14),
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
        constraints: BoxConstraints(maxHeight: 41, minHeight: 41),
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
          alignment: Alignment.center,
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
