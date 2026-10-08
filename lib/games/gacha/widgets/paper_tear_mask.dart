import 'dart:math';

import 'package:flutter/material.dart';

/// Bounded frontier: 25 samples, stable noise, no gesture history/saveLayer.
class PaperTearGeometry {
  const PaperTearGeometry({
    required this.progress,
    required this.fromLeft,
    this.fingerY = .5,
    this.simple = false,
    this.frontier,
  });
  final double progress;
  final bool fromLeft;
  final double fingerY;
  final bool simple;
  final List<double>? frontier;
  List<Offset> edge(Size size) {
    final p = progress.clamp(0.0, 1.0);
    return List.generate(25, (i) {
      final y = i / 24;
      final noise = sin(i * 2.37) * .012 + sin(i * 5.13) * .008;
      final localLift = simple ? 0.0 : .035 * exp(-pow((y - fingerY) / .18, 2));
      final x = p == 0 || p == 1
          ? p
          : frontier?[i] ?? (p + noise + localLift).clamp(0.0, 1.0);
      return Offset((fromLeft ? x : 1 - x) * size.width, y * size.height);
    }, growable: false);
  }

  Path cover(Size size) {
    if (progress >= 1) return Path();
    final points = edge(size);
    final outside = fromLeft ? size.width : 0.0;
    final path = Path()
      ..moveTo(outside, 0)
      ..lineTo(points.first.dx, 0);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    return path
      ..lineTo(outside, size.height)
      ..close();
  }
}

class PaperTearClipper extends CustomClipper<Path> {
  const PaperTearClipper(this.geometry);
  final PaperTearGeometry geometry;
  @override
  Path getClip(Size size) => geometry.cover(size);
  @override
  bool shouldReclip(PaperTearClipper old) =>
      old.geometry.progress != geometry.progress ||
      old.geometry.fingerY != geometry.fingerY ||
      old.geometry.fromLeft != geometry.fromLeft ||
      old.geometry.simple != geometry.simple ||
      old.geometry.frontier != geometry.frontier;
}

/// Tiny ink shadow + lifted fibre highlight; no blur or full-sheet transform.
class PaperTearEdgePainter extends CustomPainter {
  const PaperTearEdgePainter(this.geometry);
  final PaperTearGeometry geometry;
  @override
  void paint(Canvas canvas, Size size) {
    if (geometry.progress <= 0 || geometry.progress >= 1) return;
    // The sprite has transparent top/bottom margins; don't draw fibres on air.
    final points = geometry
        .edge(size)
        .where(
          (point) =>
              point.dy >= size.height * .19 && point.dy <= size.height * .86,
        )
        .toList(growable: false);
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    final direction = geometry.fromLeft ? 1.0 : -1.0;
    canvas.drawPath(
      path.shift(Offset(direction * 2, 1)),
      Paint()
        ..color = const Color(0x504A2D19)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFEBC7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawPath(
      path.shift(Offset(direction * 2, 0)),
      Paint()
        ..color = const Color(0xFFBA9064)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(PaperTearEdgePainter old) =>
      PaperTearClipper(geometry).shouldReclip(PaperTearClipper(old.geometry));
}
