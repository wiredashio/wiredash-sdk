import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/wiredash_provider.dart';

/// Horizontal menu offering more Wiredash services besides feedback
class MoreMenu extends StatelessWidget {
  const MoreMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        alignment: Alignment.center,
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          // wiredash blue / 100
          color: const Color(0xFFE8EEFB),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Wrap(
          runAlignment: WrapAlignment.spaceEvenly,
          alignment: WrapAlignment.spaceEvenly,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          children: [
            _Link(
              icon: const Icon(Icons.list_alt_outlined),
              label: const Text('Change Log'),
              onTap: () {
                context.wiredashModel.enterCaptureMode();
              },
            ),
            const _Link(
              icon: Icon(Icons.checklist_outlined),
              label: Text('Surveys'),
            ),
            const _Link(
              icon: Icon(Icons.question_answer_outlined),
              label: Text('FAQs'),
            ),
          ].toList(),
        ),
      ),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({
    required this.icon,
    required this.label,
    Key? key,
    this.onTap,
  }) : super(key: key);

  final Widget icon;
  final Widget label;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
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
      ),
    );
  }
}
