import 'package:flutter/material.dart';

/// A widget built on top of [AnimatedSwitcher] that uses [SlideTransition] to
/// animate transition between an old and new [child].
class AlertTransitionWidget extends StatelessWidget {
  const AlertTransitionWidget({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(
        milliseconds: 200,
      ),
      reverseDuration: const Duration(
        milliseconds: 200,
      ),
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
      child: child,
    );
  }
}
