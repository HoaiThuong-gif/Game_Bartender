import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/rubik_interactive_preview.dart';
import '../../widgets/rubik_theme.dart';
import '../controllers/rubik_challenge_controller.dart';
import '../models/rubik_room.dart';
import '../services/rubik_challenge_service.dart';

class RubikChallengeRoomScreen extends StatefulWidget {
  const RubikChallengeRoomScreen({
    super.key,
    required this.repository,
    required this.code,
    this.cubeBuilder,
  });
  final RubikChallengeRepository repository;
  final String code;
  final Widget Function(BuildContext, RubikChallengeController)? cubeBuilder;
  @override
  State<RubikChallengeRoomScreen> createState() => _RoomState();
}

class _RoomState extends State<RubikChallengeRoomScreen>
    with WidgetsBindingObserver {
  late final c = RubikChallengeController(widget.repository, widget.code);
  bool _leaving = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed ||
        state == AppLifecycleState.paused) {
      unawaited(
        widget.repository
            .presence(widget.code, state == AppLifecycleState.resumed)
            .catchError((Object _) {}),
      );
    }
  }

  Future<void> _leave() async {
    if (_leaving) return;
    setState(() => _leaving = true);
    try {
      await c.leave().timeout(const Duration(seconds: 5));
    } catch (_) {
      /* onDisconnect and maintenance resolve an offline departure. */
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RubikTheme(
    child: PopScope(
      canPop: _leaving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_leave());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.repository.demo
                ? 'THỬ 1V1 • ${widget.code}'
                : 'PHÒNG ${widget.code}',
          ),
          actions: [
            IconButton(
              tooltip: 'Sao chép mã phòng',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: widget.code));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã sao chép mã phòng')),
                );
              },
              icon: const Icon(Icons.copy),
            ),
          ],
        ),
        body: SafeArea(
          child: AnimatedBuilder(
            animation: c,
            builder: (context, _) {
              final room = c.room;
              if (room == null) {
                return Center(child: Text(c.error ?? 'Đang tải phòng…'));
              }
              if (!room.players.containsKey(widget.repository.uid)) {
                return const Center(
                  child: Text(
                    'Bạn đã rời phòng. Hãy về sảnh để tạo hoặc tham gia lại.',
                  ),
                );
              }
              if (room.status == ChallengeStatus.finished) return _result(room);
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        for (final entry in room.players.entries)
                          Expanded(child: _player(entry.key, entry.value)),
                        if (room.players.length == 1)
                          const Expanded(
                            child: Text(
                              'Đang chờ đối thủ…',
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (room.scramble.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.extension_outlined,
                              size: 80,
                              color: Color(0xFF1670D2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              room.status == ChallengeStatus.waiting
                                  ? 'Gửi mã ${room.code} cho bạn của bạn'
                                  : 'Cả hai sẵn sàng để bắt đầu',
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          widget.cubeBuilder?.call(context, c) ??
                              RubikInteractivePreview(
                                key: ValueKey('challenge-${room.round}'),
                                challengeMoves: room.scramble,
                                interactionEnabled:
                                    c.playing &&
                                    c.me?.finished != true &&
                                    c.me?.dnf != true,
                                onPrepared: c.cubePrepared,
                                onSolved: c.cubeSolved,
                              ),
                          if (!c.prepared)
                            const Center(child: CircularProgressIndicator()),
                          if (room.startAt != null && c.countdown > 0)
                            IgnorePointer(
                              child: Center(
                                child: Text(
                                  c.countdown > 3
                                      ? 'Chuẩn bị'
                                      : '${c.countdown}',
                                  style: const TextStyle(
                                    fontSize: 64,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF155A91),
                                  ),
                                ),
                              ),
                            ),
                          if (c.playing && c.elapsed < 800)
                            const IgnorePointer(
                              child: Center(
                                child: Text(
                                  'GO',
                                  style: TextStyle(
                                    fontSize: 64,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF155A91),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  Text(
                    challengeTime(c.me?.finishMs ?? c.elapsed),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (c.error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        c.error!,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: room.scramble.isEmpty
                          ? FilledButton(
                              onPressed:
                                  room.status == ChallengeStatus.ready &&
                                      c.me?.ready != true &&
                                      !c.busy
                                  ? () => c.action('ready')
                                  : null,
                              child: Text(
                                c.me?.ready == true
                                    ? 'Đã sẵn sàng • Chờ đối thủ'
                                    : 'Sẵn sàng',
                              ),
                            )
                          : room.status == ChallengeStatus.ready && c.prepared
                          ? FilledButton(
                              onPressed: c.busy
                                  ? null
                                  : () => c.action('loaded'),
                              child: const Text('Đề đã tải • Chờ đối thủ'),
                            )
                          : FilledButton(
                              onPressed:
                                  c.playing &&
                                      c.solved &&
                                      c.prepared &&
                                      !c.busy &&
                                      !c.finishPending &&
                                      c.me?.finished != true &&
                                      c.me?.dnf != true
                                  ? () => c.action('finish')
                                  : null,
                              child: Text(
                                c.me?.finished == true
                                    ? 'Đã hoàn thành • Chờ đối thủ'
                                    : c.me?.dnf == true
                                    ? 'DNF • Chờ kết quả'
                                    : c.finishPending
                                    ? 'Đang ghi nhận…'
                                    : 'Hoàn thành',
                              ),
                            ),
                    ),
                  ),
                  if (c.playing && c.me?.finished != true)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Giải xong cube để bật Hoàn thành • Tối đa 5 phút',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
  Widget _player(String uid, ChallengePlayer p) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        uid == widget.repository.uid ? 'Bạn • ${p.name}' : p.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(
        p.dnf
            ? 'DNF'
            : p.finished
            ? challengeTime(p.finishMs ?? 0)
            : c.playing
            ? 'Đang giải'
            : p.ready
            ? 'Sẵn sàng'
            : 'Chưa sẵn sàng',
      ),
    ],
  );
  Widget _result(RubikRoom room) {
    final winner = room.winnerId;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(
          Icons.emoji_events_outlined,
          size: 80,
          color: Color(0xFF1670D2),
        ),
        const SizedBox(height: 16),
        Text(
          winner == widget.repository.uid
              ? 'CHIẾN THẮNG'
              : winner == 'draw'
              ? 'HÒA'
              : winner == 'none'
              ? 'TRẬN KẾT THÚC • DNF'
              : 'Đối thủ chiến thắng',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        for (final entry in room.players.entries)
          ListTile(
            title: Text(
              entry.key == widget.repository.uid
                  ? 'Bạn • ${entry.value.name}'
                  : entry.value.name,
            ),
            trailing: Text(
              entry.value.dnf
                  ? 'DNF'
                  : challengeTime(entry.value.finishMs ?? 0),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          '+${room.rewards[widget.repository.uid] ?? 0} cá${widget.repository.demo ? ' (mô phỏng)' : ''}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        if (!widget.repository.demo)
          Text(
            c.rewardSynced ? 'Đã nhận vào ví Gacha' : 'Đang chờ nhận thưởng',
            textAlign: TextAlign.center,
          ),
        if (!c.rewardSynced && !widget.repository.demo)
          TextButton(
            onPressed: c.syncRewards,
            child: const Text('Nhận thưởng / thử lại'),
          ),
        if (c.error != null)
          Text(c.error!, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 24),
        FilledButton(
          onPressed:
              c.busy ||
                  c.me?.rematch == true ||
                  room.players.values.any((p) => p.left)
              ? null
              : () => c.action('rematch'),
          child: Text(
            c.me?.rematch == true ? 'Chờ đối thủ chơi lại' : 'Chơi lại',
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _leaving ? null : _leave,
          child: const Text('Về sảnh'),
        ),
      ],
    );
  }
}
