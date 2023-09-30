import 'package:flutter/material.dart';
import 'package:movna/assets.dart';
import 'package:movna/presentation/widgets/svg_themed_widget.dart';

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
      // This stack relies on the fact that the two provided svg have the same
      // width, and a height adjusted so that their center align.
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          RotationTransition(
            turns: _animation,
            child: SvgThemedWidget(
              svgAsset: Assets.movnaIconBody,
              width: widget.width,
            ),
          ),
          RotationTransition(
            turns: ReverseAnimation(_animation),
            child: SvgThemedWidget(
              svgAsset: Assets.movnaIconHat,
              width: widget.width,
            ),
          ),
        ],
      ),
    );
  }
}
