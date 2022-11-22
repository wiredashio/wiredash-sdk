import 'package:flutter/material.dart';
import 'package:wiredash/src/_ps.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';

class PsStep2Message extends StatefulWidget {
  const PsStep2Message({
    Key? key,
  }) : super(key: key);

  @override
  State<PsStep2Message> createState() => _PsStep2MessageState();
}

class _PsStep2MessageState extends State<PsStep2Message>
    with TickerProviderStateMixin {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: PsModelProvider.of(context, listen: false).message,
    )..addListener(() {
        final text = _controller.text;
        if (context.psModel.message != text) {
          context.psModel.message = text;
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
      indicator: const StepIndicator(
        currentStep: 2,
        total: 2,
        completed: false,
      ),
      title: Text(context.l10n.promoterScoreStep2MessageTitle),
      description: Text(
        context.l10n.promoterScoreStep2MessageDescription(
          context.psModel.score!.intValue,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // reduce size when it doesn't fit
          Flexible(
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.multiline,
              minLines: context.theme.windowSize.height > 400 ? 3 : 2,
              maxLines: 10,
              maxLength: 2048,
              buildCounter: _getCounterText,
              style: context.text.input.onBackground,
              cursorColor: context.theme.primaryColor,
              decoration: InputDecoration(
                filled: true,
                fillColor: context.theme.primaryBackgroundColor,
                hoverColor: Colors.transparent,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: context.theme.secondaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: context.theme.secondaryColor),
                ),
                errorBorder: InputBorder.none,
                hintText: context.l10n.promoterScoreStep2MessageHint,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                hintStyle: context.text.input.onSurface.copyWith(
                  color: context.text.input.onSurface.color?.withOpacity(0.6),
                ),
                errorStyle: context.text.inputError.textStyle.copyWith(
                  color: context.theme.errorColor,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TronButton(
                color: context.theme.secondaryColor,
                label: context.l10n.promoterScoreBackButton,
                onTap: () {
                  context
                      .findAncestorStateOfType<LarryPageViewState>()!
                      .moveToPreviousPage();
                },
              ),
              TronButton(
                label: context.l10n.promoterScoreSubmitButton,
                trailingIcon: Wirecons.check,
                onTap: () {
                  context.psModel.submit();
                },
              ),
            ],
          )
        ],
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

  Color getCounterColor() {
    if (remaining >= 150) {
      return Colors.green.shade400.withOpacity(0.8);
    } else if (remaining >= 50) {
      return Colors.orange.withOpacity(0.8);
    }
    // ignore: deprecated_member_use
    return Theme.of(context).errorColor;
    // replace with this when we drop support for 3.3.0-0.5.pre
    // return Theme.of(context).colorScheme.error;
  }

  return Text(
    remaining > 150 ? '' : remaining.toString(),
    style: context.text.inputError.textStyle.copyWith(color: getCounterColor()),
  );
}
