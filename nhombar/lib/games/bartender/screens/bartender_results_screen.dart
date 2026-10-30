import '../../../settings/app_theme.dart';

import 'package:flutter/material.dart';

import '../controllers/bartender_controller.dart';

/// Màn hình kết quả trận đấu Bartender.
///
/// Xem PROJECT_SPEC.md & API.md:
/// - Hiển thị xếp hạng người chơi, số đơn mỗi người, tổng đơn cả đội, thời gian sống sót.
/// - Xử lý trường hợp results đang tải / chưa có (kèm nút quay về lobby).
/// - Thông báo rõ khi trận kết thúc do < 2 người chơi kết nối (D14).
/// - Nút "VỀ LOBBY" để dọn dẹp và quay về sảnh chính.
/// - Đảm bảo không tràn bố cục ở 360x640 và 390x844.
class BartenderResultsScreen extends StatelessWidget {
  const BartenderResultsScreen({super.key, required this.controller});

  final BartenderController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.arenaBackground,
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final results = controller.room?.results;

          // Xử lý khi results chưa có (đang chờ đồng bộ từ repository)
          if (results == null) {
            return SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.amberAccent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Đang tải kết quả trận đấu...',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        key: const Key('back-to-lobby-button'),
                        onPressed: () {
                          controller.leaveRoom();
                          Navigator.of(context).maybePop();
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Quay về lobby'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final isEarlyEndDueToDisconnect =
              controller.room != null &&
              controller.room!.connectedPlayerCount < 2;

          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxHeight < 700;
                final pad = isSmall ? 14.0 : 20.0;
                final spacing = isSmall ? 10.0 : 16.0;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: pad, vertical: 8),
                  child: Column(
                    children: [
                      SizedBox(height: isSmall ? 4 : 12),

                      // Tiêu đề kết thúc
                      Text(
                        '🎉 HẾT GIỜ! 🎉',
                        style: TextStyle(
                          color: Colors.amberAccent,
                          fontSize: isSmall ? 22 : 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'KẾT QUẢ TRẬN ĐẤU',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: spacing),

                      // Cảnh báo nếu trận kết thúc vì < 2 người chơi
                      if (isEarlyEndDueToDisconnect)
                        Container(
                          margin: EdgeInsets.only(bottom: spacing),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade900.withValues(
                              alpha: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.orangeAccent.withValues(alpha: 0.5),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.orangeAccent,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Trận kết thúc sớm vì còn dưới 2 người chơi kết nối.',
                                  style: TextStyle(
                                    color: Colors.orangeAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Thống kê tổng quan (thời gian sống sót & tổng đơn cả đội)
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.timer,
                              label: 'THỜI GIAN\nSỐNG SÓT',
                              value: '${results.totalSurvivalSeconds}s',
                              color: Colors.cyanAccent,
                              isSmall: isSmall,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.local_bar,
                              label: 'TỔNG ĐƠN\nCẢ ĐỘI',
                              value: '${results.totalTeamOrders}',
                              color: Colors.amberAccent,
                              isSmall: isSmall,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: spacing),

                      // Tiêu đề bảng xếp hạng
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '🏆 BẢNG XẾP HẠNG',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Danh sách xếp hạng
                      Expanded(
                        child: ListView.builder(
                          itemCount: results.ranking.length,
                          itemBuilder: (context, index) {
                            final player = results.ranking[index];
                            final isMe = player.id == controller.myPlayerId;
                            final medal = index == 0
                                ? '🥇'
                                : index == 1
                                ? '🥈'
                                : index == 2
                                ? '🥉'
                                : '#${index + 1}';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: isSmall ? 8 : 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: isMe
                                    ? LinearGradient(
                                        colors: [
                                          Colors.deepPurple.withValues(
                                            alpha: 0.4,
                                          ),
                                          Colors.deepPurple.withValues(
                                            alpha: 0.2,
                                          ),
                                        ],
                                      )
                                    : null,
                                color: isMe ? null : AppTheme.arenaSurface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isMe
                                      ? Colors.deepPurpleAccent
                                      : Colors.white12,
                                  width: isMe ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Thứ hạng / Huy chương
                                  SizedBox(
                                    width: 36,
                                    child: Text(
                                      medal,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: index < 3 ? 20 : 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // Tên người chơi
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            player.name,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: isMe
                                                  ? Colors.amberAccent
                                                  : Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        if (isMe) ...[
                                          const SizedBox(width: 4),
                                          const Text(
                                            '(Bạn)',
                                            style: TextStyle(
                                              color: Colors.white38,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  // Số đơn hoàn thành của cá nhân
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${player.completedOrders} đơn',
                                      style: const TextStyle(
                                        color: Colors.amberAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: spacing),

                      // Nút hành động: Quay về lobby và Chơi lại
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: OutlinedButton.icon(
                                key: const Key('back-to-lobby-button'),
                                onPressed: () {
                                  controller.leaveRoom();
                                  Navigator.of(context).maybePop();
                                },
                                icon: const Icon(Icons.arrow_back, size: 16),
                                label: const Text(
                                  'VỀ LOBBY',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white70,
                                  side: const BorderSide(color: Colors.white24),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 44,
                              child: ElevatedButton.icon(
                                key: const Key('play-again-button'),
                                onPressed: controller.isBusy
                                    ? null
                                    : controller.playAgain,
                                icon: const Icon(Icons.replay, size: 16),
                                label: Text(
                                  controller.isBusy
                                      ? 'Đang tạo...'
                                      : 'CHƠI LẠI!',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amberAccent,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmall ? 4 : 8),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isSmall,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: isSmall ? 8 : 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: isSmall ? 22 : 26),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: isSmall ? 18 : 22,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
