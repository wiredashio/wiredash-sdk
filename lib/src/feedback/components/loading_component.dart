import 'package:flutter/material.dart';

/// Shown while feedback gets submitted
class LoadingComponent extends StatelessWidget {
  const LoadingComponent({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: const [
          SizedBox(height: 32),
          CircularProgressIndicator(),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}
