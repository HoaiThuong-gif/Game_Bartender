import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../controllers/cube_input_controller.dart';
import '../controllers/rubik_scan_controller.dart';
import '../models/cube_state.dart';
import '../models/rubik_face.dart';
import '../services/rubik_camera_service.dart';
import '../services/rubik_color_detector.dart';
import '../widgets/rubik_palette.dart';
import '../widgets/rubik_preview_panel.dart';
import '../widgets/rubik_scan_face_grid.dart';
import '../widgets/rubik_scan_preview.dart';
import '../widgets/rubik_theme.dart';
import 'solution_screen.dart';

class RubikScanScreen extends StatefulWidget {
  const RubikScanScreen({
    super.key,
    this.camera,
    this.detector = const RubikColorDetector(),
    this.previewBuilder,
  });
  final ScanCamera? camera;
  final RubikColorDetector detector;
  final CubePreviewBuilder? previewBuilder;

  @override
  State<RubikScanScreen> createState() => _RubikScanScreenState();
}

class _RubikScanScreenState extends State<RubikScanScreen>
    with WidgetsBindingObserver {
  late final ScanCamera _camera = widget.camera ?? RubikCameraService();
  final _scan = RubikScanController();
  final _input = CubeInputController();
  int _faceIndex = 0;
  int _cameraEpoch = 0;
  int _captureEpoch = 0;
  bool _foreground = true;
  bool _ready = false;
  bool _busy = false;
  bool _summary = false;
  String? _error;
  List<RubikColor?>? _draft;
  Set<int> _uncertain = {};
  Uint8List? _thumbnail;
  RubikFace get _face => CubeState.definitionOrder[_faceIndex];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _syncCamera();
  }

  Future<void> _syncCamera() async {
    final epoch = ++_cameraEpoch;
    final open = _foreground && _draft == null && !_summary;
    if (mounted) setState(() => _ready = false);
    try {
      if (open) {
        await _camera.open();
      } else {
        await _camera.close();
      }
      if (mounted && epoch == _cameraEpoch) setState(() => _ready = open);
    } catch (error) {
      if (mounted && epoch == _cameraEpoch) {
        setState(() => _error = _cameraError(error));
      }
    }
  }

  String _cameraError(Object error) {
    if (error is CameraException && error.code.contains('Access')) {
      return 'Chưa có quyền camera. Hãy cho phép Camera trong Cài đặt ứng dụng, rồi bấm Thử lại.';
    }
    if (error is CameraException && error.code == 'NoRearCamera') {
      return 'Thiết bị không có camera sau. Bạn có thể quay lại và nhập thủ công.';
    }
    return 'Không thể mở hoặc chụp camera. Hãy thử lại; nếu vẫn lỗi, dùng cách nhập thủ công.';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (!_foreground) _captureEpoch++;
    _syncCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraEpoch++;
    _captureEpoch++;
    unawaited(_camera.close().catchError((Object _) {}));
    _input.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (_busy || !_ready) return;
    final epoch = ++_captureEpoch;
    final aspect = _camera.previewAspect;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final bytes = await _camera.capture();
      if (!mounted || epoch != _captureEpoch) return;
      final result = await widget.detector.detect(bytes, aspect);
      if (!mounted || epoch != _captureEpoch) return;
      setState(() {
        _draft = List.of(result.colors);
        _uncertain = Set.of(result.uncertain);
        _thumbnail = result.thumbnail;
      });
      await _syncCamera();
    } catch (error) {
      if (mounted && epoch == _captureEpoch) {
        setState(
          () => _error = error is FormatException
              ? 'Không đọc được ảnh. Hãy chụp lại với đủ ánh sáng.'
              : _cameraError(error),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _edit(int index) async {
    final color = await showModalBottomSheet<RubikColor>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Chọn màu ô ${index + 1}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final color in RubikColor.values)
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context, color),
                      icon: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: color.paint,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black26),
                        ),
                      ),
                      label: Text(color.label),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (mounted && color != null) {
      setState(() {
        _draft![index] = color;
        _uncertain.remove(index);
        _error = null;
      });
    }
  }

  void _confirm() {
    try {
      _scan.confirm(_face, _draft!);
      setState(() {
        _error = null;
        _draft = null;
        _thumbnail = null;
        _summary = _scan.confirmed.length == 6;
        if (!_summary) {
          _faceIndex = CubeState.definitionOrder.indexWhere(
            (face) => !_scan.confirmed.contains(face),
          );
        }
      });
      _syncCamera();
    } on ArgumentError catch (error) {
      setState(() => _error = error.message.toString());
    }
  }

  void _review(RubikFace face) {
    setState(() {
      _faceIndex = CubeState.definitionOrder.indexOf(face);
      _draft = List.of(_scan.state.stickers(face));
      _uncertain = {};
      _thumbnail = null;
      _summary = false;
      _error = null;
    });
    _syncCamera();
  }

  Future<void> _solve() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    _input.load(_scan.state);
    final moves = await _input.solve();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = _input.error;
    });
    if (moves == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SolutionScreen(
          moves: moves,
          initialState: _input.state,
          previewBuilder: widget.previewBuilder,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => RubikTheme(
    child: Scaffold(
      appBar: AppBar(title: const Text('Quét Rubik')),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: _summary
            ? FilledButton(
                onPressed: _busy ? null : _solve,
                child: Text(_busy ? 'Đang giải…' : 'Kiểm tra & Giải'),
              )
            : _draft != null
            ? Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () {
                              setState(() {
                                _draft = null;
                                _thumbnail = null;
                                _error = null;
                              });
                              _syncCamera();
                            },
                      child: const Text('Chụp lại'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _busy ? null : _confirm,
                      child: const Text('Xác nhận mặt'),
                    ),
                  ),
                ],
              )
            : FilledButton(
                onPressed: _ready && !_busy ? _capture : null,
                child: Text(
                  _busy ? 'Đang nhận diện…' : 'Chụp mặt ${_face.code}',
                ),
              ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  children: [
                    if (_summary) ...[
                      const Text(
                        'Đã xác nhận 6/6 mặt',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Chạm một mặt để sửa màu hoặc chụp lại.'),
                      for (final face in CubeState.definitionOrder)
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: face.centerColor.paint,
                            child: Text(
                              face.code,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                          title: Text(
                            'Mặt ${face.centerColor.label.toLowerCase()} · ${face.code}',
                          ),
                          trailing: const Icon(Icons.edit_outlined),
                          onTap: _busy ? null : () => _review(face),
                        ),
                      const Divider(),
                      Wrap(
                        spacing: 14,
                        runSpacing: 8,
                        children: [
                          for (final color in RubikColor.values)
                            Text(
                              '${color.label}: ${_scan.state.count(color)}/9',
                              style: TextStyle(
                                color: _scan.state.count(color) == 9
                                    ? const Color(0xFF21816A)
                                    : Colors.red.shade700,
                              ),
                            ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        'Mặt ${_faceIndex + 1}/6 · ${_face.code} · ${_face.centerColor.label}',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tâm ${_face.centerColor.label.toLowerCase()} hướng vào camera. '
                        'Tâm ${_face.topFace.centerColor.label.toLowerCase()} ở phía trên.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      if (_draft == null) ...[
                        SizedBox(
                          height: (constraints.maxHeight * .58).clamp(
                            150.0,
                            360.0,
                          ),
                          child: Center(
                            child: _ready
                                ? RubikScanPreview(
                                    controller: _camera.controller,
                                    aspect: _camera.previewAspect,
                                  )
                                : _error == null
                                ? const CircularProgressIndicator()
                                : const Icon(
                                    Icons.no_photography_outlined,
                                    size: 64,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Giữ điện thoại dọc. Căn mặt Rubik thẳng, khớp 9 ô trong khung; tránh bóng và lóa.',
                          textAlign: TextAlign.center,
                        ),
                      ] else ...[
                        if (_thumbnail != null) ...[
                          const Text('Vùng ảnh đã lấy mẫu'),
                          const SizedBox(height: 6),
                          Image.memory(
                            _thumbnail!,
                            width: 130,
                            height: 130,
                            gaplessPlayback: true,
                          ),
                          const SizedBox(height: 12),
                        ],
                        const Text('Chạm ô để sửa màu trước khi xác nhận.'),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 240,
                          child: RubikScanFaceGrid(
                            colors: _draft!,
                            uncertain: _uncertain,
                            onEdit: _busy ? null : _edit,
                          ),
                        ),
                        if (_uncertain.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              'Ô có dấu ? cần kiểm tra kỹ.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        if (_draft![4] != _face.centerColor)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Tâm phải là màu ${_face.centerColor.label.toLowerCase()}. Kiểm tra đúng mặt trước khi xác nhận.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                      if (_scan.confirmed.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          children: [
                            for (final face in CubeState.definitionOrder.where(
                              _scan.confirmed.contains,
                            ))
                              ActionChip(
                                label: Text('Sửa ${face.code}'),
                                onPressed: _busy ? null : () => _review(face),
                              ),
                          ],
                        ),
                    ],
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    if (!_ready &&
                        _draft == null &&
                        !_summary &&
                        _error != null)
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () {
                                setState(() => _error = null);
                                _syncCamera();
                              },
                        child: const Text('Thử lại'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
