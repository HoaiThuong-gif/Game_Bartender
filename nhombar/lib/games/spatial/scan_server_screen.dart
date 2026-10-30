import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'scan_pairing.dart';
import 'scan_qr_screen.dart';

class ScanServerScreen extends StatefulWidget {
  const ScanServerScreen({super.key, this.forScan = false});
  final bool forScan;
  @override
  State<ScanServerScreen> createState() => _ScanServerScreenState();
}

class _ScanServerScreenState extends State<ScanServerScreen>
    with WidgetsBindingObserver {
  static const _channel = MethodChannel('meomeo/spatial');
  final _address = TextEditingController();
  final _code = TextEditingController();
  Timer? _timer;
  bool _busy = false, _ready = false, _foreground = true, _scanning = false;
  String? _hint;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _timer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (_foreground && !_scanning) _check();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground && !_scanning) _check();
  }

  Future<void> _load() async {
    try {
      final settings = await _channel.invokeMapMethod<String, dynamic>(
        'serverSettings',
      );
      if (!mounted) return;
      _address.text = settings?['address'] as String? ?? '';
      _code.text = settings?['code'] as String? ?? '';
    } catch (error) {
      debugPrint('[Scan settings] ${error.runtimeType}');
    }
    if (mounted) await _check();
  }

  Future<void> _check({ScanPairing? pairing}) async {
    if (_busy || !mounted) return;
    setState(() {
      _busy = true;
      _ready = false;
      _hint = null;
    });
    try {
      if (pairing != null) {
        await _channel.invokeMethod<dynamic>('saveServerSettings', {
          'address': pairing.address,
          'code': pairing.code,
        });
      }
      final health = await _channel.invokeMapMethod<String, dynamic>(
        'checkServerConnection',
      );
      if (mounted) setState(() => _ready = health?['ready'] == true);
    } catch (error) {
      debugPrint(
        '[Scan connection] ${error is PlatformException ? error.code : error.runtimeType}',
      );
      if (mounted) {
        setState(
          () => _hint = pairing != null
              ? 'Chưa ghép nối được. Hãy mở mã mới trên máy tính và thử lại.'
              : null,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _qr() async {
    _scanning = true;
    final pairing = await Navigator.of(context).push<ScanPairing>(
      MaterialPageRoute(builder: (_) => const ScanQrScreen()),
    );
    _scanning = false;
    if (mounted && pairing != null) await _check(pairing: pairing);
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _address.dispose();
    _code.dispose();
    super.dispose();
  }

  Widget _step(IconData icon, String text) =>
      ListTile(leading: Icon(icon), title: Text(text));
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Hướng dẫn kết nối')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Icon(
          _ready ? Icons.check_circle_outline : Icons.computer,
          size: 72,
          color: _ready ? Colors.green : null,
        ),
        const SizedBox(height: 16),
        Text(
          _ready ? 'Sẵn sàng quét' : 'Chưa tìm thấy máy xử lý 3D',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (_busy) const LinearProgressIndicator(),
        if (_hint != null) Text(_hint!),
        if (_ready)
          FilledButton(
            onPressed: _busy ? null : () => Navigator.pop(context, true),
            child: Text(widget.forScan ? 'Bắt đầu quét' : 'Xong'),
          )
        else ...[
          _step(Icons.computer, '1. Mở “Mở máy quét” trên máy tính.'),
          _step(Icons.wifi, '2. Cho điện thoại và máy tính dùng cùng Wi-Fi.'),
          _step(
            Icons.qr_code_scanner,
            '3. Quét mã trên máy tính để kết nối lần đầu.',
          ),
          FilledButton.icon(
            onPressed: _busy ? null : _qr,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Quét mã kết nối'),
          ),
          TextButton.icon(
            onPressed: _busy ? null : _check,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'App nhớ máy đã ghép nối và tự tìm lại trong những lần sau.',
          ),
        ),
        ExpansionTile(
          title: const Text('Dùng cáp kết nối'),
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Cắm cáp truyền dữ liệu và mở chương trình quét trên máy tính. '
                'Bản dùng thử cần người lớn bật Gỡ lỗi USB và xác nhận Cho phép trên điện thoại. '
                'App sẽ tự kết nối khi chương trình máy tính nhận điện thoại.',
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: const Text('Cấu hình nâng cao'),
          children: [
            const Text(
              'Dành cho người thiết lập. Lấy địa chỉ và mã từ chương trình trên máy tính.',
            ),
            TextField(
              controller: _address,
              enabled: !_busy,
              autocorrect: false,
              enableSuggestions: false,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(labelText: 'Địa chỉ HTTPS'),
            ),
            TextField(
              controller: _code,
              enabled: !_busy,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(labelText: 'Mã ghép nối'),
            ),
            TextButton(
              onPressed: _busy
                  ? null
                  : () => _check(
                      pairing: ScanPairing(
                        _address.text.trim(),
                        _code.text.trim(),
                      ),
                    ),
              child: const Text('Kiểm tra và lưu'),
            ),
          ],
        ),
      ],
    ),
  );
}
