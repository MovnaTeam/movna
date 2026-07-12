import 'package:flutter/material.dart';

/// A widget that rotates using given [rotationDegrees] but that always rotate
/// using the shortest rotation.
///
/// For example when rotating from 359 to 1 degrees, rotates 2 degrees forward
/// instead of 358 degrees backward like [AnimatedRotation] would do.
class ContinuouslyAnimatedRotation extends ImplicitlyAnimatedWidget {
  const ContinuouslyAnimatedRotation({
    required this.turns,
    required this.child,
    required super.duration,
    super.key,
    super.curve = Curves.linear,
    super.onEnd,
  });
  final double turns;
  final Widget child;

  @override
  AnimatedWidgetBaseState<ContinuouslyAnimatedRotation> createState() =>
      _ContinuouslyAnimatedRotationState();
}

class _ContinuouslyAnimatedRotationState
    extends AnimatedWidgetBaseState<ContinuouslyAnimatedRotation> {
  Tween<double>? _turnsTween;

  /// Unbounded: used to compute deltas
  double _rawTurns = 0.0;

  /// Normalized value shown to the user when not animating.
  double _displayTurns = 0.0;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    final targetTurns = widget.turns % 1.0;
    final delta = targetTurns - (_rawTurns % 1.0);
    final shortestDelta = delta - delta.roundToDouble();
    final nextTurns = _rawTurns + shortestDelta;

    _turnsTween = visitor(
      _turnsTween,
      nextTurns,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>;

    _rawTurns = nextTurns;
  }

  @override
  void didUpdateTweens() {
    super.didUpdateTweens();

    // When animation completes, snap _displayTurns to the normalized equivalent
    // in [0, 1)
    animation.addStatusListener(_onAnimationStatusChanged);
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      animation.removeStatusListener(_onAnimationStatusChanged);

      // Normalize only the displayed value, raw value keeps continuity
      _displayTurns = _rawTurns % 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final turns = !animation.isCompleted && !animation.isDismissed
        ? (_turnsTween?.evaluate(animation) ?? _displayTurns)
        : _displayTurns;
    return RotationTransition(
      turns: AlwaysStoppedAnimation(turns),
      child: widget.child,
    );
  }
}
