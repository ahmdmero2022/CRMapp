import 'package:flutter/material.dart';

/// Fades and slides its child in from a few pixels below on first build —
/// used to give list rows / stat cards a light staggered "just loaded" feel
/// instead of popping in instantly. Purely cosmetic; wrap [child] with a
/// per-index [delay] (see [staggerDelay]) for a cascading effect.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 10,
  });

  final Widget child;
  final Duration delay;
  final double offset;

  /// Caps the stagger so long lists don't take seconds to finish animating.
  static Duration staggerDelay(int index, {int stepMs = 25, int maxIndex = 12}) =>
      Duration(milliseconds: stepMs * (index > maxIndex ? maxIndex : index));

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final Animation<double> _fade =
      CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  late final Animation<Offset> _slide = Tween(
    begin: Offset(0, widget.offset / 100),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
