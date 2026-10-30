import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'photo_model_api.dart';

import 'package:flutter/services.dart';

import 'photo_scan_image.dart';

class PhotoScanScreen extends StatefulWidget {
  const PhotoScanScreen({super.key, this.service, this.pickImage});
  final PhotoModelService? service;
  final Future<PhotoScanImage?> Function()? pickImage;
  @override
  State<PhotoScanScreen> createState() => _PhotoScanScreenState();
}

class _PhotoScanScreenState extends State<PhotoScanScreen>
    with WidgetsBindingObserver {
  late final PhotoModelService _service = widget.service ?? PhotoModelApi();
  CameraController? _camera;
  PhotoScanImage? _photo;
  Uint8List? _mesh;
  String? _error;
  String _stage = 'uploading';
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
    _service.close();
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
        '[Photo3D] ${error is CameraException ? error.code : error.runtimeType}',
      );
      if (mounted) {
        setState(
          () => _error = error is PhotoModelException
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
      throw const PhotoModelException(
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
      _mesh = null;
    });
  });

  Future<PhotoScanImage> _prepare(XFile file) async {
    if (await file.length() > 8 * 1024 * 1024) {
      throw const PhotoModelException('Hãy chọn ảnh nhỏ hơn 8 MB.');
    }
    return compute(preparePhotoScanImage, await file.readAsBytes());
  }

  Future<void> _createModel(PhotoScanImage image) async {
    if (!mounted) return;
    setState(() {
      _photo = image;
      _mesh = null;
    });
    final result = await _service.generate(image.bytes, (stage) {
      if (mounted) setState(() => _stage = stage);
    });
    if (mounted) setState(() => _mesh = result);
  }

  Future<void> _capture() => _run(() async {
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized) return;
    final file = await camera.takePicture();
    PhotoScanImage image;
    try {
      image = await _prepare(file);
    } finally {
      // Only delete the temporary photo created by OUR camera, never a gallery source.
      try {
        await File(file.path).delete();
      } catch (_) {}
    }
    await _releaseCamera();
    await _createModel(image);
  });

  Future<void> _gallery() => _run(() async {
    await _releaseCamera();
    PhotoScanImage? image;
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
    if (image != null) await _createModel(image);
  });

  Future<void> _view() => _run(() async {
    final mesh = _mesh;
    if (mesh == null) return;
    try {
      await const MethodChannel('meomeo/spatial')
          .invokeMethod<void>('openPhotoModel', {'mesh': mesh});
    } on PlatformException {
      throw const PhotoModelException('Chưa mở được mô hình. Hãy thử lại.');
    } on MissingPluginException {
      throw const PhotoModelException(
        'Hãy mở mô hình trên bản Android mới của ứng dụng.',
      );
    }
  });

  String get _stageText => switch (_stage) {
    'preprocessing' => 'Đang tách đồ vật…',
    'reconstructing' => 'Đang tạo hình 3D…',
    'extracting' || 'exporting' => 'Đang hoàn thiện mô hình…',
    'downloading' => 'Đang nhận mô hình…',
    _ => 'Đang gửi ảnh…',
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ảnh thành 3D')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: SizedBox(
                height: (MediaQuery.sizeOf(context).height * .4).clamp(
                  180,
                  380,
                ),
                child: _camera != null
                    ? Center(child: CameraPreview(_camera!))
                    : _photo != null
                    ? Image.memory(_photo!.bytes, fit: BoxFit.contain)
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.view_in_ar_outlined, size: 72),
                          SizedBox(height: 16),
                          Text('Chụp một vật trên nền đơn giản'),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_mesh != null) ...[
            FilledButton.icon(
              onPressed: _busy ? null : _view,
              icon: const Icon(Icons.view_in_ar),
              label: const Text('Xem mô hình 3D'),
            ),
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Bản thử nghiệm: mặt khuất có thể khác vật thật.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
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
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_stageText, textAlign: TextAlign.center),
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
                  : _mesh != null
                  ? _view
                  : _photo != null
                  ? () => _run(() => _createModel(_photo!))
                  : _openCamera,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ],
      ),
    ),
  );
}
