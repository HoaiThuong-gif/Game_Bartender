import 'package:flutter/material.dart';

import '../controllers/bartender_controller.dart';

/// Màn hình lobby Bartender — chờ người chơi và bắt đầu trận.
///
/// Xem PROJECT_SPEC.md mục "Phòng & người chơi":
/// "Trận có thể bắt đầu khi có từ 2 người trở lên trong phòng."
///
/// Trong chế độ FakeRoomRepository, phòng tự động có host + bot,
/// nên luôn đủ 2+ người.
class BartenderLobbyScreen extends StatefulWidget {
  const BartenderLobbyScreen({
    super.key,
    required this.controller,
  });

  final BartenderController controller;

  @override
  State<BartenderLobbyScreen> createState() => _BartenderLobbyScreenState();
}

class _BartenderLobbyScreenState extends State<BartenderLobbyScreen> {
  final _nameController = TextEditingController(text: 'Bạn');
  int _playerCount = 3;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text(
          'QUẦY BARTENDER',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: ctrl,
        builder: (context, _) {
          final room = ctrl.room;

          // Chưa tạo phòng => hiện form tạo phòng
          if (room == null) {
            return _buildCreateRoomForm(ctrl);
          }

          // Đã tạo phòng => hiện danh sách người chơi + nút bắt đầu
          return _buildLobby(ctrl);
        },
      ),
    );
  }

  Widget _buildCreateRoomForm(BartenderController ctrl) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🍸',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            const Text(
              'PHA CHẾ CÙNG ĐỒNG ĐỘI',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tạo phòng, chọn số đồng đội, và bắt đầu pha chế!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 32),

            // Tên người chơi
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Tên của bạn',
                labelStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.person, color: Colors.amberAccent),
                filled: true,
                fillColor: const Color(0xFF1E1E2C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.amberAccent),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Chọn số người chơi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2C),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.group, color: Colors.amberAccent, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Số người chơi',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  Row(
                    children: [2, 3, 4].map((n) {
                      final isSelected = _playerCount == n;
                      return Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: ChoiceChip(
                          label: Text('$n'),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _playerCount = n),
                          selectedColor: Colors.amberAccent,
                          backgroundColor: const Color(0xFF2C2C40),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                          side: BorderSide.none,
                          visualDensity: VisualDensity.compact,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Nút tạo phòng
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: ctrl.isBusy
                    ? null
                    : () {
                        ctrl.createRoom(
                          playerName: _nameController.text,
                          totalPlayers: _playerCount,
                        );
                      },
                icon: const Icon(Icons.add_circle_outline),
                label: Text(
                  ctrl.isBusy ? 'Đang tạo...' : 'TẠO PHÒNG',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
              ),
            ),

            // Thông báo lỗi
            if (ctrl.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                ctrl.errorMessage!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLobby(BartenderController ctrl) {
    final room = ctrl.room!;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Mã phòng
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2C2540), Color(0xFF1F1D30)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'MÃ PHÒNG',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  room.code,
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 8,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Danh sách người chơi
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'NGƯỜI CHƠI:',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: room.totalPlayerCount,
              itemBuilder: (context, index) {
                final player = room.players.values.elementAt(index);
                final isMe = player.id == ctrl.myPlayerId;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? Colors.deepPurple.withValues(alpha: 0.3)
                        : const Color(0xFF1E1E2C),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isMe
                          ? Colors.deepPurpleAccent
                          : Colors.white12,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            isMe ? Colors.deepPurple : Colors.blueGrey,
                        child: Text(
                          '${player.ringIndex + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
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
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              isMe ? 'Bạn (Host)' : 'Bot',
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.circle,
                        size: 10,
                        color: player.connected
                            ? Colors.greenAccent
                            : Colors.grey,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Nút bắt đầu
          if (room.canStart)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: ctrl.isBusy ? null : ctrl.startMatch,
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  ctrl.isBusy ? 'Đang bắt đầu...' : 'BẮT ĐẦU TRẬN ĐẤU!',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
              ),
            ),

          if (ctrl.noticeMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              ctrl.noticeMessage!,
              style: const TextStyle(
                color: Colors.amberAccent,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
