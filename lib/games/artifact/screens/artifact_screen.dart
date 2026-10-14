import 'package:flutter/material.dart';

import '../controllers/artifact_controller.dart';
import '../models/artifact_puzzle.dart';
import '../widgets/artifact_3d_view.dart';

class ArtifactScreen extends StatefulWidget {
  const ArtifactScreen({super.key});
  @override
  State<ArtifactScreen> createState() => _ArtifactScreenState();
}

class _ArtifactScreenState extends State<ArtifactScreen> {
  final _game = ArtifactController();
  bool _ready = false;
  bool _busy = false;
  static const _ink = Color(0xFF4A3425);
  static const _bronze = Color(0xFF906435);
  static const _paper = Color(0xFFF6EFDF);

  void _availability({bool? ready, bool? busy}) {
    if (!mounted) return;
    if ((ready == null || ready == _ready) && (busy == null || busy == _busy)) {
      return;
    }
    setState(() {
      if (ready != null) _ready = ready;
      if (busy != null) _busy = busy;
    });
  }

  bool _move(ArtifactAction action) {
    if (_game.phase != ArtifactPhase.playing) return false;
    final accepted = _game.move(action);
    _availability(busy: accepted);
    return accepted;
  }

  void _reset() {
    _availability(busy: false);
    _game.reset();
  }

  void _help() => showModalBottomSheet<void>(
    context: context,
    backgroundColor: _paper,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _game.level.puzzle.isMongSen
                  ? 'Mộng Sen · Khám phá các mộng khóa'
                  : 'Đọc dấu xưa, tự tháo từng cơ cấu',
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _game.level.puzzle.isMongSen
                  ? 'Vuốt vùng trống hoặc khung cố định để xoay hộp; chụm hai ngón để thu phóng.\n\n'
                        'Chạm chọn một chi tiết rồi kéo theo khe hoặc ray của nó. Kéo quanh tâm cam đồng để xoay. Khi hướng kéo gần trùng góc nhìn, hãy xoay hộp để thấy đường chuyển động rõ hơn.\n\n'
                        'Nắp có hai chuyển động: trượt đến cửa thoát rồi nhấc lên. Chạm lại nắp sau mỗi chuyển động để chọn thao tác kế tiếp.\n\n'
                        'Chi tiết đỏ lên và dừng khi bị giữ. Quan sát gờ, vai mộng và chốt để tìm nguyên nhân. Kéo chưa đủ xa hoặc thêm ngón thứ hai sẽ hủy thao tác đang kéo. Gợi ý chỉ xuất hiện khi bạn yêu cầu.'
                  : 'Vuốt vùng trống hoặc khung cố định để quan sát; chụm hai ngón để zoom.\n\n'
                        'Chạm và kéo từng bộ phận theo khe, ray hoặc quanh trục xoay. Kéo ngược để lắp lại. Xoay cổ vật để tìm chi tiết ở mặt sau và dưới đáy.\n\n'
                        'Chi tiết đỏ lên khi bị khóa. Quan sát vai mộng, cửa khuyết và chốt đang giữ nó. Gợi ý chỉ xuất hiện khi bạn yêu cầu. Đặt lại giữ nguyên cổ vật.',
              style: const TextStyle(fontSize: 15, height: 1.5, color: _ink),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tiếp tục khám phá'),
            ),
          ],
        ),
      ),
    ),
  );

  @override
  void dispose() {
    _game.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(
      scaffoldBackgroundColor: _paper,
      colorScheme: ColorScheme.fromSeed(seedColor: _bronze, surface: _paper),
      appBarTheme: const AppBarTheme(
        backgroundColor: _paper,
        foregroundColor: _ink,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _bronze,
          foregroundColor: Colors.white,
        ),
      ),
    ),
    child: AnimatedBuilder(
      animation: _game,
      builder: (context, _) {
        final puzzle = _game.level.puzzle;
        final complete = _game.phase == ArtifactPhase.complete;
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Giải Mã Cổ Vật',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            actions: [
              IconButton(
                onPressed: _help,
                tooltip: 'Cách chơi',
                icon: const Icon(Icons.help_outline),
              ),
              IconButton(
                onPressed: _ready ? _reset : null,
                tooltip: 'Đặt lại màn',
                icon: const Icon(Icons.restart_alt),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CỔ VẬT ${puzzle.level.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                color: _bronze,
                                fontSize: 11,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              puzzle.title,
                              style: const TextStyle(
                                color: _ink,
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${_game.moves} thao tác',
                            style: const TextStyle(
                              color: _ink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            puzzle.isMongSen
                                ? 'Gỗ · Đồng · Mộng khóa'
                                : 'Gỗ · Đồng · Cơ khí',
                            style: const TextStyle(
                              color: _bronze,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Artifact3DView(
                        snapshot: _game.snapshot,
                        onAction: _move,
                        onSelect: _game.select,
                        onReady: (value) => _availability(ready: value),
                        onBusy: (value) => _availability(busy: value),
                        onComplete: _game.complete,
                      ),
                      if (complete)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: _paper.withValues(alpha: .97),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFCDB58B),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.auto_awesome,
                                  color: _bronze,
                                  size: 28,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  puzzle.isMongSen
                                      ? 'Đã mở Mộng Sen'
                                      : 'Đã lấy lõi bí mật',
                                  style: const TextStyle(
                                    color: _ink,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${_game.moves} thao tác · Tối ưu ${_game.level.minimumMoves}',
                                  style: const TextStyle(color: _bronze),
                                ),
                                const SizedBox(height: 12),
                                FilledButton.icon(
                                  onPressed: puzzle.level < 5
                                      ? _game.nextLevel
                                      : _reset,
                                  icon: const Icon(Icons.arrow_forward),
                                  label: Text(
                                    puzzle.level < 5
                                        ? 'Cổ vật tiếp theo'
                                        : 'Chơi lại cổ vật 5',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_game.noticeVisible)
                        Text(
                          _game.notice,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      if (_game.phase == ArtifactPhase.playing)
                        TextButton.icon(
                          onPressed: _ready ? _game.hint : null,
                          icon: const Icon(Icons.lightbulb_outline, size: 17),
                          label: const Text('Gợi ý'),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      if (_game.phase == ArtifactPhase.opening)
                        const Padding(
                          padding: EdgeInsets.all(8),
                          child: LinearProgressIndicator(
                            color: _bronze,
                            backgroundColor: Color(0xFFE5D6BC),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
