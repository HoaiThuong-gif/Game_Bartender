import 'dart:math';

import 'package:flutter/material.dart';

import 'gacha_colors.dart';

/// Six warm paper flecks; removed, rather than kept invisible, after 480 ms.
class ItemRevealParticles extends StatefulWidget {
  const ItemRevealParticles({super.key});
  @override
  State<ItemRevealParticles> createState() => _ItemRevealParticlesState();
}

class _ItemRevealParticlesState extends State<ItemRevealParticles>
    with SingleTickerProviderStateMixin {
  late final _animation =
      AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 480),
        )
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed && mounted) setState(() {});
        })
        ..forward();
  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_animation.isCompleted) return const SizedBox.shrink();
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (_, _) => CustomPaint(painter: _Flecks(_animation.value)),
        ),
      ),
    );
  }
}

class _Flecks extends CustomPainter {
  _Flecks(this.t);
  final double t;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GachaColors.brick.withValues(alpha: (1 - t) * .6)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 6; i++) {
      final angle = i * pi / 3 + .2;
      final radius = 25 + t * min(size.width, size.height) * .4;
      final position =
          size.center(Offset.zero) +
          Offset(cos(angle) * radius, sin(angle) * radius + t * t * 20);
      canvas.drawLine(
        position,
        position + Offset(cos(angle + t) * 6, sin(angle + t) * 6),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_Flecks oldDelegate) => oldDelegate.t != t;
}
