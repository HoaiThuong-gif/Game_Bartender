import 'package:flutter/material.dart';

import '../bartender_config.dart';
import '../controllers/bartender_controller.dart';

/// Màn hình lobby Bartender — chờ người chơi và bắt đầu trận.
///
/// Xem PROJECT_SPEC.md mục "Phòng & người chơi":
/// "Trận có thể bắt đầu khi có từ 2 người trở lên trong phòng."
///
/// Trong chế độ FakeRoomRepository, phòng tự động có host + bot,
/// nên luôn đủ 2+ người.
///
/// Trong chế độ FirebaseRoomRepository, người chơi thứ 2+ dùng tab
/// "Vào phòng" để nhập mã 4 chữ số và gọi [BartenderController.joinRoom].
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
  final _codeController = TextEditingController();
  /// 0 = tab Tạo phòng, 1 = tab Vào phòng.
  /// Trong chế độ Fake, tab "Vào phòng" ẩn vì Fake không hỗ trợ mã phòng thật.
  int _selectedTab = 0;
  int _playerCount = 3;

  bool get _isRealMode => !BartenderConfig.useFakeRepository;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
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
        actions: [
          // Nút rời phòng ở app bar khi đã vào phòng
          ListenableBuilder(
            listenable: ctrl,
            builder: (context, _) {
              if (ctrl.room == null) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.logout, color: Colors.white70),
                tooltip: 'Rời phòng',
                onPressed: ctrl.isBusy ? null : ctrl.leaveRoom,
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: ctrl,
        builder: (context, _) {
          final room = ctrl.room;

          // Chưa tạo phòng => hiện form tạo / vào phòng
          if (room == null) {
            return _buildSetupForm(ctrl);
          }

          // Đã tạo/vào phòng => hiện danh sách người chơi + nút bắt đầu
          return _buildLobby(ctrl);
        },
      ),
    );
  }

  // ─── Form tạo / vào phòng ────────────────────────────────────

  Widget _buildSetupForm(BartenderController ctrl) {
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
            Text(
              _selectedTab == 0
                  ? 'Tạo phòng, chọn số đồng đội, và bắt đầu pha chế!'
                  : 'Nhập mã 4 chữ số của phòng để tham gia!',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 32),

            // Tab selector (chỉ hiện khi dùng Firebase thật)
            if (_isRealMode) ...[
              _buildTabSelector(),
              const SizedBox(height: 20),
            ],

            // Tên người chơi (dùng chung cả 2 tab)
            _buildNameField(),
            const SizedBox(height: 16),

            // Nội dung theo tab
            if (_selectedTab == 0)
              _buildCreateTab(ctrl)
            else
              _buildJoinTab(ctrl),

            // Thông báo lỗi
            if (ctrl.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                ctrl.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTab(index: 0, label: 'Tạo phòng'),
          _buildTab(index: 1, label: 'Vào phòng'),
        ],
      ),
    );
  }

  Widget _buildTab({required int index, required String label}) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.amberAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextField(
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
    );
  }

  Widget _buildCreateTab(BartenderController ctrl) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Chọn số người chơi (chỉ có ý nghĩa với Fake; Firebase tự detect)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
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

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: ctrl.isBusy
                ? null
                : () {
                    ctrl.createRoom(
                      playerName: _nameController.text.trim().isEmpty
                          ? 'Bạn'
                          : _nameController.text.trim(),
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
      ],
    );
  }

  Widget _buildJoinTab(BartenderController ctrl) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Nhập mã phòng
        TextField(
          key: const Key('bartender_code_field'),
          controller: _codeController,
          style: const TextStyle(
            color: Colors.amberAccent,
            fontSize: 22,
            letterSpacing: 8,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: InputDecoration(
            labelText: 'Mã phòng (4 chữ số)',
            labelStyle: const TextStyle(color: Colors.white54),
            hintText: '1234',
            hintStyle: const TextStyle(color: Colors.white24, letterSpacing: 8),
            prefixIcon: const Icon(Icons.vpn_key, color: Colors.amberAccent),
            filled: true,
            fillColor: const Color(0xFF1E1E2C),
            counterStyle: const TextStyle(color: Colors.white38),
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

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: ctrl.isBusy
                ? null
                : () {
                    final code = _codeController.text.trim();
                    if (code.isEmpty) return;
                    ctrl.joinRoom(
                      code: code,
                      playerName: _nameController.text.trim().isEmpty
                          ? 'Bạn'
                          : _nameController.text.trim(),
                    );
                  },
            icon: const Icon(Icons.login),
            label: Text(
              ctrl.isBusy ? 'Đang vào...' : 'VÀO PHÒNG',
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
      ],
    );
  }

  // ─── Màn chờ sau khi tạo / vào phòng ──────────────────────────

  Widget _buildLobby(BartenderController ctrl) {
    final room = ctrl.room!;
    final myId = ctrl.myPlayerId;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Mã phòng — hiện để người chơi khác nhập vào
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
                final isMe = player.id == myId;
                final isHost = player.ringIndex == 0;

                // Nhãn vai trò:
                // - Bạn (Host) / Bạn nếu là mình
                // - Bot nếu tên bắt đầu bằng 'Bot' (FakeRepository)
                // - Host / Đồng đội nếu là người thật khác
                final String roleLabel;
                if (isMe) {
                  roleLabel = isHost ? 'Bạn (Host)' : 'Bạn';
                } else if (player.name.startsWith('Bot') ||
                    player.id.startsWith('bot_')) {
                  roleLabel = 'Bot';
                } else {
                  roleLabel = isHost ? 'Host' : 'Đồng đội';
                }

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
                                color:
                                    isMe ? Colors.amberAccent : Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              roleLabel,
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

          // Nút bắt đầu (chỉ host thấy khi đủ người)
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
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Đang chờ người chơi... (${room.connectedPlayerCount}/2 tối thiểu)',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),
          const SizedBox(height: 8),

          // Nút rời phòng
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: ctrl.isBusy ? null : ctrl.leaveRoom,
              icon: const Icon(Icons.exit_to_app, size: 18),
              label: const Text('RỜI PHÒNG'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          if (ctrl.noticeMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              ctrl.noticeMessage!,
              textAlign: TextAlign.center,
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
