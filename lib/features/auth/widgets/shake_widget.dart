import 'package:flutter/material.dart';

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final double shakeOffset;
  final Duration duration;

  const ShakeWidget({
    super.key,
    required this.child,
    this.shakeOffset = 6.0,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  ShakeWidgetState createState() => ShakeWidgetState();
}

class ShakeWidgetState extends State<ShakeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -widget.shakeOffset), weight: 1),
      TweenSequenceItem(
        tween: Tween(begin: -widget.shakeOffset, end: widget.shakeOffset),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: widget.shakeOffset, end: -widget.shakeOffset * 0.6),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -widget.shakeOffset * 0.6, end: widget.shakeOffset * 0.6),
        weight: 2,
      ),
      TweenSequenceItem(tween: Tween(begin: widget.shakeOffset * 0.6, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void shake() {
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(offset: Offset(_animation.value, 0), child: child);
      },
      child: widget.child,
    );
  }
}
