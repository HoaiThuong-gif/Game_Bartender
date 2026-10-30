import 'package:flutter/material.dart';

import 'detection_image.dart';
import 'detection_models.dart';

const detectionColors = [
  Colors.deepOrange,
  Colors.blue,
  Colors.green,
  Colors.purple,
];

/// Shared BoxFit.contain math keeps boxes aligned on portrait/landscape screens.
Rect detectionImageRect(Size imageSize, Size viewport) {
  final fitted = applyBoxFit(BoxFit.contain, imageSize, viewport);
  return Alignment.center.inscribe(fitted.destination, Offset.zero & viewport);
}

Rect projectDetectionBox(Rect box, Size imageSize, Size viewport) {
  final image = detectionImageRect(imageSize, viewport);
  return Rect.fromLTRB(
    image.left + box.left / imageSize.width * image.width,
    image.top + box.top / imageSize.height * image.height,
    image.left + box.right / imageSize.width * image.width,
    image.top + box.bottom / imageSize.height * image.height,
  );
}

class DetectionPreview extends StatelessWidget {
  const DetectionPreview({
    super.key,
    required this.image,
    this.result,
    this.height = 320,
  });
  final double height;
  final DetectionImage image;
  final DetectionResult? result;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(image.bytes, fit: BoxFit.contain, gaplessPlayback: true),
        if (result != null)
          IgnorePointer(
            child: CustomPaint(painter: _DetectionPainter(result!)),
          ),
      ],
    ),
  );
}

class _DetectionPainter extends CustomPainter {
  const _DetectionPainter(this.result);
  final DetectionResult result;
  @override
  void paint(Canvas canvas, Size size) {
    final image = detectionImageRect(result.imageSize, size);
    canvas.save();
    canvas.clipRect(image);
    for (var i = 0; i < result.objects.length; i++) {
      final object = result.objects[i];
      final color = detectionColors[i % detectionColors.length];
      final box = projectDetectionBox(object.box, result.imageSize, size);
      canvas.drawRect(
        box,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      final text = TextPainter(
        text: TextSpan(
          text:
              '${i + 1}. ${object.vietnamese} ${(object.confidence * 100).round()}%',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 2,
      )..layout(maxWidth: (image.width - 8).clamp(1, double.infinity));
      final x = box.left.clamp(
        image.left,
        (image.right - text.width - 8).clamp(image.left, image.right),
      );
      final y = (box.top - text.height - 8).clamp(
        image.top,
        (image.bottom - text.height - 8).clamp(image.top, image.bottom),
      );
      canvas.drawRect(
        Rect.fromLTWH(x, y, text.width + 8, text.height + 8),
        Paint()..color = color,
      );
      text.paint(canvas, Offset(x + 4, y + 4));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DetectionPainter oldDelegate) =>
      result != oldDelegate.result;
}
