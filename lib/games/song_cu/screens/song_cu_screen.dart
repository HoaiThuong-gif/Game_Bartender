import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/song_cu_controller.dart';
import '../widgets/song_cu_tv_view.dart';

class SongCuScreen extends StatefulWidget {
  const SongCuScreen({super.key});

  @override
  State<SongCuScreen> createState() => _SongCuScreenState();
}

class _SongCuScreenState extends State<SongCuScreen>
    with WidgetsBindingObserver {
  final _game = SongCuController();
  bool _overlay = false, _leaving = false, _foreground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _foreground = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    _game.setActive(_foreground);
    unawaited(_game.load());
  }

  void _setOverlay(bool value) {
    if (!mounted) return;
    setState(() => _overlay = value);
    _game.setActive(!_overlay && !_leaving && _foreground);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _game.setActive(!_overlay && !_leaving && _foreground);
  }

  Future<void> _help() async {
    _setOverlay(true);
    var hint = _game.hint();
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: const Text('Dùng chiếc TV cũ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bật NGUỒN. Núm trên chuyển kênh, núm dưới chỉnh âm lượng. Remote có cùng chức năng. Tìm chương trình có đèn lồng rồi kéo anten cho hình rõ và ổn định.',
                ),
                const SizedBox(height: 12),
                const Text(
                  'Chạm mặt nóc TV để nhập nhịp. Nếu hình tối ngắt quãng khi tín hiệu đã rõ, gõ ngắn để sửa tiếp xúc. Quan sát đèn lồng phát nhịp rồi gõ lại: chạm ngắn là chấm, giữ lâu là gạch. Một số lượt chỉ cần bắt rõ chương trình.',
                ),
                const SizedBox(height: 12),
                const Text(
                  'Chạm dưới 0,4 giây: ngắn. Giữ khoảng 0,6–2 giây: dài. Khoảng nghỉ giữa các dấu tùy bạn. Có thể xóa và phát lại.',
                ),
                const SizedBox(height: 16),
                Text(hint, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => update(() => hint = _game.hint()),
              child: const Text('Gợi ý tiếp'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tiếp tục'),
            ),
          ],
        ),
      ),
    );
    _setOverlay(false);
  }

  Future<void> _settings() async {
    _setOverlay(true);
    await showDialog<void>(
      context: context,
      builder: (context) => AnimatedBuilder(
        animation: _game,
        builder: (context, _) => AlertDialog(
          title: const Text('Âm thanh & hỗ trợ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Âm thanh nhẹ'),
                  value: _game.sound,
                  onChanged: (v) => _game.settings(audio: v),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Âm lượng'),
                ),
                Slider(
                  value: _game.volume,
                  max: .5,
                  divisions: 10,
                  label: '${(_game.volume * 200).round()}%',
                  onChanged: (v) => _game.settings(gain: v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Giảm chuyển động'),
                  subtitle: const Text(
                    'Giảm nhiễu động và phản hồi rung của TV.',
                  ),
                  value: _game.reduceMotion,
                  onChanged: (v) => _game.settings(reduced: v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Hiện ký hiệu hỗ trợ'),
                  subtitle: const Text(
                    'Hiện nhịp chấm / gạch trên remote sau khi xem trọn tín hiệu.',
                  ),
                  value: _game.rhythmAssist,
                  onChanged: (v) => _game.settings(assist: v),
                ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Xong'),
            ),
          ],
        ),
      ),
    );
    _setOverlay(false);
  }

  Future<void> _restart() async {
    _setOverlay(true);
    final reset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bắt lại tín hiệu từ đầu?'),
        content: const Text(
          'Cài đặt và buổi phát sóng đã hoàn thành vẫn được giữ.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tiếp tục'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Chơi lại'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (reset == true) _game.restart();
    _setOverlay(false);
  }

  void _back() {
    if (_leaving) return;
    setState(() => _leaving = true);
    _game.setActive(false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _game.dispose();
    super.dispose();
  }

  Widget _remote() {
    final enabled = _game.state.powered && !_game.state.complete;
    final editing = enabled && !_game.state.playing && _game.phase == 'morse';
    Widget key(String label, IconData icon, VoidCallback? action) => Expanded(
      child: TextButton.icon(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 48),
          foregroundColor: const Color(0xFFF1E7D2),
          disabledForegroundColor: const Color(0xFF8F938A),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          textStyle: const TextStyle(fontSize: 12),
        ),
        onPressed: action,
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
    final marks = _game.state.entered
        .map((v) => v == '.' ? '·' : '—')
        .join(' ');
    return Container(
      constraints: const BoxConstraints(maxWidth: 380),
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      decoration: BoxDecoration(
        color: const Color(0xFF3D4640),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF7B7D6D), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFCCD0B8),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              'CH ${(_game.state.channel + 1).toString().padLeft(2, '0')}   ·   VOL ${(_game.volume * 200).round()}%'
              '${marks.isEmpty ? '' : '   |   $marks'}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF304438)),
            ),
          ),
          if (_game.rhythmAssist && _game.state.observed)
            Text(
              _game.level.rhythm.map((v) => v == '.' ? '·' : '—').join('   '),
              style: const TextStyle(color: Color(0xFFF1E7D2), fontSize: 18),
            ),
          if (_game.notice.isNotEmpty)
            Text(
              _game.notice,
              style: const TextStyle(color: Color(0xFFF1D2A5), fontSize: 12),
            ),
          Row(
            children: [
              key(
                'Kênh −',
                Icons.remove,
                enabled ? () => _game.remote('channel', -1) : null,
              ),
              key(
                'Kênh +',
                Icons.add,
                enabled ? () => _game.remote('channel', 1) : null,
              ),
              key(
                'Âm −',
                Icons.volume_down,
                _game.state.powered ? () => _game.remote('volume', -1) : null,
              ),
              key(
                'Âm +',
                Icons.volume_up,
                _game.state.powered ? () => _game.remote('volume', 1) : null,
              ),
            ],
          ),
          Row(
            children: [
              key(
                'Phát lại',
                Icons.replay,
                editing ? () => _game.remote('replay') : null,
              ),
              key(
                'Xóa',
                Icons.clear_all,
                editing ? () => _game.remote('erase') : null,
              ),
              key(
                'Lùi 1',
                Icons.backspace_outlined,
                editing ? () => _game.remote('undo') : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF526A5B)),
      scaffoldBackgroundColor: const Color(0xFFECE2D1),
    ),
    child: AnimatedBuilder(
      animation: _game,
      builder: (context, _) => PopScope(
        canPop: _leaving,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _back();
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFECE2D1),
            leading: IconButton(
              tooltip: 'Về sân nhà',
              onPressed: _back,
              icon: const Icon(Icons.arrow_back),
            ),
            title: const Text(
              'Sóng Cũ',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            actions: [
              IconButton(
                tooltip: _game.sound ? 'Tắt âm thanh' : 'Bật âm thanh',
                onPressed: _game.loaded
                    ? () => _game.settings(audio: !_game.sound)
                    : null,
                icon: Icon(
                  _game.sound
                      ? Icons.volume_up_outlined
                      : Icons.volume_off_outlined,
                ),
              ),
              IconButton(
                tooltip: 'Cách chơi',
                onPressed: _game.loaded ? _help : null,
                icon: const Icon(Icons.help_outline),
              ),
              IconButton(
                tooltip: 'Cài đặt',
                onPressed: _game.loaded ? _settings : null,
                icon: const Icon(Icons.tune),
              ),
            ],
          ),
          body: SafeArea(
            child: !_game.loaded
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Lượt ${_game.round + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Chơi lại',
                              onPressed: _restart,
                              icon: const Icon(Icons.replay),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SongCuTVView(
                          snapshot: _game.snapshot(
                            systemReducedMotion: MediaQuery.disableAnimationsOf(
                              context,
                            ),
                          ),
                          active: !_overlay && !_leaving && _foreground,
                          onAction: _game.action,
                        ),
                      ),
                      _remote(),
                      if (_game.state.complete)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _game.nextBroadcast,
                                  child: const Text('Kênh khác'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton(
                                  onPressed: _back,
                                  child: const Text('Đủ rồi'),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    ),
  );
}
