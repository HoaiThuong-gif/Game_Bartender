import 'package:flutter/material.dart';

import '../controllers/bartender_controller.dart';
import '../models/match_result.dart';
import '../widgets/bartender_visual_theme.dart';

/// A presentation of the existing room result. Return/exit keep Zhoufen's flow.
class BartenderResultsScreen extends StatelessWidget {
  const BartenderResultsScreen({super.key, required this.controller});
  final BartenderController controller;

  Future<void> _leave(BuildContext context) async {
    await controller.leaveRoom();
    if (context.mounted &&
        controller.room == null &&
        Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: [
        const CustomPaint(painter: BartenderBackdrop()),
        SafeArea(
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              final result = controller.room?.results;
              if (result == null) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFFE8C47D)),
                      const SizedBox(height: 20),
                      const Text(
                        'Đang tải kết quả trận đấu...',
                        style: TextStyle(color: bartenderCream, fontSize: 18),
                      ),
                      TextButton.icon(
                        key: const Key('back-to-lobby-button'),
                        onPressed: () => _leave(context),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: bartenderCream,
                        ),
                        label: const Text(
                          'THOÁT',
                          style: TextStyle(color: bartenderCream),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return LayoutBuilder(
                builder: (context, box) {
                  final wide =
                      box.maxWidth > 650 && box.maxWidth > box.maxHeight;
                  final tight = box.maxHeight < 500;
                  return Padding(
                    padding: EdgeInsets.all(tight ? 12 : 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: tight ? 44 : 52,
                              height: tight ? 44 : 52,
                              decoration: BoxDecoration(
                                color: const Color(0x22E8C47D),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0x66E8C47D),
                                ),
                              ),
                              child: const Icon(
                                Icons.local_bar_rounded,
                                color: Color(0xFFE8C47D),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '🎉 HẾT GIỜ! 🎉',
                                    style: TextStyle(
                                      color: bartenderCream,
                                      fontSize: tight ? 25 : 30,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: .8,
                                    ),
                                  ),
                                  const Text(
                                    'BẠN ĐÃ THUA GAME 😢',
                                    style: TextStyle(
                                      color: Color(0xFFB7CDBB),
                                      fontSize: 12,
                                      letterSpacing: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (controller.room!.connectedPlayerCount < 2)
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Text(
                              'Trận kết thúc sớm vì còn dưới 2 người chơi kết nối.',
                              style: TextStyle(
                                color: bartenderCream,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: wide
                              ? Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: _summary(result, tight),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(flex: 6, child: _ranking(result)),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _summary(result, tight),
                                    const SizedBox(height: 12),
                                    Expanded(child: _ranking(result)),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: tight ? 46 : 52,
                                child: OutlinedButton.icon(
                                  key: const Key('back-to-lobby-button'),
                                  onPressed: () => _leave(context),
                                  icon: const Icon(
                                    Icons.logout_rounded,
                                    size: 19,
                                  ),
                                  label: const Text('THOÁT'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: bartenderCream,
                                    side: const BorderSide(
                                      color: Color(0x667CB295),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: tight ? 46 : 52,
                                child: FilledButton.icon(
                                  key: const Key('play-again-button'),
                                  onPressed: controller.isBusy
                                      ? null
                                      : controller.returnToLobby,
                                  icon: const Icon(
                                    Icons.meeting_room_rounded,
                                    size: 21,
                                  ),
                                  label: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      controller.isBusy
                                          ? 'Đang vào...'
                                          : 'QUAY LẠI PHÒNG',
                                    ),
                                  ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFF1CE88),
                                    foregroundColor: bartenderInk,
                                    textStyle: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  );

  Widget _summary(MatchResult result, bool tight) => Container(
    padding: EdgeInsets.all(tight ? 12 : 18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFF9E9), Color(0xFFFFE9B8)],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFF3CC7E), width: 1.5),
      boxShadow: const [
        BoxShadow(
          color: Color(0x30000000),
          blurRadius: 16,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE2C0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'THÀNH QUẢ CẢ ĐỘI',
              style: TextStyle(
                color: Color(0xFF806438),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BartenderTrophy(width: tight ? 76 : 98),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                children: [
                  Text(
                    '${result.totalTeamOrders}',
                    style: TextStyle(
                      color: bartenderGreen,
                      fontSize: tight ? 46 : 62,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'ĐƠN HOÀN THÀNH',
                      style: TextStyle(
                        color: bartenderInk,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0x66FFFFFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x22B78F4A)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.timer_outlined,
                color: Color(0xFF947345),
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                '${result.totalSurvivalSeconds}s',
                style: const TextStyle(
                  color: bartenderInk,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  'cùng giữ quầy',
                  style: TextStyle(color: Color(0xFF947345), fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _ranking(MatchResult result) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF6EEDB),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0x44F5E0AA)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.leaderboard_rounded, color: bartenderGreen, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'BẢNG XẾP HẠNG',
                style: TextStyle(
                  color: bartenderInk,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            itemCount: result.ranking.length,
            separatorBuilder: (_, _) => const SizedBox(height: 7),
            itemBuilder: (context, index) {
              final player = result.ranking[index],
                  me = player.id == controller.myPlayerId;
              final first = index == 0;
              final accent = first ? const Color(0xFFAA7938) : bartenderGreen;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: first
                        ? [const Color(0xFFFFF0C5), const Color(0xFFFFE3A2)]
                        : me
                        ? [const Color(0xFFDEEEE1), const Color(0xFFE8F2E5)]
                        : [const Color(0xFFFFFCF1), const Color(0xFFFFF8E8)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: first
                        ? const Color(0xFFD9B768)
                        : me
                        ? const Color(0xFF7DA98C)
                        : const Color(0xFFE6DBC3),
                    width: first || me ? 1.4 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 31,
                      height: 31,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: first
                            ? const Color(0xFFE5B65D)
                            : const Color(0xFFE9E3D2),
                        border: Border.all(
                          color: const Color(0xFFFAF0D6),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '${index + 1}'.padLeft(2, '0'),
                        style: TextStyle(
                          color: first
                              ? const Color(0xFF6B451C)
                              : const Color(0xFF8B806B),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              player.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: bartenderInk,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (me) ...[
                            const SizedBox(width: 4),
                            const Text(
                              '(Bạn)',
                              style: TextStyle(
                                color: bartenderGreen,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      '${player.completedOrders} đơn',
                      style: TextStyle(
                        color: accent,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
