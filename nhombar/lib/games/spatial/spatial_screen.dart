import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'scan_server_screen.dart';

/// The lobby stays in Flutter; camera ownership and reconstruction stay native.
class SpatialScreen extends StatefulWidget {
  const SpatialScreen({super.key, this.expedition = false});

  final bool expedition;

  @override
  State<SpatialScreen> createState() => _SpatialScreenState();
}

class _SpatialScreenState extends State<SpatialScreen>
    with WidgetsBindingObserver {
  static const _channel = MethodChannel('meomeo/spatial');
  List<Map<String, dynamic>> _models = const [];
  String? _error;
  bool _connected = false;
  bool _checking = false;
  bool _showModels = false;
  bool _loading = true;
  bool _opening = false;
  bool _importing = false;
  bool _deleting = false;
  final _selected = <String>{};

  bool get _android =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
    _showModels = widget.expedition;
    _checkConnection();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _opening = false;
      _refresh();
      _checkConnection();
    }
  }

  Future<void> _refresh() async {
    if (!_android) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error =
              'Hãy mở chức năng này trên điện thoại Android có hỗ trợ quét 3D.';
        });
      }
      return;
    }
    try {
      final result = await _channel.invokeListMethod<dynamic>('models');
      if (!mounted) return;
      setState(() {
        _models = [
          for (final item in result ?? [])
            Map<String, dynamic>.from(item as Map),
        ];
        _selected.retainAll(_models.map((model) => model['id'] as String));
        _error = null;
        _loading = false;
      });
    } on PlatformException catch (error) {
      if (mounted) {
        setState(() {
          debugPrint('[Spatial] ${error.code}: ${error.message}');
          _error = 'Chưa tải được mô hình. Hãy thử lại.';
          _loading = false;
        });
      }
    } on MissingPluginException {
      if (mounted) {
        setState(() {
          _error = 'Cần bản build Android có mô-đun quét 3D.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _checkConnection() async {
    if (!_android || _checking) return;
    setState(() => _checking = true);
    try {
      final health = await _channel.invokeMapMethod<String, dynamic>(
        'checkServerConnection',
      );
      if (mounted) setState(() => _connected = health?['ready'] == true);
    } catch (error) {
      debugPrint('[Spatial connection] ${error.runtimeType}');
      if (mounted) setState(() => _connected = false);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _connectionGuide() async {
    await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const ScanServerScreen()));
    if (mounted) await _checkConnection();
  }

  void _friendlyError(PlatformException error) {
    debugPrint('[Spatial] ${error.code}: ${error.message}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chưa thực hiện được. Hãy thử lại.')),
    );
  }

  Future<void> _open(String mode, [String? id]) async {
    if (_opening || !_android) return;
    setState(() => _opening = true);
    try {
      if (mode == 'scan') {
        try {
          final health = await _channel.invokeMapMethod<String, dynamic>(
            'checkServerConnection',
          );
          if (health?['ready'] != true) {
            throw PlatformException(code: 'NOT_READY');
          }
        } on PlatformException {
          if (!mounted) return;
          setState(() => _connected = false);
          final connected = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => const ScanServerScreen(forScan: true),
            ),
          );
          if (!mounted || connected != true) return;
          final health = await _channel.invokeMapMethod<String, dynamic>(
            'checkServerConnection',
          );
          if (health?['ready'] != true) {
            throw PlatformException(code: 'NOT_READY');
          }
        }
        if (!mounted) return;
      }
      await _channel.invokeMethod<void>('open', {'mode': mode, 'id': id});
    } on PlatformException catch (error) {
      if (mounted) {
        _friendlyError(error);
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  Future<void> _importPc() async {
    if (_importing) return;
    setState(() => _importing = true);
    try {
      final count = await _channel.invokeMethod<int>('importPcModels') ?? 0;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã nhận $count mô hình mới từ máy tính.')),
      );
      await _refresh();
    } on PlatformException catch (error) {
      if (mounted) {
        _friendlyError(error);
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _deleteModels(List<Map<String, dynamic>> models) async {
    if (_deleting || models.isEmpty) return;
    final ids = models.map((m) => m['id'] as String).toList();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          models.length == 1 ? 'Xóa mô hình?' : 'Xóa ${models.length} mô hình?',
        ),
        content: Text(
          models.length == 1
              ? 'Xóa “${models.first['name']}” khỏi điện thoại? Bạn không thể lấy lại sau khi xóa.'
              : 'Xóa các mô hình đã chọn khỏi điện thoại? Bạn không thể lấy lại sau khi xóa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _deleting = true);
    try {
      final count =
          await _channel.invokeMethod<int>('deleteModels', {'ids': ids}) ?? 0;
      if (!mounted) return;
      setState(() {
        _models.removeWhere((model) => ids.contains(model['id']));
        _selected.removeAll(ids);
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Đã xóa $count mô hình.')));
    } on PlatformException catch (error) {
      if (mounted) {
        _friendlyError(error);
      }
    } finally {
      if (mounted) {
        setState(() => _deleting = false);
        await _refresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xff0b1222),
    appBar: AppBar(
      title: Text(_showModels ? 'Mô hình của tôi' : 'Quét 3D'),
      leading: _showModels && !widget.expedition
          ? IconButton(
              tooltip: 'Về quét 3D',
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() => _showModels = false),
            )
          : null,
      actions: [
        IconButton(
          tooltip: 'Hướng dẫn kết nối',
          onPressed: _connectionGuide,
          icon: const Icon(Icons.help_outline),
        ),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: () async {
        await _refresh();
        await _checkConnection();
      },
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (!_showModels) ...[
            const SizedBox(height: 24),
            const Icon(Icons.view_in_ar, size: 88, color: Color(0xff6ee7c5)),
            const SizedBox(height: 24),
            const Text(
              'Biến đồ vật thành mô hình 3D',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const _ScanTip(
              icon: Icons.wb_sunny_outlined,
              text: 'Đặt đồ vật ở chỗ đủ sáng',
            ),
            const _ScanTip(
              icon: Icons.center_focus_strong,
              text: 'Giữ đồ vật đứng yên',
            ),
            const _ScanTip(
              icon: Icons.threesixty,
              text: 'Đi chậm quanh đồ vật',
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _android && _connected && !_checking && !_opening
                  ? () => _open('scan')
                  : null,
              icon: const Icon(Icons.camera_alt_outlined),
              label: Text(_opening ? 'Đang mở máy ảnh…' : 'Bắt đầu quét'),
            ),
            OutlinedButton.icon(
              onPressed: () => setState(() => _showModels = true),
              icon: const Icon(Icons.collections_outlined),
              label: const Text('Mô hình của tôi'),
            ),
            const SizedBox(height: 20),
            if (_checking) const LinearProgressIndicator(),
            Text(
              _checking
                  ? 'Đang tìm máy xử lý…'
                  : _connected
                  ? 'Sẵn sàng quét'
                  : 'Chưa tìm thấy máy xử lý 3D',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            if (!_connected && !_checking) ...[
              TextButton.icon(
                onPressed: _checkConnection,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
              TextButton(
                onPressed: _connectionGuide,
                child: const Text('Hướng dẫn kết nối'),
              ),
            ],
          ] else ...[
            if (_loading) const LinearProgressIndicator(),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.orange)),
            if (!_loading && _models.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Chưa có mô hình. Hãy quét đồ vật đầu tiên!',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            if (_selected.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Đã chọn ${_selected.length}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: _deleting
                        ? null
                        : () => setState(_selected.clear),
                    child: const Text('Bỏ chọn'),
                  ),
                  FilledButton(
                    onPressed: _deleting
                        ? null
                        : () => _deleteModels(
                            _models
                                .where((m) => _selected.contains(m['id']))
                                .toList(),
                          ),
                    child: const Text('Xóa đã chọn'),
                  ),
                ],
              ),
            for (final model in _models) _modelCard(model),
            OutlinedButton.icon(
              onPressed: _importing || !_connected ? null : _importPc,
              icon: const Icon(Icons.download),
              label: Text(
                _importing ? 'Đang nhận mô hình…' : 'Nhận mô hình từ máy xử lý',
              ),
            ),
            TextButton(onPressed: _refresh, child: const Text('Làm mới')),
          ],
        ],
      ),
    ),
  );

  Widget _modelCard(Map<String, dynamic> model) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: _selected.contains(model['id']),
                onChanged: _deleting
                    ? null
                    : (value) => setState(() {
                        if (value == true) {
                          _selected.add(model['id'] as String);
                        } else {
                          _selected.remove(model['id']);
                        }
                      }),
              ),
              Expanded(
                child: Text(
                  model['name'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Xóa mô hình',
                onPressed: _deleting || _opening
                    ? null
                    : () => _deleteModels([model]),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ExpansionTile(
            title: const Text('Chi tiết mô hình'),
            children: [
              Text(
                '${model['triangles']} tam giác · ${model['frames']} ${model['source'] == 'photogrammetry' ? 'ảnh camera' : 'khung depth'} · '
                '${model['coverage']}% góc',
              ),
              Text(
                model['scanComplete'] == true &&
                        (model['qualityVersion'] as num? ?? 0) >= 5
                    ? '✓ Đạt kiểm tra dữ liệu; cần xem lại hình dạng'
                    : 'Bản quét chưa hoàn chỉnh',
              ),
              if ((model['qualityVersion'] as num? ?? 0) < 5)
                const Text('Bản quét cũ: chưa qua bộ kiểm tra hình học mới.'),
              if (model['quality'] is String &&
                  (model['quality'] as String).isNotEmpty)
                Text(model['quality'] as String),
              if (model['source'] == 'photogrammetry')
                Text(
                  model['scaleEstimated'] == true
                      ? 'Tỷ lệ mét chưa đủ tin cậy'
                      : 'Tỷ lệ từ camera ARCore',
                ),
              if (model['textured'] == true)
                const Text('Texture ảnh thật · UV atlas'),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _opening || _deleting || _selected.isNotEmpty
                    ? null
                    : () => _open('view', model['id'] as String),
                icon: const Icon(Icons.threed_rotation),
                label: const Text('Xem 3D'),
              ),
              FilledButton.tonal(
                onPressed: _opening || _deleting || _selected.isNotEmpty
                    ? null
                    : () => _open('ar', model['id'] as String),
                child: Text('AR ${model['arComplete'] == true ? '✓' : ''}'),
              ),
              FilledButton.tonal(
                onPressed: _opening || _deleting || _selected.isNotEmpty
                    ? null
                    : () => _open('vr', model['id'] as String),
                child: Text('VR ${model['vrComplete'] == true ? '✓' : ''}'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _ScanTip extends StatelessWidget {
  const _ScanTip({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xff6ee7c5)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
        ),
      ],
    ),
  );
}
