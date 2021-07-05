import 'package:flutter/material.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/wiredash_backdrop.dart';
import 'package:wiredash/src/wiredash_provider.dart';

class WiredashFeedbackFlow extends StatefulWidget {
  const WiredashFeedbackFlow({Key? key}) : super(key: key);

  @override
  State<WiredashFeedbackFlow> createState() => _WiredashFeedbackFlowState();
}

class _WiredashFeedbackFlowState extends State<WiredashFeedbackFlow> {
  final TextEditingController _controller = TextEditingController();

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
              return _controller.text.isEmpty
                  ? const _Links()
                  : const _Labels();
            },
          ),
        ],
      ),
    );
  }
}

class _Links extends StatelessWidget {
  const _Links({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(
        horizontal: WiredashBackdrop.feedbackInputHorizontalPadding,
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        // wiredash blue / 100
        color: const Color(0xFFE8EEFB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Wrap(
        runAlignment: WrapAlignment.spaceEvenly,
        alignment: WrapAlignment.spaceEvenly,
        spacing: 16,
        children: const [
          _Link(
            icon: Icon(Icons.hourglass_bottom_outlined),
            label: Text('Future Lab'),
          ),
          _Link(
            icon: Icon(Icons.task),
            label: Text('Change Log'),
          ),
          _Link(
            icon: Icon(Icons.search),
            label: Text('FAQs'),
          ),
          _Link(
            icon: Icon(Icons.hourglass_bottom_outlined),
            label: Text('Future Lab'),
          ),
          _Link(
            icon: Icon(Icons.task),
            label: Text('Change Log'),
          ),
          _Link(
            icon: Icon(Icons.search),
            label: Text('FAQs'),
          ),
        ].toList(),
      ),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({required this.icon, required this.label, Key? key})
      : super(key: key);

  final Widget icon;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        children: [
          IconTheme.merge(
            data: const IconThemeData(
              size: 24,
              // tint
              color: Color(0xFF1A56DB),
            ),
            child: icon,
          ),
          const SizedBox(height: 8),
          DefaultTextStyle.merge(
            style: const TextStyle(
              // tint
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF1A56DB),
            ),
            child: label,
          ),
        ],
      ),
    );
  }
}

class _Labels extends StatelessWidget {
  const _Labels({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: const [
          _Label(child: Text('bug')),
          _Label(child: Text('praise')),
          _Label(child: Text('feature request')),
          _Label(child: Text('something funny')),
          _Label(child: Text('overmorrow')),
        ],
      ),
    );
  }
}

class _Label extends StatefulWidget {
  const _Label({required this.child, Key? key}) : super(key: key);
  final Widget child;

  @override
  __LabelState createState() => __LabelState();
}

class __LabelState extends State<_Label> {
  bool _selected = false;

  void _toggle() {
    setState(() {
      _selected = !_selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        decoration: BoxDecoration(
          color: _selected ? Colors.white : const Color(0xFFE8EEFB),
          borderRadius: BorderRadius.circular(10),
          border: _selected
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
        child: DefaultTextStyle.merge(
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: _selected
                ? const Color(0xFF1A56DB) // tint
                : const Color(0xFFA0AEC0), // gray / 500
          ),
          child: widget.child,
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
