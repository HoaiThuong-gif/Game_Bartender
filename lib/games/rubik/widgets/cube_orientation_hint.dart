import 'package:flutter/material.dart';

import '../models/rubik_face.dart';
import 'rubik_palette.dart';

/// Static orientation diagram. Independent of the existing Three.js preview.
class CubeOrientationHint extends StatelessWidget {
  const CubeOrientationHint({super.key, required this.face});
  final RubikFace face;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        SizedBox(
          width: 64,
          height: 68,
          child: CustomPaint(
            painter: _OrientationPainter(
              face.centerColor.paint,
              face.topFace.centerColor.paint,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Tâm ${face.centerColor.label.toLowerCase()} hướng về bạn\n'
            'Tâm ${face.topFace.centerColor.label.toLowerCase()} ở phía trên',
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF334155),
            ),
          ),
        ),
      ],
    ),
  );
}

class _OrientationPainter extends CustomPainter {
  const _OrientationPainter(this.front, this.top);
  final Color front;
  final Color top;

  @override
  void paint(Canvas canvas, Size size) {
    final frontRect = Rect.fromLTWH(5, 22, size.width - 10, size.height - 27);
    final topPath = Path()
      ..moveTo(5, 22)
      ..lineTo(14, 5)
      ..lineTo(size.width - 14, 5)
      ..lineTo(size.width - 5, 22)
      ..close();
    final stroke = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(topPath, Paint()..color = top);
    canvas.drawPath(topPath, stroke);
    canvas.drawRect(frontRect, Paint()..color = front);
    canvas.drawRect(frontRect, stroke);
    for (var i = 1; i < 3; i++) {
      final x = frontRect.left + frontRect.width * i / 3;
      final y = frontRect.top + frontRect.height * i / 3;
      canvas.drawLine(
        Offset(x, frontRect.top),
        Offset(x, frontRect.bottom),
        stroke,
      );
      canvas.drawLine(
        Offset(frontRect.left, y),
        Offset(frontRect.right, y),
        stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_OrientationPainter oldDelegate) =>
      oldDelegate.front != front || oldDelegate.top != top;
}
