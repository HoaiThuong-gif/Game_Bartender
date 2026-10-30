import 'dart:ui';

class DetectedObject {
  const DetectedObject({
    required this.classId,
    required this.english,
    required this.vietnamese,
    required this.confidence,
    required this.box,
  });
  final int classId;
  final String english, vietnamese;
  final double confidence;

  /// Pixel coordinates in the upright image returned by the API, in xyxy order.
  final Rect box;
}

class DetectionResult {
  const DetectionResult({required this.imageSize, required this.objects});
  final Size imageSize;
  final List<DetectedObject> objects;

  factory DetectionResult.fromJson(Map<String, dynamic> data) {
    Never invalid() =>
        throw const FormatException('Invalid detection response');
    final image = data['image'];
    if (data['model'] != 'yolo26n' ||
        data['bbox_format'] != 'xyxy' ||
        image is! Map) {
      invalid();
    }
    final width = image['width'], height = image['height'];
    if (width is! int ||
        height is! int ||
        width <= 0 ||
        height <= 0 ||
        width * height > 16000000) {
      invalid();
    }
    final items = data['detections'];
    if (items is! List || items.length > 50) invalid();
    final objects = <DetectedObject>[];
    for (final item in items) {
      if (item is! Map) invalid();
      final id = item['class_id'],
          english = item['name_en'],
          vietnamese = item['name_vi'];
      final score = item['confidence'], values = item['bbox'];
      if (id is! int ||
          id < 0 ||
          id >= 80 ||
          english is! String ||
          english.isEmpty ||
          english.length > 80 ||
          vietnamese is! String ||
          vietnamese.isEmpty ||
          vietnamese.length > 80 ||
          score is! num ||
          !score.isFinite ||
          score < 0 ||
          score > 1 ||
          values is! List ||
          values.length != 4) {
        invalid();
      }
      if (values.any((value) => value is! num || !value.isFinite)) invalid();
      final box = Rect.fromLTRB(
        (values[0] as num).toDouble(),
        (values[1] as num).toDouble(),
        (values[2] as num).toDouble(),
        (values[3] as num).toDouble(),
      );
      if (box.left < 0 ||
          box.top < 0 ||
          box.right > width ||
          box.bottom > height ||
          box.width <= 0 ||
          box.height <= 0) {
        invalid();
      }
      objects.add(
        DetectedObject(
          classId: id,
          english: english,
          vietnamese: vietnamese,
          confidence: score.toDouble(),
          box: box,
        ),
      );
    }
    return DetectionResult(
      imageSize: Size(width.toDouble(), height.toDouble()),
      objects: objects,
    );
  }
}

class DetectionException implements Exception {
  const DetectionException(this.message);
  final String message;
  @override
  String toString() => message;
}
