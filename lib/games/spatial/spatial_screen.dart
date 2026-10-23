import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  String _availability = 'Đang kiểm tra ARCore…';
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
    }
  }

  Future<void> _refresh() async {
    if (!_android) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error =
              'Quét depth và AR hiện hỗ trợ Android. '
              'Hãy mở ứng dụng trên thiết bị Android có ARCore Depth.';
        });
      }
      return;
    }
    try {
      final result = await _channel.invokeListMethod<dynamic>('models');
      final support = await _channel.invokeMapMethod<String, dynamic>(
        'capabilities',
      );
      if (!mounted) return;
      setState(() {
        _models = [
          for (final item in result ?? [])
            Map<String, dynamic>.from(item as Map),
        ];
        _selected.retainAll(_models.map((model) => model['id'] as String));
        _availability =
            'ARCore: ${support?['arcore'] ?? 'chưa xác định'}. '
            'Khả năng depth được kiểm tra khi mở camera.';
        _error = null;
        _loading = false;
      });
    } on PlatformException catch (error) {
      if (mounted) {
        setState(() {
          _error = error.message ?? error.code;
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

  Future<void> _open(String mode, [String? id]) async {
    if (_opening || !_android) return;
    setState(() => _opening = true);
    try {
      await _channel.invokeMethod<void>('open', {'mode': mode, 'id': id});
    } on PlatformException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message ?? error.code)));
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message ?? error.code)));
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
              ? 'Xóa “${models.first['name']}” cùng mesh, texture và các tệp xuất đã lưu trên điện thoại?'
              : 'Xóa các mô hình đã chọn cùng mesh, texture và các tệp xuất tương ứng trên điện thoại?',
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message ?? error.code)));
      }
    } finally {
      if (mounted) {
        setState(() => _deleting = false);
        await _refresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final expedition = widget.expedition;
    return Scaffold(
      backgroundColor: const Color(0xff0b1222),
      appBar: AppBar(
        title: Text(expedition ? 'Game 4 · AR / VR' : 'Game 3 · Quét 3D'),
        actions: [
          IconButton(
            tooltip: 'Làm mới thư viện',
            onPressed: _loading || _deleting ? null : _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (!_deleting) await _refresh();
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Icon(
              expedition ? Icons.view_in_ar : Icons.document_scanner_outlined,
              size: 56,
              color: const Color(0xff6ee7c5),
            ),
            const SizedBox(height: 16),
            Text(
              expedition
                  ? 'Mang vật thể của bạn vào cuộc chơi'
                  : 'Thợ săn hình khối',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              expedition
                  ? 'Sắp đặt AR: khớp vị trí, góc và kích thước qua 3 lượt. '
                        'Thám hiểm VR: tìm và thu thập 4 trạm quanh mô hình trong không gian 3D. '
                        'Mỗi nhiệm vụ sử dụng chính bản quét bạn đã lưu.'
                  : 'Di chuyển camera liên tục quanh một vật thể đứng yên. '
                        'Thu thập ít nhất 75% góc nhìn ở hai độ cao để hoàn thành nhiệm vụ. '
                        'Depth trên điện thoại phù hợp bản quét thô. Với vật nhỏ hoặc cần texture rõ, '
                        'ưu tiên Ảnh → PC để thu ảnh rõ và tái tạo đa góc cục bộ '
                        'qua máy tính kết nối USB.',
              style: const TextStyle(color: Color(0xffc4cede), height: 1.6),
            ),
            const SizedBox(height: 16),
            if (!expedition)
              FilledButton.icon(
                onPressed: _android && !_opening ? () => _open('scan') : null,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Quét vật thể mới'),
              ),
            if (expedition && _models.isEmpty && !_loading)
              OutlinedButton.icon(
                onPressed: _android && !_opening ? () => _open('scan') : null,
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Tạo mô hình đầu tiên từ Game 3'),
              ),
            const SizedBox(height: 16),
            if (_android)
              OutlinedButton.icon(
                onPressed: _importing ? null : _importPc,
                icon: const Icon(Icons.usb),
                label: Text(
                  _importing
                      ? 'Đang nhận mô hình…'
                      : 'Nhận mô hình từ PC qua USB',
                ),
              ),
            if (_android)
              Text(
                _availability,
                style: const TextStyle(color: Color(0xff91a2bb), fontSize: 12),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.orange),
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              'Bộ sưu tập quét thật',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 12),
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (!_loading && _models.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Chưa có bản quét. Thư viện chỉ hiển thị mô hình được tạo '
                  'từ camera của bạn; không có dữ liệu mẫu.',
                  style: TextStyle(color: Color(0xffb0bfd4), height: 1.5),
                ),
              ),
            if (_selected.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
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
                    FilledButton.icon(
                      onPressed: _deleting
                          ? null
                          : () => _deleteModels(
                              _models
                                  .where((m) => _selected.contains(m['id']))
                                  .toList(),
                            ),
                      icon: const Icon(Icons.delete_outline),
                      label: Text(_deleting ? 'Đang xóa…' : 'Xóa đã chọn'),
                    ),
                  ],
                ),
              ),
            for (final model in _models) _modelCard(model),
            const SizedBox(height: 20),
            const Text(
              'Đặt vật thể đục, có chi tiết trên bàn đủ sáng. Giữ vật thể đứng yên, '
              'đi quanh để quan sát các mặt. Depth có thể không đo được kính, '
              'gương, mặt quá nhỏ hoặc các phần bị che khuất. '
              'Mô hình lưu trong dữ liệu ứng dụng; gỡ ứng dụng sẽ mất bản quét.',
              style: TextStyle(
                color: Color(0xff91a2bb),
                height: 1.5,
                fontSize: 12,
              ),
            ),
            TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Công nghệ & dữ liệu'),
                  content: const SingleChildScrollView(
                    child: Text(
                      'ARCore SDK 1.57.0 — Google LLC.\n'
                      'SDK và thông báo giấy phép: '
                      'https://github.com/google-ar/arcore-android-sdk/blob/main/LICENSE\n\n'
                      'Đường depth hợp nhất TSDF và trích xuất lưới trên thiết bị. '
                      'Đường Ảnh → PC dùng COLMAP (BSD-3-Clause), OpenCV (Apache-2.0), '
                      'Open3D (MIT), MobileSAM (Apache-2.0) trên máy tính của bạn. '
                      'MobileSAM: https://github.com/ChaoningZhang/MobileSAM; '
                      'OpenMVS 2.4.0 — SEACAVE (AGPL-3.0), công cụ PC nguyên bản, '
                      'không có bảo hành. Mã nguồn và giấy phép: '
                      'https://github.com/cdcseacave/openMVS/tree/v2.4.0. '
                      'Khởi động: tools/start-scan-server.ps1; kết nối USB: '
                      'adb reverse tcp:8765 tcp:8765. '
                      'Các khung camera không được gửi lên Firebase hoặc API trả phí. '
                      'Game 4 không hỗ trợ bộ điều khiển OpenXR; chế độ hai mắt '
                      'trên điện thoại cần cảm biến hướng và kính phù hợp.',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Đóng'),
                    ),
                  ],
                ),
              ),
              child: const Text('Công nghệ & dữ liệu'),
            ),
          ],
        ),
      ),
    );
  }

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
          Text(
            '${model['triangles']} tam giác · ${model['frames']} ${model['source'] == 'photogrammetry' ? 'ảnh camera' : 'khung depth'} · '
            '${model['coverage']}% góc',
          ),
          Text(
            model['scanComplete'] == true &&
                    (model['qualityVersion'] as num? ?? 0) >= 3
                ? '✓ Đạt kiểm tra dữ liệu; cần xem lại hình dạng'
                : 'Bản quét chưa hoàn chỉnh',
          ),
          if ((model['qualityVersion'] as num? ?? 0) < 3)
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
