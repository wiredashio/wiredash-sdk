import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/feedback/data/label.dart';
import 'package:wiredash/src/feedback/ui/big_blue_button.dart';
import 'package:wiredash/src/feedback/ui/feedback_flow.dart';
import 'package:wiredash/src/feedback/ui/labeled_button.dart';
import 'package:wiredash/src/feedback/ui/larry_page_view.dart';

const _labels = [
  Label(id: 'bug', name: 'Bug'),
  Label(id: 'improvement', name: 'Improvement'),
  Label(id: 'praise', name: 'Praise 🎉'),
];

class Step2Labels extends StatefulWidget {
  const Step2Labels({Key? key}) : super(key: key);

  @override
  _Step2LabelsState createState() => _Step2LabelsState();
}

class _Step2LabelsState extends State<Step2Labels>
    with TickerProviderStateMixin {
  // TODO move into feedback model
  final ValueNotifier<Set<Label>> _selectedLabels = ValueNotifier({});

  @override
  Widget build(BuildContext context) {
    return StepPageScaffold(
      child: ValueListenableBuilder<Set<Label>>(
        valueListenable: _selectedLabels,
        builder: (context, selectedLabels, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What category fits best with your feedback?',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // TODO replace with automatic scaled spacing from theme
              const SizedBox(height: 32),
              _LabelRecommendations(
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
              const SizedBox(height: 32),
              Builder(
                builder: (context) {
                  return AnimatedSize(
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
                            onTap: () {
                              StepInformation.of(context)
                                  .pageView
                                  .moveToNextPage();
                            },
                            child: const Text('Skip'),
                          );
                        }

                        return BigBlueButton(
                          onTap: () {
                            StepInformation.of(context)
                                .pageView
                                .moveToNextPage();
                          },
                          // TODO don't use material icon
                          child: const Icon(Icons.arrow_right_alt),
                        );
                      }(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
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
