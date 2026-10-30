import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'detection_api.dart';
import 'detection_image.dart';
import 'detection_models.dart';
import 'detection_preview.dart';

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({super.key, this.detector, this.pickImage});
  final ObjectDetector? detector;
  final Future<DetectionImage?> Function()? pickImage;
  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen>
    with WidgetsBindingObserver {
  late final ObjectDetector _detector = widget.detector ?? DetectionApi();
  CameraController? _camera;
  DetectionImage? _photo;
  DetectionResult? _result;
  String? _error;
  bool _busy = false, _foreground = true;
  int _cameraGeneration = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (!_foreground && _camera != null) {
      final camera = _camera;
      _cameraGeneration++;
      setState(() => _camera = null);
      camera?.dispose();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraGeneration++;
    _camera?.dispose();
    _detector.close();
    super.dispose();
  }

  Future<void> _releaseCamera() async {
    _cameraGeneration++;
    final camera = _camera;
    if (mounted) setState(() => _camera = null);
    await camera?.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (error) {
      debugPrint(
        '[Detection] ${error is CameraException ? error.code : error.runtimeType}',
      );
      if (mounted) {
        setState(
          () => _error = error is DetectionException
              ? error.message
              : error is CameraException
              ? 'Chưa mở được máy ảnh. Hãy cấp quyền camera trong Cài đặt rồi thử lại.'
              : 'Chưa đọc được ảnh. Hãy thử lại hoặc chọn ảnh khác.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openCamera() => _run(() async {
    await _releaseCamera();
    final generation = _cameraGeneration;
    final cameras = await availableCameras();
    if (!mounted || !_foreground || generation != _cameraGeneration) return;
    if (cameras.isEmpty) {
      throw const DetectionException(
        'Chưa tìm thấy máy ảnh. Bạn có thể chọn ảnh từ thư viện.',
      );
    }
    final back =
        cameras
            .where((camera) => camera.lensDirection == CameraLensDirection.back)
            .firstOrNull ??
        cameras.first;
    final camera = CameraController(
      back,
      ResolutionPreset.high,
      enableAudio: false,
    );
    try {
      await camera.initialize();
    } catch (_) {
      await camera.dispose();
      rethrow;
    }
    if (!mounted || !_foreground || generation != _cameraGeneration) {
      await camera.dispose();
      return;
    }
    setState(() {
      _camera = camera;
      _photo = null;
      _result = null;
    });
  });

  Future<DetectionImage> _prepare(XFile file) async {
    if (await file.length() > 8 * 1024 * 1024) {
      throw const DetectionException('Hãy chọn ảnh nhỏ hơn 8 MB.');
    }
    return compute(prepareDetectionImage, await file.readAsBytes());
  }

  Future<void> _recognize(DetectionImage image) async {
    if (!mounted) return;
    setState(() {
      _photo = image;
      _result = null;
    });
    final result = await _detector.detect(image);
    if (mounted) setState(() => _result = result);
  }

  Future<void> _capture() => _run(() async {
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized) return;
    final file = await camera.takePicture();
    DetectionImage image;
    try {
      image = await _prepare(file);
    } finally {
      // Only delete the temporary photo created by OUR camera, never a gallery source.
      try {
        await File(file.path).delete();
      } catch (_) {}
    }
    await _releaseCamera();
    await _recognize(image);
  });

  Future<void> _gallery() => _run(() async {
    await _releaseCamera();
    DetectionImage? image;
    if (widget.pickImage != null) {
      image = await widget.pickImage!();
    } else {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 90,
        requestFullMetadata: false,
      );
      if (file != null) image = await _prepare(file);
    }
    if (image != null) await _recognize(image);
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Nhận diện đồ vật')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: _camera != null
                  ? SizedBox(
                      height: (MediaQuery.sizeOf(context).height * .42).clamp(
                        180,
                        420,
                      ),
                      child: Center(child: CameraPreview(_camera!)),
                    )
                  : _photo != null
                  ? DetectionPreview(
                      image: _photo!,
                      result: _result,
                      height: (MediaQuery.sizeOf(context).height * .42).clamp(
                        180,
                        420,
                      ),
                    )
                  : SizedBox(
                      height: (MediaQuery.sizeOf(context).height * .34).clamp(
                        160,
                        300,
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_camera_outlined, size: 80),
                          SizedBox(height: 16),
                          Text(
                            'Cho mình xem một đồ vật nhé!',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _busy
                ? null
                : _camera != null
                ? _capture
                : _openCamera,
            icon: const Icon(Icons.camera_alt),
            label: Text(
              _camera != null
                  ? 'Chụp ảnh'
                  : _photo != null
                  ? 'Chụp lại'
                  : 'Mở camera',
            ),
          ),
          OutlinedButton.icon(
            onPressed: _busy ? null : _gallery,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Chọn ảnh'),
          ),
          if (_busy) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Đang nhìn đồ vật…', textAlign: TextAlign.center),
            ),
          ],
          if (_error != null) ...[
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_error!, textAlign: TextAlign.center),
            ),
            TextButton.icon(
              onPressed: _busy
                  ? null
                  : () {
                      if (_photo != null) {
                        _run(() => _recognize(_photo!));
                      } else {
                        _openCamera();
                      }
                    },
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
          if (_result != null && _result!.objects.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Chưa tìm thấy đồ vật quen thuộc. Thử chụp rõ hơn nhé!',
                textAlign: TextAlign.center,
              ),
            ),
          if (_result != null)
            for (var i = 0; i < _result!.objects.length; i++)
              _resultTile(i, _result!.objects[i]),
          if (_result == null && !_busy)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Thử: táo, chuối, cốc, sách, ghế, chai.',
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    ),
  );

  Widget _resultTile(int index, DetectedObject object) => Card(
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: detectionColors[index % detectionColors.length],
        foregroundColor: Colors.white,
        child: Text('${index + 1}'),
      ),
      title: Text(
        object.vietnamese,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(object.english),
      trailing: Text(
        '${(object.confidence * 100).round()}%',
        style: const TextStyle(fontSize: 20),
      ),
    ),
  );
}
