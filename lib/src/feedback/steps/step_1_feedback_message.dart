import 'package:flutter/material.dart';
import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';

class Step1FeedbackMessage extends StatefulWidget {
  const Step1FeedbackMessage({super.key});

  @override
  State<Step1FeedbackMessage> createState() => _Step1FeedbackMessageState();
}

class _Step1FeedbackMessageState extends State<Step1FeedbackMessage>
    with TickerProviderStateMixin {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.readFeedbackModel.feedbackMessage,
    )..addListener(() {
        final text = _controller.text;
        if (context.watchFeedbackModel.feedbackMessage != text) {
          context.watchFeedbackModel.feedbackMessage = text;
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
      indicator: const FeedbackProgressIndicator(
        flowStatus: FeedbackFlowStatus.message,
      ),
      title: Text(context.l10n.feedbackStep1MessageTitle),
      breadcrumbTitle: Text(context.l10n.feedbackStep1MessageBreadcrumbTitle),
      description: Text(context.l10n.feedbackStep1MessageDescription),
      discardLabel: Text(context.l10n.feedbackDiscardButton),
      discardConfirmLabel: Text(context.l10n.feedbackDiscardConfirmButton),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // reduce size when it doesn't fit
          Flexible(
            child: TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.l10n.feedbackStep1MessageErrorMissingMessage;
                }
                return null;
              },
              controller: _controller,
              keyboardType: TextInputType.multiline,
              minLines: context.theme.windowSize.height > 400 ? 3 : 2,
              maxLines: 10,
              maxLength: 2048,
              buildCounter: _getCounterText,
              style: context.text.input.onSurface,
              cursorColor: context.theme.primaryColor,
              decoration: InputDecoration(
                filled: true,
                fillColor: context.theme.surfaceColor,
                hoverColor: Colors.transparent,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: context.theme.primaryContainerColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: context.theme.primaryColor),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: context.theme.errorColor,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: context.theme.errorColor.lighten(),
                  ),
                ),
                hintText: context.l10n.feedbackStep1MessageHint,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                hintStyle: context.text.input.onSurface.copyWith(
                  // ignore: deprecated_member_use
                  color: context.text.input.onSurface.color?.withOpacity(0.6),
                ),
                errorStyle: context.text.inputError.textStyle.copyWith(
                  color: context.theme.errorColor,
                ),
                errorMaxLines: 3,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: TronButton(
                  color: context.theme.secondaryColor,
                  label: context.l10n.feedbackCloseButton,
                  onTap: context.wiredashModel.hide,
                ),
              ),
              Flexible(
                child: TronButton(
                  label: context.l10n.feedbackNextButton,
                  trailingIcon: Wirecons.arrow_right,
                  onTap: context.readFeedbackModel.feedbackMessage == null
                      ? context.readFeedbackModel.validateForm
                      : context.readFeedbackModel.goToNextStep,
                ),
              ),
            ],
          ),
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
      // ignore: deprecated_member_use
      return Colors.green.shade400.withOpacity(0.8);
    } else if (remaining >= 50) {
      // ignore: deprecated_member_use
      return Colors.orange.withOpacity(0.8);
    }
    return context.theme.errorColor;
  }

  return Text(
    remaining > 150 ? '' : remaining.toString(),
    style: context.text.inputError.textStyle.copyWith(color: getCounterColor()),
  );
}
