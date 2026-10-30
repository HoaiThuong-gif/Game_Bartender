import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/bartender_controller.dart';
import '../models/player.dart';
import '../models/room.dart';

// Chỉ có hình nền + logo trong ảnh này. TẤT CẢ ô nhập/nút là widget Flutter.
const String _menuImage = 'assets/images/ui/menu_background.png';
const Color _coffee = Color(0xFF57290F);
const Color _brown = Color(0xFF8F4A22);

class BartenderLobbyScreen extends StatefulWidget {
  const BartenderLobbyScreen({
    super.key,
    required this.controller,
    this.playerName,
  });
  final BartenderController controller;
  final String? playerName;

  @override
  State<BartenderLobbyScreen> createState() => _BartenderLobbyScreenState();
}

class _BartenderLobbyScreenState extends State<BartenderLobbyScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _joinCode = TextEditingController();
  int _count = 3;

  @override
  void initState() {
    super.initState();
    _name.text = _roomName(widget.playerName ?? '');
  }

  @override
  void didUpdateWidget(covariant BartenderLobbyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playerName != widget.playerName) {
      _name.text = _roomName(widget.playerName ?? '');
    }
  }

  String _roomName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Người chơi';
    // The existing game API accepts at most 24 UTF-16 code units.
    var result = '';
    for (final character in trimmed.characters) {
      if (result.length + character.length > 24) break;
      result += character;
    }
    return result.isEmpty ? 'Người chơi' : result;
  }

  // Same authority as Zhoufen: host is ring 0; readiness comes from Room.
  String? _hostPlayerId(Room room) {
    for (final player in room.players.values) {
      if (player.ringIndex == 0) return player.id;
    }
    return null;
  }

  bool _isHost(BartenderController ctrl) =>
      ctrl.room != null && ctrl.myRingIndex == 0;

  bool _isBot(Player player) =>
      player.name.trim().toLowerCase().startsWith('bot ');

  bool _isPlayerReady(Player player) => player.connected && player.readyInLobby;

  Future<void> _createRoom(BartenderController ctrl) async {
    await ctrl.createRoom(playerName: _playerName, totalPlayers: _count);
  }

  Future<void> _leaveRoom(BartenderController ctrl) => ctrl.leaveRoom();

  String get _playerName {
    return _roomName(widget.playerName ?? _name.text);
  }

  @override
  void dispose() {
    _name.dispose();
    _joinCode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;
    return Scaffold(
      backgroundColor: const Color(0xFF4F291C),
      resizeToAvoidBottomInset: false,
      // KHÔNG bọc SafeArea quanh nền: hình phủ cả mép camera và thanh hệ thống.
      body: ListenableBuilder(
        listenable: ctrl,
        builder: (context, _) =>
            ctrl.room == null ? _startPage(ctrl) : _waitingPage(ctrl),
      ),
    );
  }

  Widget _background() {
    return Image.asset(
      _menuImage,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stack) => ColoredBox(
        color: const Color(0xFFFFE3A5),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'KHÔNG TẢI ĐƯỢC ẢNH NỀN\n$_menuImage\n'
                'Kiểm tra pubspec.yaml → flutter: → assets: → '
                '- assets/images/ui/\nSau đó Stop và Run lại.\n$error',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _coffee,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Canvas gốc 1844 × 853 tương ứng đúng tỷ lệ bức tranh được cung cấp.
  // FittedBox chỉ co nhóm nút; ảnh nền phủ kín bằng BoxFit.cover độc lập.
  // Không có SingleChildScrollView: tất cả nút nằm trong MỘT khung hình.
  Widget _startPage(BartenderController ctrl) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(child: _background()),
            Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 1844,
                  height: 853,
                  child: Stack(
                    children: [
                      // Logo và toàn bộ mascot ĐÃ NẰM TRONG HÌNH NỀN.
                      const Positioned(
                        top: 482,
                        left: 609,
                        width: 626,
                        height: 37,
                        child: _LittleHeading(
                          text: 'Tên của bạn',
                          icon: Icons.person_rounded,
                        ),
                      ),
                      Positioned(
                        left: 645,
                        top: 523,
                        width: 554,
                        height: 67,
                        child: _NameInput(
                          controller: _name,
                          readOnly: widget.playerName != null,
                        ),
                      ),
                      const Positioned(
                        top: 601,
                        left: 566,
                        width: 712,
                        height: 41,
                        child: _LittleHeading(
                          text: 'Số người chơi trong phòng',
                          icon: Icons.groups_rounded,
                        ),
                      ),
                      Positioned(
                        left: 653,
                        top: 647,
                        width: 538,
                        height: 78,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [2, 3, 4]
                              .map(
                                (n) => _PlayerOption(
                                  number: n,
                                  selected: _count == n,
                                  onTap: () => setState(() => _count = n),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      Positioned(
                        left: 439,
                        top: 740,
                        width: 473,
                        height: 97,
                        child: _ActionPill(
                          icon: Icons.groups_rounded,
                          title: ctrl.isBusy ? 'ĐANG TẠO...' : 'TẠO PHÒNG MỚI',
                          caption: 'Chơi với Bot hoặc mời bạn bè',
                          yellow: true,
                          onPressed: ctrl.isBusy
                              ? null
                              : () => _createRoom(ctrl),
                        ),
                      ),
                      Positioned(
                        left: 929,
                        top: 740,
                        width: 473,
                        height: 97,
                        child: _ActionPill(
                          icon: Icons.confirmation_number_rounded,
                          title: 'THAM GIA PHÒNG',
                          caption: 'Nhập mã phòng để tham gia',
                          yellow: false,
                          onPressed: ctrl.isBusy ? null : () => _openJoin(ctrl),
                        ),
                      ),
                      if (ctrl.errorMessage != null)
                        Positioned(
                          left: 620,
                          top: 456,
                          width: 604,
                          height: 33,
                          child: _MessageStrip(message: ctrl.errorMessage!),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Popup tham gia phòng: gọn, không có panel trang trí hay nút X dư thừa.
  // Có thể đóng bằng nút HỦY hoặc chạm ra ngoài khung.
  Future<void> _openJoin(BartenderController ctrl) async {
    _joinCode.clear();
    String? validation;

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Đóng cửa sổ tham gia phòng',
      barrierColor: const Color(0xB31A110B),
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (ctx, updateDialog) {
            // Khi mở bàn phím, khung có thể dịch lên; màn hình nhỏ
            // vẫn cuộn được phần popup nếu cần, không tràn chiều cao.
            final bottomInset = MediaQuery.viewInsetsOf(ctx).bottom;

            return SafeArea(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18, 12, 18, bottomInset + 12),
                  child: SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 475),
                        child: Material(
                          color: const Color(0xFFFFF5E2),
                          elevation: 18,
                          shadowColor: const Color(0x99381A09),
                          clipBehavior: Clip.antiAlias,
                          borderRadius: BorderRadius.circular(23),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(23),
                              border: Border.all(
                                color: const Color(0xFFD5A46C),
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.fromLTRB(23, 21, 23, 22),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFE1A5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.meeting_room_rounded,
                                        color: _coffee,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        'THAM GIA PHÒNG',
                                        style: TextStyle(
                                          color: _coffee,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 7),
                                const Text(
                                  'Nhập mã phòng được chia sẻ để vào chơi cùng bạn bè.',
                                  style: TextStyle(
                                    color: _brown,
                                    fontSize: 14,
                                    height: 1.4,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 19),
                                const Text(
                                  'MÃ PHÒNG',
                                  style: TextStyle(
                                    color: _coffee,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _joinCode,
                                  autofocus: false,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  textInputAction: TextInputAction.done,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(12),
                                    FilteringTextInputFormatter.allow(
                                      RegExp('[a-zA-Z0-9]'),
                                    ),
                                  ],
                                  onChanged: (_) {
                                    if (validation != null) {
                                      updateDialog(() => validation = null);
                                    }
                                  },
                                  onSubmitted: (_) => _submitJoin(
                                    ctrl,
                                    ctx,
                                    updateDialog,
                                    (message) => validation = message,
                                  ),
                                  style: const TextStyle(
                                    color: _coffee,
                                    fontSize: 20,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Ví dụ: 8737',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFFBCA48B),
                                      fontSize: 17,
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.key_rounded,
                                      color: Color(0xFFA46B37),
                                    ),
                                    errorText: validation,
                                    errorMaxLines: 2,
                                    filled: true,
                                    fillColor: const Color(0xFFFFFCF5),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFD4AC83),
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFB77736),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 21),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: _coffee,
                                          backgroundColor: const Color(
                                            0xFFFFF9ED,
                                          ),
                                          minimumSize: const Size(0, 49),
                                          side: const BorderSide(
                                            color: Color(0xFFBA8A61),
                                            width: 1.5,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              13,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'HỦY',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: () => _submitJoin(
                                          ctrl,
                                          ctx,
                                          updateDialog,
                                          (message) => validation = message,
                                        ),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF21BF8F,
                                          ),
                                          foregroundColor: const Color(
                                            0xFF073E30,
                                          ),
                                          minimumSize: const Size(0, 49),
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              13,
                                            ),
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.login_rounded,
                                          size: 19,
                                        ),
                                        label: const Text(
                                          'THAM GIA',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.985, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  void _submitJoin(
    BartenderController ctrl,
    BuildContext dialogContext,
    StateSetter setDialogState,
    void Function(String?) updateValidation,
  ) {
    final code = _joinCode.text.trim().toUpperCase();
    if (code.isEmpty) {
      setDialogState(() => updateValidation('Hãy nhập mã phòng.'));
      return;
    }
    Navigator.of(dialogContext).pop();
    ctrl.joinRoom(code: code, playerName: _playerName);
  }

  // Mọi người quay lại lobby qua returnToLobby của controller.
  // Chỉ host bấm SẴN SÀNG để mở trận mới khi room.canStart cho phép.
  Widget _waitingPage(BartenderController ctrl) {
    final room = ctrl.room!;
    final players = room.players.values.toList()
      ..sort((a, b) => a.ringIndex.compareTo(b.ringIndex));
    final total = room.totalPlayerCount;
    final hostId = _hostPlayerId(room);
    final host = _isHost(ctrl);
    final readyCount = room.readyPlayerCount;
    final allReady = room.canStart;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: _background()),
        const Positioned.fill(child: ColoredBox(color: Color(0xB0482718))),
        Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 1500,
              height: 710,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 11,
                    child: _LobbyPanel(
                      title: 'PHÒNG CHỜ',
                      headerIcon: Icons.local_bar_rounded,
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          const Text(
                            'MÃ PHÒNG',
                            style: TextStyle(
                              color: _brown,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 9),
                          Container(
                            height: 120,
                            margin: const EdgeInsets.symmetric(horizontal: 15),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFFF8DA),
                                  Color(0xFFFFE49E),
                                  Color(0xFFFFC46F),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFC78335),
                                width: 3,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x5C63320E),
                                  blurRadius: 9,
                                  offset: Offset(0, 7),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.vpn_key_rounded,
                                  color: Color(0xFFBA6B2C),
                                  size: 35,
                                ),
                                const SizedBox(width: 14),
                                SelectableText(
                                  room.code,
                                  style: const TextStyle(
                                    color: Color(0xFF9B4218),
                                    fontSize: 60,
                                    letterSpacing: 7,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(text: room.code),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Đã sao chép mã phòng'),
                                      ),
                                    );
                                  },
                                  tooltip: 'Sao chép mã phòng',
                                  icon: const Icon(
                                    Icons.copy_rounded,
                                    size: 30,
                                    color: _brown,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.groups_rounded,
                                color: _coffee,
                                size: 28,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${players.length} / $total NGƯỜI CHƠI',
                                style: const TextStyle(
                                  color: _coffee,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 13),
                          _RoomStatus(ready: allReady),
                          const SizedBox(height: 11),
                          Text(
                            host
                                ? 'Bạn là CHỦ PHÒNG'
                                : 'Bạn đang là NGƯỜI THAM GIA',
                            style: const TextStyle(
                              color: _brown,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (ctrl.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: _MessageStrip(message: ctrl.errorMessage!),
                            ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: _ActionPill(
                                  title: host ? 'SẴN SÀNG' : 'CHỜ CHỦ PHÒNG',
                                  caption: host
                                      ? (allReady
                                            ? 'Bắt đầu trận mới'
                                            : 'Chờ mọi người quay lại lobby')
                                      : 'Chủ phòng sẽ bắt đầu trận mới',
                                  icon: host
                                      ? Icons.play_arrow_rounded
                                      : Icons.hourglass_top_rounded,
                                  yellow: host,
                                  onPressed: host && allReady && !ctrl.isBusy
                                      ? () =>
                                            ctrl.startMatch(waitForScene: true)
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _ActionPill(
                                  title: 'RỜI PHÒNG',
                                  caption: 'Quay về menu chính',
                                  icon: Icons.exit_to_app_rounded,
                                  yellow: false,
                                  onPressed: ctrl.isBusy
                                      ? null
                                      : () => _leaveRoom(ctrl),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 25),
                  Expanded(
                    flex: 12,
                    child: _LobbyPanel(
                      title: 'DANH SÁCH ĐỘI',
                      headerIcon: Icons.people_rounded,
                      child: Column(
                        children: [
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'THÀNH VIÊN',
                                style: TextStyle(
                                  color: _brown,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                '$readyCount / ${players.length} SẴN SÀNG',
                                style: const TextStyle(
                                  color: Color(0xFF168958),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...List.generate(total > 4 ? 4 : total, (index) {
                            final player = index < players.length
                                ? players[index]
                                : null;
                            return _PlayerRow(
                              order: index + 1,
                              name: player?.name ?? 'Đang chờ đồng đội...',
                              isMe:
                                  player != null &&
                                  player.id == ctrl.myPlayerId,
                              connected: player?.connected ?? false,
                              waiting: player == null,
                              isHost: player != null && player.id == hostId,
                              isReady: player != null && _isPlayerReady(player),
                              isBot: player != null && _isBot(player),
                            );
                          }),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFF7D3), Color(0xFFFFE5AC)],
                              ),
                              border: Border.all(
                                color: const Color(0xFFC68E4D),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(17),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  allReady
                                      ? Icons.celebration_rounded
                                      : Icons.campaign_rounded,
                                  color: const Color(0xFFB86821),
                                  size: 31,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    allReady
                                        ? (host
                                              ? 'Tất cả đã sẵn sàng, bắt đầu thôi!'
                                              : 'Đã sẵn sàng, đang đợi chủ phòng bắt đầu.')
                                        : (room.connectedPlayerCount < 2
                                              ? 'Chờ thêm đồng đội vào phòng.'
                                              : 'Chờ mọi người quay lại lobby.'),
                                    style: const TextStyle(
                                      color: _coffee,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LittleHeading extends StatelessWidget {
  const _LittleHeading({required this.text, required this.icon});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.auto_awesome, color: Color(0xFFFFC12E), size: 24),
        const SizedBox(width: 10),
        Icon(icon, color: _brown, size: 26),
        const SizedBox(width: 9),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              style: const TextStyle(
                color: _coffee,
                fontWeight: FontWeight.w900,
                fontSize: 31,
                shadows: [
                  Shadow(
                    color: Color(0xCCFFF1CA),
                    offset: Offset(0, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Icon(Icons.auto_awesome, color: Color(0xFFFFC12E), size: 24),
      ],
    );
  }
}

class _NameInput extends StatelessWidget {
  const _NameInput({required this.controller, this.readOnly = false});
  final TextEditingController controller;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFA45D2E), width: 3),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFFFF1D7)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x7741200F),
            offset: Offset(0, 7),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              maxLength: 24,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.singleLineFormatter,
              ],
              style: const TextStyle(
                color: _coffee,
                fontSize: 29,
                fontWeight: FontWeight.w900,
              ),
              decoration: const InputDecoration(
                hintText: 'Nhập tên của bạn',
                hintStyle: TextStyle(color: Color(0xFFB18D6B)),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                border: InputBorder.none,
                counterText: '',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Icon(
              readOnly ? Icons.person : Icons.edit_rounded,
              color: const Color(0xFFC18347),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerOption extends StatelessWidget {
  const _PlayerOption({
    required this.number,
    required this.selected,
    required this.onTap,
  });
  final int number;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 151,
          height: 76,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            border: Border.all(
              color: selected
                  ? const Color(0xFFC47A0A)
                  : const Color(0xFFAC663C),
              width: selected ? 4 : 3,
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: selected
                  ? [
                      const Color(0xFFFFF6A4),
                      const Color(0xFFFFCC20),
                      const Color(0xFFFF9F09),
                    ]
                  : [const Color(0xFFFFFFFF), const Color(0xFFFFEFCD)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x7A542610),
                blurRadius: 4,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 12,
                right: 12,
                top: 5,
                height: 7,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xAFFFFFFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Text(
                '$number',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 44,
                  color: selected ? Colors.white : _coffee,
                  shadows: selected
                      ? const [
                          Shadow(
                            color: Color(0xAA9F4E00),
                            offset: Offset(0, 2),
                            blurRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionPill extends StatefulWidget {
  const _ActionPill({
    required this.icon,
    required this.title,
    required this.caption,
    required this.yellow,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String caption;
  final bool yellow;
  final VoidCallback? onPressed;

  @override
  State<_ActionPill> createState() => _ActionPillState();
}

class _ActionPillState extends State<_ActionPill> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isYellow = widget.yellow;
    final edge = isYellow ? const Color(0xFF98400A) : const Color(0xFF116343);
    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: widget.onPressed == null
          ? null
          : (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.965 : 1,
        duration: const Duration(milliseconds: 100),
        child: Opacity(
          opacity: widget.onPressed == null ? 0.55 : 1,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isYellow
                    ? [
                        const Color(0xFFFFF4A2),
                        const Color(0xFFFFD22B),
                        const Color(0xFFFFAA05),
                      ]
                    : [
                        const Color(0xFFBAFFE1),
                        const Color(0xFF58EBAB),
                        const Color(0xFF1EBC87),
                      ],
              ),
              borderRadius: BorderRadius.circular(39),
              border: Border.all(color: edge, width: 5),
              boxShadow: [
                BoxShadow(
                  color: edge,
                  offset: const Offset(0, 8),
                  blurRadius: 0,
                ),
                const BoxShadow(
                  color: Color(0x88502F16),
                  offset: Offset(0, 12),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 13),
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isYellow
                        ? const Color(0xFFFFF6D8)
                        : const Color(0xFFE9FFF4),
                    border: Border.all(color: edge, width: 3),
                  ),
                  child: Icon(widget.icon, color: edge, size: 43),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.title,
                          maxLines: 1,
                          style: const TextStyle(
                            color: _coffee,
                            fontSize: 31,
                            height: 1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.caption,
                          maxLines: 1,
                          style: const TextStyle(
                            color: _brown,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 13),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageStrip extends StatelessWidget {
  const _MessageStrip({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCD8651)),
      ),
      child: Text(
        message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF9B241D),
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _LobbyPanel extends StatelessWidget {
  const _LobbyPanel({
    required this.title,
    required this.headerIcon,
    required this.child,
  });
  final String title;
  final IconData headerIcon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEAC1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF733B20), width: 5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x9B241108),
            blurRadius: 16,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 97,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFAE5D2D), Color(0xFF633019)],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFFFCC77), width: 3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(headerIcon, color: const Color(0xFFFFDE83), size: 38),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFFFF0CC),
                    fontSize: 41,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _RoomStatus extends StatelessWidget {
  const _RoomStatus({required this.ready});
  final bool ready;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: ready ? const Color(0xFFCCF3D5) : const Color(0xFFFFE8B6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ready ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
            color: ready ? const Color(0xFF228B4C) : const Color(0xFFB8781E),
          ),
          const SizedBox(width: 8),
          Text(
            ready ? 'CẢ ĐỘI ĐÃ SẴN SÀNG!' : 'ĐANG CHỜ SẴN SÀNG...',
            style: const TextStyle(
              color: _coffee,
              fontWeight: FontWeight.w900,
              fontSize: 19,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
    required this.order,
    required this.name,
    required this.isMe,
    required this.connected,
    required this.waiting,
    required this.isHost,
    required this.isReady,
    required this.isBot,
  });
  final int order;
  final String name;
  final bool isMe, connected, waiting, isHost, isReady, isBot;

  @override
  Widget build(BuildContext context) {
    final accent = isHost
        ? const Color(0xFFFFB42A)
        : isReady
        ? const Color(0xFF68DEAC)
        : const Color(0xFFFFD193);
    return Container(
      height: 99,
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFFEF8),
            isHost ? const Color(0xFFFFEDBE) : const Color(0xFFFFF3DD),
          ],
        ),
        border: Border.all(
          color: isHost ? const Color(0xFFE19F32) : const Color(0xFFCCA071),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x39582B12),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 57,
            height: 57,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [const Color(0xFFFFE99F), accent],
              ),
              border: Border.all(color: const Color(0xFFA8612B), width: 2),
            ),
            child: Text(
              '$order',
              style: const TextStyle(
                color: _coffee,
                fontSize: 27,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 13),
          CircleAvatar(
            radius: 27,
            backgroundColor: const Color(0xFFFFE1AB),
            child: Icon(
              isHost
                  ? Icons.emoji_events_rounded
                  : isBot
                  ? Icons.smart_toy_rounded
                  : Icons.face_rounded,
              color: const Color(0xFFB46B2E),
              size: 33,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: waiting ? const Color(0xFFAC977E) : _coffee,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    if (isHost)
                      const Icon(
                        Icons.workspace_premium_rounded,
                        size: 17,
                        color: Color(0xFFAF6C16),
                      ),
                    Text(
                      isHost
                          ? 'CHỦ PHÒNG'
                          : waiting
                          ? 'CHƯA THAM GIA'
                          : isBot
                          ? 'BOT'
                          : isMe
                          ? 'BẠN'
                          : 'THÀNH VIÊN',
                      style: const TextStyle(
                        color: Color(0xFFAD752B),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!waiting)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: isReady
                    ? const Color(0xFFD8F8E8)
                    : const Color(0xFFFFE4C7),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isHost
                        ? Icons.star_rounded
                        : isReady
                        ? Icons.check_circle_rounded
                        : Icons.hourglass_bottom_rounded,
                    color: isHost
                        ? const Color(0xFFB47419)
                        : isReady
                        ? const Color(0xFF1C9566)
                        : const Color(0xFFB6732D),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isHost
                        ? 'HOST'
                        : isReady
                        ? 'ĐÃ VÀO LOBBY'
                        : 'ĐANG XEM KẾT QUẢ',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: isReady
                          ? const Color(0xFF16815B)
                          : const Color(0xFF9D5627),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 12),
          Icon(
            Icons.circle,
            size: 13,
            color: waiting
                ? Colors.grey
                : connected
                ? const Color(0xFF38C568)
                : const Color(0xFFCAA16D),
          ),
        ],
      ),
    );
  }
}
