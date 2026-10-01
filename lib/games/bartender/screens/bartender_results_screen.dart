import 'package:flutter/material.dart';

import '../controllers/bartender_controller.dart';
import '../models/match_result.dart';

/// Màn hình kết quả trận đấu Bartender.
///
/// Xem PROJECT_SPEC.md mục "Kết thúc trận":
/// "Hiển thị tổng thời gian sống sót, tổng số đơn cả đội đã hoàn thành,
/// và bảng xếp hạng cá nhân theo số đơn đã hoàn thành."
class BartenderResultsScreen extends StatelessWidget {
  const BartenderResultsScreen({
    super.key,
    required this.controller,
  });

  final BartenderController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final results = controller.room?.results;
          if (results == null) {
            return const Center(
              child: Text(
                'Đang tải kết quả...',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Header
                  const Text(
                    '🎉 HẾT GIỜ! 🎉',
                    style: TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'KẾT QUẢ TRẬN ĐẤU',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tổng quan
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.timer,
                          label: 'THỜI GIAN\nSỐNG SÓT',
                          value: '${results.totalSurvivalSeconds}s',
                          color: Colors.cyanAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.local_bar,
                          label: 'TỔNG ĐƠN\nCẢ ĐỘI',
                          value: '${results.totalTeamOrders}',
                          color: Colors.amberAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Bảng xếp hạng
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '🏆 BẢNG XẾP HẠNG',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

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
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            gradient: isMe
                                ? LinearGradient(
                                    colors: [
                                      Colors.deepPurple.withValues(alpha: 0.4),
                                      Colors.deepPurple.withValues(alpha: 0.2),
                                    ],
                                  )
                                : null,
                            color: isMe ? null : const Color(0xFF1E1E2C),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isMe
                                  ? Colors.deepPurpleAccent
                                  : Colors.white12,
                              width: isMe ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Huy chương
                              SizedBox(
                                width: 40,
                                child: Text(
                                  medal,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: index < 3 ? 24 : 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Tên
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      player.name,
                                      style: TextStyle(
                                        color: isMe
                                            ? Colors.amberAccent
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    if (isMe)
                                      const Text(
                                        '(Bạn)',
                                        style: TextStyle(
                                          color: Colors.white38,
                                          fontSize: 11,
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // Số đơn
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${player.completedOrders} đơn',
                                  style: const TextStyle(
                                    color: Colors.amberAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Nút hành động
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              controller.leaveRoom();
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.exit_to_app),
                            label: const Text(
                              'THOÁT',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: const BorderSide(color: Colors.white24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed:
                                controller.isBusy ? null : controller.playAgain,
                            icon: const Icon(Icons.replay),
                            label: Text(
                              controller.isBusy
                                  ? 'Đang tạo...'
                                  : 'CHƠI LẠI!',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amberAccent,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
