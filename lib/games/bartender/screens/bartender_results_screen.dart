import 'package:flutter/material.dart';

import '../controllers/bartender_controller.dart';
import '../models/match_result.dart';

const _ink = Color(0xFF5B321F);
const _cream = Color(0xFFFFF4DB);
const _green = Color(0xFF287A63);

/// Presentation only: ranking and actions still come from the room controller.
class BartenderResultsScreen extends StatelessWidget {
  const BartenderResultsScreen({super.key, required this.controller});
  final BartenderController controller;

  void _leave(BuildContext context) {
    controller.leaveRoom();
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5B3020), Color(0xFFAD6839), Color(0xFF663A27)],
        ),
      ),
      child: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final result = controller.room?.results;
            if (result == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFFFFD27D)),
                    const SizedBox(height: 20),
                    const Text(
                      'Đang tải kết quả trận đấu...',
                      style: TextStyle(color: _cream, fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      key: const Key('back-to-lobby-button'),
                      onPressed: () => _leave(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Quay về lobby'),
                      style: OutlinedButton.styleFrom(foregroundColor: _cream),
                    ),
                  ],
                ),
              );
            }
            return LayoutBuilder(
              builder: (context, box) {
                final wide = box.maxWidth > 650 && box.maxWidth > box.maxHeight;
                final tight = box.maxHeight < 380;
                final summary = _summary(result, tight);
                final ranking = _ranking(result);
                return Padding(
                  padding: EdgeInsets.all(tight ? 12 : 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD27D),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.local_bar_rounded,
                              color: _ink,
                              size: tight ? 26 : 34,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '🎉 HẾT GIỜ! 🎉',
                                  style: TextStyle(
                                    color: _cream,
                                    fontSize: tight ? 24 : 30,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const Text(
                                  'CA PHA CHẾ ĐÃ KHÉP LẠI',
                                  style: TextStyle(
                                    color: Color(0xFFFFD6A2),
                                    fontSize: 13,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (controller.room!.connectedPlayerCount < 2)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Trận kết thúc sớm vì còn dưới 2 người chơi kết nối.',
                            style: TextStyle(color: _cream, fontSize: 14),
                          ),
                        ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: wide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(flex: 4, child: summary),
                                  const SizedBox(width: 16),
                                  Expanded(flex: 6, child: ranking),
                                ],
                              )
                            : Column(
                                children: [
                                  summary,
                                  const SizedBox(height: 16),
                                  Expanded(child: ranking),
                                ],
                              ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: tight ? 46 : 52,
                              child: OutlinedButton.icon(
                                key: const Key('back-to-lobby-button'),
                                onPressed: () => _leave(context),
                                icon: const Icon(Icons.arrow_back_rounded),
                                label: const Text('VỀ LOBBY'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _cream,
                                  side: const BorderSide(
                                    color: Color(0xFFE6BF8C),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
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
                                    : controller.playAgain,
                                icon: const Icon(Icons.replay_rounded),
                                label: Text(
                                  controller.isBusy
                                      ? 'Đang tạo...'
                                      : 'CHƠI LẠI!',
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFCD69),
                                  foregroundColor: _ink,
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
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
    ),
  );

  Widget _summary(MatchResult result, bool tight) => Container(
    padding: EdgeInsets.all(tight ? 10 : 20),
    decoration: BoxDecoration(
      color: _cream,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0xFFFFD27D), width: 2),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFFB87826),
              size: 20,
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'THÀNH QUẢ CẢ ĐỘI',
                style: TextStyle(
                  color: _ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        Text(
          '${result.totalTeamOrders}',
          style: TextStyle(
            color: _green,
            fontSize: tight ? 42 : 64,
            height: 1.1,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Text(
          'ĐƠN HOÀN THÀNH',
          style: TextStyle(
            color: _green,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        const Divider(color: Color(0xFFE2CBA9), height: 1),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer_outlined, color: _ink, size: 24),
            const SizedBox(width: 8),
            Text(
              '${result.totalSurvivalSeconds}s',
              style: const TextStyle(
                color: _ink,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'cùng giữ quầy',
                style: TextStyle(color: _ink, fontSize: 15),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _ranking(MatchResult result) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFFFFE6BB),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🏆 BẢNG XẾP HẠNG',
          style: TextStyle(
            color: _ink,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            itemCount: result.ranking.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final player = result.ranking[index];
              final me = player.id == controller.myPlayerId;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: me ? const Color(0xFFDAEBDD) : _cream,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: me ? _green : const Color(0xFFE3C392),
                    width: me ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      index < 3 ? ['🥇', '🥈', '🥉'][index] : '#${index + 1}',
                      style: const TextStyle(fontSize: 22, color: _ink),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 5,
                        children: [
                          Text(
                            player.name,
                            style: const TextStyle(
                              color: _ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (me)
                            const Text(
                              '(Bạn)',
                              style: TextStyle(color: _green, fontSize: 14),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${player.completedOrders} đơn',
                      style: const TextStyle(
                        color: _green,
                        fontSize: 18,
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
