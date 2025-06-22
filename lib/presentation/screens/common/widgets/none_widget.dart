import 'package:flutter/material.dart';

/// A widget that displays nothing and takes up no place.
class NoneWidget extends StatelessWidget {
  const NoneWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
