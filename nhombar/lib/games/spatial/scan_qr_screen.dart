import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'scan_pairing.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});
  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final _camera = MobileScannerController(formats: [BarcodeFormat.qrCode]);
  bool _reading = false;
  String? _hint;
  Future<void> _read(BarcodeCapture capture) async {
    if (_reading) return;
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value == null) return;
    _reading = true;
    ScanPairing pairing;
    try {
      pairing = ScanPairing.parse(value);
    } catch (_) {
      setState(
        () => _hint = 'Hãy quét mã trong cửa sổ kết nối 3D trên máy tính.',
      );
      _reading = false;
      return;
    }
    await _camera.stop();
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kết nối máy xử lý này?'),
        content: const Text(
          'Chỉ tiếp tục nếu mã này đang hiển thị trên máy tính của bạn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Quét lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Kết nối'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmed == true) {
      Navigator.pop(context, pairing);
    } else {
      _reading = false;
      await _camera.start();
    }
  }

  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Quét mã trên máy tính')),
    body: Column(
      children: [
        Expanded(
          child: MobileScanner(
            controller: _camera,
            onDetect: _read,
            errorBuilder: (context, error) => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Chưa mở được máy ảnh. Hãy cấp quyền camera trong Cài đặt rồi mở lại.',
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              _hint ?? 'Đưa mã vuông trên máy tính vào giữa máy ảnh.',
            ),
          ),
        ),
      ],
    ),
  );
}
