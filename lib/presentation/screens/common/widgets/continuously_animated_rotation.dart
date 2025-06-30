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
  double _currentTurns = 0.0;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    final newTurns = _normalizeAndComputeTargetTurns(widget.turns);
    _turnsTween = visitor(
      _turnsTween,
      newTurns,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>;
  }

  /// Normalize delta into shortest arc [-0.5, 0.5] and accumulate it
  double _normalizeAndComputeTargetTurns(double newTurns) {
    final delta = newTurns - _currentTurns;
    final shortestDelta = delta - delta.roundToDouble();
    final targetTurns = _currentTurns + shortestDelta;
    _currentTurns = targetTurns;
    return targetTurns;
  }

  @override
  Widget build(BuildContext context) {
    final animatedTurns = _turnsTween?.evaluate(animation) ?? _currentTurns;
    return RotationTransition(
      turns: AlwaysStoppedAnimation(animatedTurns),
      child: widget.child,
    );
  }
}
