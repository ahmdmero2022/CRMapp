import 'package:flutter/material.dart';

/// Wraps a card-like widget with a subtle hover "lift": on mouse-over
/// (web/desktop) it nudges the content up a couple pixels and adds a soft
/// primary-tinted shadow, giving otherwise-flat Material 3 cards a sense of
/// depth/interactivity without touching their own layout or ripple.
class HoverLift extends StatefulWidget {
  const HoverLift({
    super.key,
    required this.child,
    this.liftPx = 3,
    this.clickable = true,
  });

  final Widget child;
  final double liftPx;
  final bool clickable;

  @override
  State<HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<HoverLift> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: widget.clickable ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(
            0, _hovering ? -widget.liftPx : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: _hovering
              ? [
                  BoxShadow(
                    color: scheme.primary.withOpacity(0.16),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ]
              : const [],
        ),
        child: widget.child,
      ),
    );
  }
}
