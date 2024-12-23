import 'package:flutter/material.dart';
import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';

class Step2Labels extends StatefulWidget {
  const Step2Labels({super.key});

  @override
  State<Step2Labels> createState() => _Step2LabelsState();
}

class _Step2LabelsState extends State<Step2Labels>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final feedbackModel = context.watchFeedbackModel;
    final selectedLabels = feedbackModel.selectedLabels;
    return StepPageScaffold(
      indicator: const FeedbackProgressIndicator(
        flowStatus: FeedbackFlowStatus.labels,
      ),
      title: Text(context.l10n.feedbackStep2LabelsTitle),
      breadcrumbTitle: Text(context.l10n.feedbackStep2LabelsBreadcrumbTitle),
      description: Text(context.l10n.feedbackStep2LabelsDescription),
      discardLabel: Text(context.l10n.feedbackDiscardButton),
      discardConfirmLabel: Text(context.l10n.feedbackDiscardConfirmButton),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LabelRecommendations(
            labels: feedbackModel.labels
                .where((label) => label.hidden != true)
                .toList(),
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
                label: context.l10n.feedbackBackButton,
                onTap: context.readFeedbackModel.goToPreviousStep,
              ),
              TronButton(
                label: context.l10n.feedbackNextButton,
                trailingIcon: Wirecons.arrow_right,
                onTap: context.readFeedbackModel.goToNextStep,
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
  });

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
  });

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
          child: AnimatedContainer(
            constraints: const BoxConstraints(maxHeight: 41, minHeight: 41),
            decoration: BoxDecoration(
              color: () {
                if (state.selected) {
                  return context.theme.primaryContainerColor;
                }
                return context.theme.secondaryContainerColor;
              }(),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                width: 2,
                // tint
                // ignore: deprecated_member_use
                color: context.theme.textOnPrimaryContainerColor.withOpacity(
                  () {
                    if (state.pressed || state.selected) {
                      return 1.0;
                    }
                    if (state.hovered) {
                      return 0.25;
                    }

                    return 0.0;
                  }(),
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            duration: const Duration(milliseconds: 225),
            child: Align(
              widthFactor: 1,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 225),
                curve: Curves.ease,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Color.lerp(
                    context.theme.textOnSecondaryContainerColor,
                    context.theme.textOnPrimaryContainerColor,
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
