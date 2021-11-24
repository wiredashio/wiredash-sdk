import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';
import 'package:wiredash/src/feedback/ui/big_blue_button.dart';
import 'package:wiredash/src/feedback/ui/feedback_flow.dart';
import 'package:wiredash/src/feedback/ui/larry_page_view.dart';
import 'package:wiredash/src/feedback/ui/more_menu.dart';
import 'package:wiredash/src/responsive_layout.dart';

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
            onTap: () {
              Focus.maybeOf(context)?.unfocus();
              StepInformation.of(context).pageView.moveToNextPage();
            },
            child: const Icon(Icons.arrow_right_alt),
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
}
