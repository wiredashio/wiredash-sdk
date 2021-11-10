import 'package:flutter/material.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';
import 'package:wiredash/src/responsive_layout.dart';

class EmailInput extends StatefulWidget {
  const EmailInput({
    this.focusNode,
    Key? key,
  }) : super(key: key);

  final FocusNode? focusNode;

  @override
  _EmailInputState createState() => _EmailInputState();
}

class _EmailInputState extends State<EmailInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: FeedbackModelProvider.of(context, listen: false).userEmail,
    )..addListener(() {
        final text = _controller.text;
        if (context.feedbackModel.userEmail != text) {
          context.feedbackModel.userEmail = text;
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
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveLayout.horizontalMargin,
        vertical: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              'Email',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.emailAddress,
            focusNode: widget.focusNode,
            style: const TextStyle(fontSize: 14),
            decoration: const InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              hintText: 'mail@wiredash.io',
              contentPadding: EdgeInsets.only(top: 16),
            ),
          ),
        ],
      ),
    );
  }
}
