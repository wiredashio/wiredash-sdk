import 'package:flutter/material.dart';
import 'package:wiredash/src/_wiredash_ui.dart';
import 'package:wiredash/src/feedback/_feedback.dart';

class Step2Labels extends StatefulWidget {
  const Step2Labels({Key? key}) : super(key: key);

  @override
  State<Step2Labels> createState() => _Step2LabelsState();
}

class _Step2LabelsState extends State<Step2Labels>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final feedbackModel = context.feedbackModel;
    final selectedLabels = feedbackModel.selectedLabels;
    return StepPageScaffold(
      indicator: const FeedbackProgressIndicator(
        flowStatus: FeedbackFlowStatus.labels,
      ),
      title: const Text(
        'Which label represents your feedback?',
      ),
      shortTitle: const Text('Labels'),
      description: const Text(
        'Selecting the correct category helps forwarding your feedback to the best person to resolve your issue',
      ),
      discardLabel: const Text('Discard Feedback'),
      discardConfirmLabel: const Text('Really? Discard!'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LabelRecommendations(
            labels: feedbackModel.labels,
            isLabelSelected: selectedLabels.contains,
            toggleSelection: (label) {
              setState(() {
                if (selectedLabels.contains(label)) {
                  feedbackModel.selectedLabels = selectedLabels.toList()
                    ..remove(label);
                } else {
                  feedbackModel.selectedLabels = selectedLabels.toList()
                    ..add(label);
                }
              });
            },
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TronButton(
                color: context.theme.secondaryColor,
                leadingIcon: Wirecons.arrow_left,
                label: 'Back',
                onTap: context.feedbackModel.goToPreviousStep,
              ),
              TronButton(
                label: 'Next',
                trailingIcon: Wirecons.arrow_right,
                onTap: context.feedbackModel.goToNextStep,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LabelRecommendations extends StatelessWidget {
  const _LabelRecommendations({
    required this.labels,
    required this.isLabelSelected,
    required this.toggleSelection,
    Key? key,
  }) : super(key: key);

  final List<Label> labels;
  final bool Function(Label) isLabelSelected;
  final void Function(Label) toggleSelection;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: labels.map((label) {
          return _Label(
            label: label,
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
    required this.selected,
    required this.toggleSelection,
    Key? key,
  }) : super(key: key);

  final Label label;
  final bool selected;
  final VoidCallback toggleSelection;

  @override
  Widget build(BuildContext context) {
    return AnimatedClickTarget(
      onTap: toggleSelection,
      selected: selected,
      builder: (context, state, anims) {
        return Opacity(
          opacity: state.selected ? 1.0 : 0.5,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 41, minHeight: 41),
            decoration: BoxDecoration(
                color: Color.lerp(
                  context.theme.primaryContainerColor,
                  context.theme.surfaceColor,
                  anims.pressedAnim.value + anims.selectedAnim.value,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 2,
                  // tint
                  color: context.theme.primaryColor.withOpacity(() {
                    if (state.pressed || state.selected) {
                      return 1.0;
                    }
                    if (state.hovered) {
                      return 0.25;
                    }

                    return 0.0;
                  }()),
                )),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Align(
              widthFactor: 1,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 225),
                curve: Curves.ease,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color.lerp(
                    context.theme.textOnPrimaryContainerColor,
                    context.theme.primaryColor,
                    anims.selectedAnim.value,
                  ),
                ),
                child: Text(label.title),
              ),
            ),
          ),
        );
      },
    );
  }
}
