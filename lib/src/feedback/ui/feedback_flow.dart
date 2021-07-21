import 'package:flutter/material.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/feedback/data/label.dart';
import 'package:wiredash/src/feedback/ui/more_menu.dart';
import 'package:wiredash/src/wiredash_backdrop.dart';
import 'package:wiredash/src/wiredash_provider.dart';

const _labels = [
  Label(id: 'aaa111', name: 'bug'),
  Label(id: 'bbb222', name: 'praise'),
  Label(id: 'ccc333', name: 'feature request'),
  Label(id: 'ddd444', name: 'something funny'),
  Label(id: 'eee555', name: 'overmorrow'),
];

class WiredashFeedbackFlow extends StatefulWidget {
  const WiredashFeedbackFlow({Key? key}) : super(key: key);

  @override
  State<WiredashFeedbackFlow> createState() => _WiredashFeedbackFlowState();
}

class _WiredashFeedbackFlowState extends State<WiredashFeedbackFlow>
    with TickerProviderStateMixin {
  late final TextEditingController _controller;
  final ValueNotifier<Set<Label>> _selectedLabels = ValueNotifier({});

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      minimum: const EdgeInsets.only(top: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.wiredashModel!.hide(),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'CLOSE',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(
              left: WiredashBackdrop.feedbackInputHorizontalPadding,
              right: WiredashBackdrop.feedbackInputHorizontalPadding,
              top: 20,
            ),
            child: Text(
              'You got feedback for us?',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextField(
            controller: _controller,
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
                left: WiredashBackdrop.feedbackInputHorizontalPadding,
                right: WiredashBackdrop.feedbackInputHorizontalPadding,
                top: 16,
              ),
            ),
          ),
          const SizedBox(height: 112),
          AnimatedBuilder(
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
                  child: () {
                    if (_controller.text.isEmpty) {
                      return const MoreMenu();
                    }
                    return ValueListenableBuilder<Set<Label>>(
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
                    );
                  }(),
                ),
              );
            },
          ),
        ],
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
    return Center(
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
