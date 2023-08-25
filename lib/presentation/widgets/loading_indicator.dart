import 'package:flutter/material.dart';

/// The loading indicator used by the application
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: use movna indicator https://github.com/MovnaTeam/movna/issues/24
    return const CircularProgressIndicator();
  }
}
