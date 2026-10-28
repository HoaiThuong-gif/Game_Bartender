
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'processing_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;

  bool _isScanning = false;
  bool _isBusy = false;
  String _message = 'Đặt vật thể vào giữa khung hình';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      final backCamera = cameras.firstWhere(
            (camera) =>
        camera.lensDirection == CameraLensDirection.back,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _message = 'Đặt vật thể vào giữa khung hình';
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _message = 'Không thể mở camera: $e';
        });
      }
    }
  }

  Future<void> _toggleScanning() async {
    final controller = _cameraController;

    if (controller == null || _isBusy) return;

    setState(() {
      _isBusy = true;
    });

    try {
      if (!_isScanning) {
        await controller.startVideoRecording();

        if (!mounted) return;

        setState(() {
          _isScanning = true;
          _message = 'Di chuyển chậm quanh vật thể';
        });
      } else {
        final video = await controller.stopVideoRecording();

        if (!mounted) return;

        setState(() {
          _isScanning = false;
          _message = 'Quét hoàn thành!';
        });

        debugPrint('Video saved at: ${video.path}');

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProcessingScreen(
              videoPath: video.path,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _message = 'Lỗi khi quét: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      if (!_isScanning) {
        _cameraController?.dispose();
        _cameraController = null;
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_cameraController == null && !_isScanning) {
        _initializeCamera();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCameraReady =
        _cameraController?.value.isInitialized ?? false;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Quét vật thể 3D'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: !isCameraReady
          ? Center(
        child: Text(
          _message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      )
          : Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_cameraController!),

          Center(
            child: IgnorePointer(
              child: Container(
                width: 250,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.tealAccent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),

          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed:
                _isBusy ? null : _toggleScanning,
                icon: Icon(
                  _isScanning
                      ? Icons.stop_circle
                      : Icons.videocam,
                ),
                label: Text(
                  _isScanning
                      ? 'Hoàn thành quét'
                      : 'Bắt đầu quét',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isScanning
                      ? Colors.red
                      : Colors.tealAccent,
                  foregroundColor: _isScanning
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
