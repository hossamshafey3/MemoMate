import 'package:flutter/material.dart';

class GlowingBadge extends StatefulWidget {
  final Widget child;
  final bool showBadge;

  const GlowingBadge({
    super.key,
    required this.child,
    required this.showBadge,
  });

  @override
  State<GlowingBadge> createState() => _GlowingBadgeState();
}

class _GlowingBadgeState extends State<GlowingBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.showBadge) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant GlowingBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showBadge && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.showBadge && _pulseController.isAnimating) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showBadge) return widget.child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        Positioned(
          top: -2,
          right: -2,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30), // Sleek iOS red
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF3B30).withValues(alpha: 0.8 * _pulseController.value),
                      blurRadius: 8 * _pulseController.value + 2,
                      spreadRadius: 3 * _pulseController.value + 0.5,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
