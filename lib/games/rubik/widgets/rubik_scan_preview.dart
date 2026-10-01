import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../services/rubik_color_detector.dart';

class RubikScanPreview extends StatelessWidget {
  const RubikScanPreview({
    super.key,
    required this.controller,
    required this.aspect,
  });
  final CameraController? controller;
  final double aspect;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: aspect,
    child: Stack(
      fit: StackFit.expand,
      children: [
        if (controller != null)
          CameraPreview(controller!)
        else
          const ColoredBox(color: Colors.black),
        const IgnorePointer(child: CustomPaint(painter: _ScanOverlay())),
      ],
    ),
  );
}

class _ScanOverlay extends CustomPainter {
  const _ScanOverlay();
  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide * scanFrameFraction;
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: side,
      height: side,
    );
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()..addRect(rect),
      ),
      Paint()..color = Colors.black45,
    );
    final pen = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, pen);
    for (var i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(rect.left + side * i / 3, rect.top),
        Offset(rect.left + side * i / 3, rect.bottom),
        pen,
      );
      canvas.drawLine(
        Offset(rect.left, rect.top + side * i / 3),
        Offset(rect.right, rect.top + side * i / 3),
        pen,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScanOverlay oldDelegate) => false;
}
