import 'dart:math' as math;

import 'package:flutter/material.dart';

const bartenderInk = Color(0xFF503421);
const bartenderCream = Color(0xFFFFF6E2);
const bartenderGreen = Color(0xFF347B65);

/// Static, procedural decoration: no downloaded assets or continuous ticker.
class BartenderBackdrop extends CustomPainter {
  const BartenderBackdrop();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF31584A), Color(0xFF193D34), Color(0xFF102C28)],
        ).createShader(Offset.zero & size),
    );
    final glow = Rect.fromCircle(
      center: Offset(size.width * .25, size.height * .25),
      radius: size.width * .55,
    );
    canvas.drawOval(
      glow,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x338FCB9D), Color(0x008FCB9D)],
        ).createShader(glow),
    );
    final line = Paint()
      ..color = const Color(0x096FE1A4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 10; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * .62 + i * 20,
            -100,
            size.width * .38,
            size.height + 220,
          ),
          const Radius.circular(180),
        ),
        line,
      );
    }
    for (var i = 0; i < 32; i++) {
      final x = (i * 173.7) % size.width, y = (i * 81.3) % size.height;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(i * .73);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(0, 0, 3, 8),
          const Radius.circular(1),
        ),
        Paint()
          ..color =
              (i % 3 == 0 ? const Color(0xFFD7BA76) : const Color(0xFF7BB997))
                  .withValues(alpha: .18),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant BartenderBackdrop oldDelegate) => false;
}

class BartenderTrophy extends StatelessWidget {
  const BartenderTrophy({super.key, this.width = 96});
  final double width;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: width * 1.14,
    child: const CustomPaint(painter: _TrophyPainter()),
  );
}

class _TrophyPainter extends CustomPainter {
  const _TrophyPainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 120, size.height / 138);
    canvas.drawCircle(
      const Offset(60, 62),
      52,
      Paint()..color = const Color(0x33E9BC57),
    );
    canvas.drawOval(
      const Rect.fromLTWH(24, 120, 76, 10),
      Paint()..color = const Color(0x226D471A),
    );
    final handle = Paint()
      ..color = const Color(0xFFCF8D2F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9;
    canvas.drawOval(const Rect.fromLTWH(10, 33, 32, 41), handle);
    canvas.drawOval(const Rect.fromLTWH(78, 33, 32, 41), handle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(53, 83, 14, 34),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFD99C39),
    );
    final cup = Path()
      ..moveTo(28, 27)
      ..lineTo(92, 27)
      ..lineTo(85, 69)
      ..quadraticBezierTo(80, 94, 60, 95)
      ..quadraticBezierTo(40, 94, 35, 69)
      ..close();
    canvas.drawPath(
      cup,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFE494), Color(0xFFE3A83F), Color(0xFFC08127)],
          stops: [0, .55, 1],
        ).createShader(const Rect.fromLTWH(28, 27, 64, 70)),
    );
    canvas.drawPath(
      Path()
        ..moveTo(38, 37)
        ..lineTo(42, 65)
        ..quadraticBezierTo(44, 78, 51, 82),
      Paint()
        ..color = const Color(0xFFFFECAA)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 5,
    );
    canvas.drawOval(
      const Rect.fromLTWH(27, 20, 66, 16),
      Paint()..color = const Color(0xFFFFEAB3),
    );
    canvas.drawOval(
      const Rect.fromLTWH(33, 24, 54, 9),
      Paint()..color = const Color(0xFFBE832A),
    );
    final star = Path();
    for (var i = 0; i < 10; i++) {
      final a = -math.pi / 2 + i * math.pi / 5, r = i.isEven ? 12.0 : 5.5;
      final p = Offset(64 + math.cos(a) * r, 59 + math.sin(a) * r);
      if (i == 0) {
        star.moveTo(p.dx, p.dy);
      } else {
        star.lineTo(p.dx, p.dy);
      }
    }
    star.close();
    canvas.drawPath(star, Paint()..color = const Color(0xFFFFF1BC));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(32, 111, 56, 15),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFFB97B29),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(28, 107, 64, 12),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFF0CA71),
    );
    canvas.drawPath(
      Path()
        ..moveTo(20, 96)
        ..lineTo(100, 87)
        ..lineTo(94, 100)
        ..lineTo(100, 111)
        ..lineTo(23, 119)
        ..lineTo(29, 107)
        ..close(),
      Paint()..color = const Color(0xFF3F846A),
    );
    canvas.drawLine(
      const Offset(38, 105),
      const Offset(82, 100),
      Paint()
        ..color = const Color(0xFFB2D2A8)
        ..strokeWidth = 2,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TrophyPainter oldDelegate) => false;
}
