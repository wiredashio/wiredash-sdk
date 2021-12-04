import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';
import 'package:wiredash/src/feedback/ui/big_blue_button.dart';
import 'package:wiredash/src/feedback/ui/feedback_flow.dart';
import 'package:wiredash/src/feedback/ui/larry_page_view.dart';

class Step1FeedbackMessage extends StatefulWidget {
  const Step1FeedbackMessage({Key? key}) : super(key: key);

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
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // reduce size when it doesn't fit
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Give us feedback',
                      style: context.theme.titleStyle,
                    ),
                  ),
                  Flexible(
                    child: ScrollBox(
                      child: TextField(
                        controller: _controller,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        maxLength: 2048,
                        buildCounter: _getCounterText,
                        minLines: 3,
                        style: context.theme.bodyStyle,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          hintText:
                              'e.g. there’s a bug when ... or I really enjoy ...',
                          contentPadding: EdgeInsets.only(top: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                    child: Container(
                      key: ValueKey(_controller.text.isEmpty),
                      child: () {
                        return BigBlueButton(
                          onTap: () {
                            StepInformation.of(context)
                                .pageView
                                .moveToNextPage();
                          },
                          child: const Text('next'),
                        );
                      }(),
                    ),
                  ),
                );
              },
            ),
          ],
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
