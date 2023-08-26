import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:movna/assets.dart';

/// The loading indicator used by the application
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const IconSpinner();
  }
}

class IconSpinner extends StatefulWidget {
  const IconSpinner({
    super.key,
    this.width = 40,
    this.duration = const Duration(seconds: 3),
    this.curve = Curves.elasticInOut,
  });

  /// The width of the spinner, height is deduced from width.
  final double width;

  /// The duration of the animation.
  final Duration duration;

  /// The type of curve to be used.
  final Curve curve;

  @override
  State<IconSpinner> createState() => _IconSpinnerState();
}

/// [AnimationController]s can be created with `vsync: this` because of
/// [TickerProviderStateMixin].
class _IconSpinnerState extends State<IconSpinner>
    with TickerProviderStateMixin {
  _IconSpinnerState();

  late final AnimationController _controller = AnimationController(
    duration: widget.duration,
    vsync: this,
  )..repeat(reverse: false);

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: widget.curve,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          RotationTransition(
            turns: _animation,
            child: SvgPicture.asset(
              Assets.movnaIconBody,
              width: widget.width,
            ),
          ),
          RotationTransition(
            turns: ReverseAnimation(_animation),
            child: SvgPicture.asset(
              Assets.movnaIconHat,
              width: widget.width,
            ),
          ),
        ],
      ),
    );
  }
}