import 'package:flutter/material.dart';

/// A widget than acts just like an [IndexedStack], keeping its children widgets
/// alive, but also animating between them with a horizontal slide animation.
class SlideIndexedStack extends StatefulWidget {
  const SlideIndexedStack({
    required this.index,
    required this.children,
    required this.duration,
    super.key,
  });

  final int index;
  final List<Widget> children;
  final Duration duration;

  @override
  State<SlideIndexedStack> createState() => _SlideIndexedStackState();
}

class _SlideIndexedStackState extends State<SlideIndexedStack>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _inAnimation;
  late Animation<Offset> _outAnimation;

  int _currentIndex = -1;
  int? _previousIndex;
  bool _slideLeft = true;

  @override
  void didUpdateWidget(SlideIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.index != oldWidget.index) {
      setState(() {
        _previousIndex = _currentIndex;
        _slideLeft = widget.index > _currentIndex;
        _currentIndex = widget.index;

        _inAnimation = Tween<Offset>(
          begin: Offset(_slideLeft ? 1.0 : -1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

        _outAnimation = Tween<Offset>(
          begin: Offset.zero,
          end: Offset(_slideLeft ? -1.0 : 1.0, 0.0),
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

        _controller.forward(from: 0.0);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _inAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
        .animate(_controller);
    _outAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
        .animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_previousIndex != null)
          SlideTransition(
            position: _outAnimation,
            child: IndexedStack(
              index: _previousIndex,
              children: widget.children,
            ),
          ),
        SlideTransition(
          position: _inAnimation,
          child: IndexedStack(
            index: _currentIndex,
            children: widget.children,
          ),
        ),
      ],
    );
  }
}
