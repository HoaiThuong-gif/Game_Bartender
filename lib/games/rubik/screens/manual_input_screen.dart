import 'package:flutter/material.dart';

import '../controllers/cube_input_controller.dart';
import '../models/cube_state.dart';
import '../models/rubik_face.dart';
import '../widgets/rubik_palette.dart';
import '../widgets/rubik_theme.dart';
import '../widgets/rubik_preview_panel.dart';
import 'solution_screen.dart';

class ManualInputScreen extends StatefulWidget {
  const ManualInputScreen({super.key, this.previewBuilder});
  final CubePreviewBuilder? previewBuilder;

  @override
  State<ManualInputScreen> createState() => _ManualInputScreenState();
}

class _ManualInputScreenState extends State<ManualInputScreen> {
  final _controller = CubeInputController();
  int _faceIndex = 0;
  RubikColor? _selected = RubikColor.white;
  bool _showingSolution = false;
  RubikFace get _face => CubeState.definitionOrder[_faceIndex];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _changeFace(int delta) => setState(() {
    _faceIndex += delta;
    _selected = _face.centerColor;
  });

  Future<void> _solve() async {
    final moves = await _controller.solve();
    if (!mounted) return;
    if (moves == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.error ?? 'Chưa tìm được lời giải.')),
      );
      return;
    }
    setState(() => _showingSolution = true);
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SolutionScreen(
          moves: moves,
          initialState: _controller.state,
          previewBuilder: widget.previewBuilder,
        ),
      ),
    );
    if (mounted) setState(() => _showingSolution = false);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _controller,
    builder: (context, _) {
      final state = _controller.state;
      final busy = _controller.busy;
      return RubikTheme(
        child: Scaffold(
          backgroundColor: const Color(0xFFF3F5FA),
          appBar: AppBar(
            title: const Text('Nhập màu Rubik'),
            backgroundColor: const Color(0xFFF3F5FA),
            actions: [
              IconButton(
                tooltip: 'Reset trạng thái',
                onPressed: busy
                    ? null
                    : () {
                        _controller.reset();
                        setState(() {
                          _faceIndex = 0;
                          _selected = RubikColor.white;
                        });
                      },
                icon: const Icon(Icons.restart_alt),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: busy || _faceIndex == 0
                        ? null
                        : () => _changeFace(-1),
                    child: const Text('Mặt trước'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    key: const ValueKey('next-face'),
                    onPressed: busy
                        ? null
                        : _faceIndex == 5
                        ? _solve
                        : () => _changeFace(1),
                    child: Text(
                      busy
                          ? 'Đang giải…'
                          : _faceIndex == 5
                          ? 'Kiểm tra & Giải'
                          : 'Mặt tiếp theo',
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => Column(
                children: [
                  SizedBox(
                    height: (constraints.maxHeight * 0.30).clamp(80.0, 230.0),
                    child: RubikPreviewPanel(
                      state: state,
                      builder: widget.previewBuilder,
                      active: !_showingSolution,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: Column(
                            children: [
                              Text(
                                '${_face.centerColor.label} · ${_face.code}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: (constraints.maxHeight * 0.38)
                                      .clamp(180.0, 260.0),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF202A40),
                                      borderRadius: BorderRadius.circular(22),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x220F172A),
                                          blurRadius: 18,
                                          offset: Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: GridView.count(
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 6,
                                      crossAxisSpacing: 6,
                                      padding: EdgeInsets.zero,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      children: [
                                        for (var i = 0; i < 9; i++)
                                          Semantics(
                                            label:
                                                'Ô ${_face.code}${i + 1}: ${state.stickers(_face)[i]?.label ?? "Chưa nhập"}',
                                            child: OutlinedButton(
                                              key: ValueKey(
                                                'sticker-${_face.code}-$i',
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                backgroundColor:
                                                    state
                                                        .stickers(_face)[i]
                                                        ?.paint ??
                                                    const Color(0xFFCBD3DF),
                                                disabledBackgroundColor:
                                                    state
                                                        .stickers(_face)[i]
                                                        ?.paint ??
                                                    const Color(0xFFCBD3DF),
                                                side: BorderSide.none,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              onPressed: i == 4 || busy
                                                  ? null
                                                  : () =>
                                                        _controller.setSticker(
                                                          _face,
                                                          i,
                                                          _selected,
                                                        ),
                                              child: i == 4
                                                  ? const Icon(
                                                      Icons.lock_outline,
                                                      color: Colors.black54,
                                                      size: 22,
                                                    )
                                                  : state.stickers(_face)[i] ==
                                                        null
                                                  ? const Icon(
                                                      Icons.add,
                                                      color: Color(0xFF8390A5),
                                                      size: 18,
                                                    )
                                                  : null,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _selected == null
                                    ? 'Chạm ô để xóa'
                                    : 'Chọn màu, chạm ô để tô',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: RubikPalette(
                                      state: state,
                                      selected: _selected,
                                      onSelected: busy
                                          ? null
                                          : (color) => setState(
                                              () => _selected = color,
                                            ),
                                    ),
                                  ),
                                  IconButton.filledTonal(
                                    key: const ValueKey('erase-sticker'),
                                    tooltip: 'Xóa ô',
                                    isSelected: _selected == null,
                                    onPressed: busy
                                        ? null
                                        : () => setState(
                                            () => _selected = _selected == null
                                                ? _face.centerColor
                                                : null,
                                          ),
                                    icon: const Icon(Icons.auto_fix_normal),
                                    selectedIcon: const Icon(
                                      Icons.auto_fix_normal,
                                      color: Color(0xFF3346A8),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Đã nhập ${state.enteredCount}/54 ô',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              if (_controller.error != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _controller.error!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error,
                                    ),
                                  ),
                                ),
                              if (busy) const LinearProgressIndicator(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
