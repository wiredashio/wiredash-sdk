import 'package:flutter/material.dart';

/// Shown while feedback gets submitted
class LoadingComponent extends StatelessWidget {
  const LoadingComponent({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: CircularProgressIndicator(),
    );
  }
}
