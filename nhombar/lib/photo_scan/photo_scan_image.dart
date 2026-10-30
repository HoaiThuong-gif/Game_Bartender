import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'photo_model_api.dart';

class PhotoScanImage {
  const PhotoScanImage(this.bytes, this.width, this.height);
  final Uint8List bytes;
  final int width, height;
}

/// Runs in an isolate. Upload AND preview use these same upright JPEG pixels.
PhotoScanImage preparePhotoScanImage(Uint8List bytes) {
  try {
    return _prepare(bytes);
  } on PhotoModelException {
    rethrow;
  } catch (_) {
    throw const PhotoModelException(
      'Ảnh chưa đọc được. Hãy chọn ảnh JPEG hoặc PNG khác.',
    );
  }
}

PhotoScanImage _prepare(Uint8List bytes) {
  if (bytes.isEmpty || bytes.length > 8 * 1024 * 1024) {
    throw const PhotoModelException('Hãy chọn ảnh nhỏ hơn 8 MB.');
  }
  final decoder = img.findDecoderForData(bytes);
  final info = decoder?.startDecode(bytes);
  if (info == null || info.width * info.height > 16000000) {
    throw const PhotoModelException(
      'Ảnh không đọc được hoặc quá lớn. Hãy chọn ảnh JPEG hoặc PNG khác.',
    );
  }
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw const PhotoModelException('Chưa đọc được ảnh. Hãy chọn ảnh khác.');
  }
  var upright = img.bakeOrientation(decoded);
  if (upright.width > 1600 || upright.height > 1600) {
    upright = upright.width >= upright.height
        ? img.copyResize(upright, width: 1600)
        : img.copyResize(upright, height: 1600);
  }
  upright.exif = img.ExifData();
  return PhotoScanImage(
    img.encodeJpg(upright, quality: 90),
    upright.width,
    upright.height,
  );
}
