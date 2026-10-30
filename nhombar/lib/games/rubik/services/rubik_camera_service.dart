import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

/// Narrow interface also allows testing the scan flow without physical hardware.
abstract interface class ScanCamera {
  CameraController? get controller;
  double get previewAspect;
  Future<void> open();
  Future<Uint8List> capture();
  Future<void> close();
}

class RubikCameraService implements ScanCamera {
  CameraController? _controller;
  Future<void> _tail = Future<void>.value();
  @override
  CameraController? get controller => _controller;
  @override
  double get previewAspect => 1 / (_controller?.value.aspectRatio ?? (4 / 3));

  // Serialize native camera operations, including background/foreground changes.
  Future<T> _enqueue<T>(Future<T> Function() action) {
    final result = _tail.then((_) => action());
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  @override
  Future<void> open() => _enqueue(() async {
    if (_controller != null) return;
    final cameras = await availableCameras();
    final rear = cameras.where(
      (camera) => camera.lensDirection == CameraLensDirection.back,
    );
    if (rear.isEmpty) throw CameraException('NoRearCamera', 'No rear camera');
    final controller = CameraController(
      rear.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    try {
      await controller.initialize();
      await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
      await controller.setFlashMode(FlashMode.off);
      _controller = controller;
    } catch (_) {
      await controller.dispose();
      rethrow;
    }
  });

  @override
  Future<Uint8List> capture() => _enqueue(() async {
    final controller = _controller;
    if (controller == null) throw StateError('Camera is closed');
    final photo = await controller.takePicture();
    try {
      return await photo.readAsBytes();
    } finally {
      // Delete only this app-created temporary capture; never touch gallery files.
      try {
        await File(photo.path).delete();
      } on FileSystemException {
        /* OS may clean the cache first. */
      }
    }
  });

  @override
  Future<void> close() => _enqueue(() async {
    final controller = _controller;
    _controller = null;
    await controller?.dispose();
  });
}
