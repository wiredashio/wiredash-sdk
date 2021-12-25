import 'package:flutter/material.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/feedback/data/label.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';
import 'package:wiredash/src/feedback/ui/base_click_target.dart';
import 'package:wiredash/src/feedback/ui/feedback_flow.dart';

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
      child: SafeArea(
        child: ScrollBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Optional step',
                style: context.theme.captionTextStyle,
              ),
              const SizedBox(height: 12),
              Text(
                'Which label represents your type of feedback?',
                style: context.theme.titleTextStyle,
              ),
              // TODO replace with automatic scaled spacing from theme
              const SizedBox(height: 32),
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
            ],
          ),
        ),
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
        return Container(
          constraints: const BoxConstraints(maxHeight: 41, minHeight: 41),
          decoration: BoxDecoration(
            color: Color.lerp(
              context.theme.primaryBackgroundColor,
              context.theme.secondaryBackgroundColor,
              anims.hoveredAnim.value +
                  anims.pressedAnim.value +
                  anims.selectedAnim.value,
            ),
            borderRadius: BorderRadius.circular(10),
            border: selected
                ? Border.all(
                    width: 2,
                    // tint
                    color: context.theme.primaryColor,
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
                color: context.theme.primaryColor,
              ),
              child: Text(label.title),
            ),
          ),
        );
      },
    );
  }
}
