
import 'dart:async';

import 'package:flutter/material.dart';

import '../services/scan_service.dart';
import 'model_viewer_screen.dart';
import 'pointcloud_viewer_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final String videoPath;

  const ProcessingScreen({
    super.key,
    required this.videoPath,
  });

  @override
  State<ProcessingScreen> createState() =>
      _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  final ScanService _scanService = ScanService();

  Timer? _pollTimer;

  bool _isUploading = false;
  bool _isUploaded = false;
  bool _isProcessing = false;
  bool _isCheckingStatus = false;
  bool _isOpeningViewer = false;

  double _uploadProgress = 0;

  String? _scanId;
  String _status = 'ready';
  String _message = 'Video đã sẵn sàng để gửi lên server';

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _uploadVideo() async {
    if (_isUploading || _isUploaded) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
      _status = 'uploading';
      _message = 'Đang kết nối với server...';
    });

    try {
      final serverAvailable =
      await _scanService.checkServer();

      if (!serverAvailable) {
        throw Exception(
          'Không kết nối được với FastAPI. '
              'Hãy kiểm tra IP laptop và mạng Wi-Fi.',
        );
      }

      if (!mounted) return;

      setState(() {
        _message = 'Đang gửi video lên server...';
      });

      final result = await _scanService.uploadVideo(
        videoPath: widget.videoPath,
        onProgress: (sent, total) {
          if (!mounted || total <= 0) return;

          setState(() {
            _uploadProgress =
                (sent / total).clamp(0.0, 1.0);
          });
        },
      );

      if (!mounted) return;

      final scanId = result['scan_id']?.toString();

      if (scanId == null || scanId.isEmpty) {
        throw Exception(
          'Backend không trả về Scan ID.',
        );
      }

      setState(() {
        _scanId = scanId;
        _isUploaded = true;
        _isProcessing = true;
        _status = 'processing';
        _uploadProgress = 1;
        _message =
        'Upload thành công! Đang chờ COLMAP dựng mô hình 3D...';
      });

      _startPolling();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _status = 'failed';
        _message = 'Lỗi: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();

    // Kiểm tra trạng thái ngay sau khi upload.
    _checkScanStatus();

    // Sau đó tự động kiểm tra mỗi 3 giây.
    _pollTimer = Timer.periodic(
      const Duration(seconds: 3),
          (_) => _checkScanStatus(),
    );
  }

  Future<void> _checkScanStatus() async {
    final scanId = _scanId;

    if (scanId == null ||
        _isCheckingStatus ||
        _isOpeningViewer ||
        !mounted) {
      return;
    }

    _isCheckingStatus = true;

    try {
      final result =
      await _scanService.getScanStatus(scanId);

      if (!mounted || _isOpeningViewer) return;

      final status =
          result['status']?.toString() ?? 'unknown';

      if (status == 'completed') {
        _pollTimer?.cancel();

        setState(() {
          _status = 'completed';
          _isProcessing = false;
          _message =
          'Dựng mô hình 3D thành công! Đang mở kết quả...';
        });

        await _openViewer(result);
        return;
      }

      if (status == 'failed') {
        _pollTimer?.cancel();

        final error =
            result['error']?.toString() ?? '';

        setState(() {
          _status = 'failed';
          _isProcessing = false;
          _message = error.isNotEmpty
              ? 'Dựng 3D thất bại: $error'
              : 'Dựng mô hình 3D thất bại.';
        });

        return;
      }

      setState(() {
        _status = status;
        _isProcessing = true;
        _message =
            result['message']?.toString() ??
                'COLMAP đang xử lý video...';
      });
    } catch (e) {
      if (!mounted) return;

      // Mất mạng tạm thời không có nghĩa
      // là quá trình dựng 3D thất bại.
      setState(() {
        _message =
        'Tạm thời không lấy được trạng thái: $e. '
            'Ứng dụng sẽ thử lại...';
      });
    } finally {
      _isCheckingStatus = false;
    }
  }

  Future<void> _openViewer(
      Map<String, dynamic> result,
      ) async {
    if (!mounted || _isOpeningViewer) return;

    _isOpeningViewer = true;

    try {
      final resultType =
      result['result_type']?.toString();

      final pointcloudPath =
      result['pointcloud_url']?.toString();

      final modelPath =
      result['model_url']?.toString();

      // =================================================
      // TRƯỜNG HỢP 1: POINT CLOUD TỪ COLMAP
      // =================================================

      if (resultType == 'pointcloud' &&
          pointcloudPath != null &&
          pointcloudPath.isNotEmpty) {
        final pointCloudUrl =
        _scanService.getPointCloudUrl(
          pointcloudPath,
        );

        // Viewer hiện tại chỉ nhận pointCloudUrl.
        // Nó tự tải cameras.json từ scan ID.
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PointCloudViewerScreen(
                  pointCloudUrl: pointCloudUrl,
                ),
          ),
        );

        return;
      }

      // =================================================
      // TRƯỜNG HỢP 2: MÔ HÌNH GLB
      // =================================================

      if (resultType == 'mesh' &&
          modelPath != null &&
          modelPath.isNotEmpty) {
        final modelUrl =
        _scanService.getModelUrl(modelPath);

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ModelViewerScreen(
                  modelUrl: modelUrl,
                ),
          ),
        );

        return;
      }

      throw Exception(
        'Backend báo hoàn thành nhưng không '
            'trả về đường dẫn mô hình hợp lệ.',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _message = 'Không thể mở mô hình 3D: $e';
      });
    } finally {
      _isOpeningViewer = false;
    }
  }

  Widget _buildStatusIcon() {
    if (_status == 'completed') {
      return const Icon(
        Icons.check_circle,
        size: 90,
        color: Colors.tealAccent,
      );
    }

    if (_status == 'failed') {
      return const Icon(
        Icons.error_outline,
        size: 90,
        color: Colors.redAccent,
      );
    }

    return const Icon(
      Icons.view_in_ar,
      size: 110,
      color: Colors.tealAccent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _isUploading || _isProcessing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xử lý mô hình 3D'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  _buildStatusIcon(),

                  const SizedBox(height: 25),

                  const Text(
                    'Xử lý bản quét 3D',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ======================================
                  // TIẾN ĐỘ UPLOAD VIDEO
                  // ======================================

                  if (_isUploading) ...[
                    LinearProgressIndicator(
                      value: _uploadProgress,
                      color: Colors.tealAccent,
                      backgroundColor: Colors.white12,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                    ),

                    const SizedBox(height: 25),
                  ],

                  // ======================================
                  // ĐANG DỰNG MÔ HÌNH COLMAP
                  // ======================================

                  if (_isProcessing) ...[
                    const CircularProgressIndicator(
                      color: Colors.tealAccent,
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'COLMAP đang xử lý trên laptop...',
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 25),
                  ],

                  // ======================================
                  // NÚT UPLOAD VIDEO
                  // ======================================

                  if (!_isUploaded) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: _isUploading
                            ? null
                            : _uploadVideo,
                        icon: const Icon(
                          Icons.cloud_upload,
                        ),
                        label: const Text(
                          'Gửi video lên server',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          Colors.tealAccent,
                          foregroundColor:
                          Colors.black,
                        ),
                      ),
                    ),
                  ],

                  // ======================================
                  // XEM LẠI MÔ HÌNH
                  // ======================================

                  if (_isUploaded &&
                      _status == 'completed') ...[
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: _isOpeningViewer
                            ? null
                            : _checkScanStatus,
                        icon: const Icon(
                          Icons.view_in_ar,
                        ),
                        label: const Text(
                          'Xem lại mô hình 3D',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          Colors.tealAccent,
                          foregroundColor:
                          Colors.black,
                        ),
                      ),
                    ),
                  ],

                  // ======================================
                  // KIỂM TRA LẠI KHI THẤT BẠI
                  // ======================================

                  if (_isUploaded &&
                      _status == 'failed') ...[
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton.icon(
                        onPressed: _checkScanStatus,
                        icon: const Icon(Icons.refresh),
                        label: const Text(
                          'Kiểm tra lại trạng thái',
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: isBusy
                        ? null
                        : () => Navigator.pop(context),
                    child: const Text(
                      'Quay lại màn hình quét',
                    ),
                  ),

                  if (_scanId != null) ...[
                    const SizedBox(height: 15),

                    SelectableText(
                      'Scan ID: $_scanId',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
