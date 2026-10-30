import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../widgets/rubik_theme.dart';
import '../services/mock_rubik_challenge_service.dart';
import '../services/rubik_challenge_service.dart';
import '../services/api_rubik_challenge_service.dart';
import 'rubik_challenge_room_screen.dart';

class RubikChallengeLobbyScreen extends StatefulWidget {
  const RubikChallengeLobbyScreen({super.key, this.repositoryFactory});
  final Future<RubikChallengeRepository> Function(bool demo)? repositoryFactory;
  @override
  State<RubikChallengeLobbyScreen> createState() => _LobbyState();
}

class _LobbyState extends State<RubikChallengeLobbyScreen> {
  final _name = TextEditingController(text: 'Người chơi');
  final _code = TextEditingController();
  bool _demo = false, _busy = false;
  String? _error;
  Future<void> _open(bool create) async {
    final name = _name.text.trim();
    final code = _code.text.trim().toUpperCase();
    if (name.isEmpty || (!create && !RegExp(r'^[A-Z2-9]{6}$').hasMatch(code))) {
      setState(() => _error = 'Nhập tên và mã phòng gồm 6 ký tự.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    RubikChallengeRepository? repository;
    try {
      repository = widget.repositoryFactory != null
          ? await widget.repositoryFactory!(_demo)
          : _demo
          ? MockRubikChallengeRepository()
          : ApiRubikChallengeRepository();
      final roomCode = create ? await repository.create(name) : code;
      if (!create) await repository.join(code, name);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) =>
              RubikChallengeRoomScreen(repository: repository!, code: roomCode),
        ),
      );
    } catch (e) {
      if (mounted) {
        final message = e.toString();
        setState(
          () => _error = message.contains('RUBIK_DATABASE_URL')
              ? 'Thách đấu online chưa được cấu hình trên bản ứng dụng này.'
              : 'Không thể vào phòng. Kiểm tra mã phòng và kết nối mạng rồi thử lại.',
        );
      }
    } finally {
      await repository?.dispose();
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RubikTheme(
    child: Scaffold(
      appBar: AppBar(
        title: const Text('THÁCH ĐẤU RUBIK 1V1'),
        actions: [
          IconButton(
            tooltip: 'Cách sử dụng',
            icon: const Icon(Icons.help_outline),
            onPressed: () => showRubikHelp(
              context,
              'Nhập tên rồi Tạo phòng; gửi mã sáu ký tự cho người thứ hai. Người tham gia nhập mã rồi Tham gia phòng.\n\nOnline cần máy chủ đã cấu hình và kết nối mạng. Chế độ Thử một máy trong bản phát triển dùng đối thủ mô phỏng, không kiểm chứng kết nối hai thiết bị.',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Icon(
              Icons.sports_esports_outlined,
              size: 64,
              color: Color(0xFF1670D2),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cùng một đề • Ai giải nhanh hơn?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _name,
              maxLength: 24,
              enabled: !_busy,
              decoration: const InputDecoration(labelText: 'Tên của bạn'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : () => _open(true),
              child: const Text('Tạo phòng'),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _code,
              maxLength: 6,
              enabled: !_busy,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Mã phòng'),
            ),
            OutlinedButton(
              onPressed: _busy || _demo ? null : () => _open(false),
              child: const Text('Tham gia phòng'),
            ),
            if (kDebugMode)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Thử một máy'),
                subtitle: const Text('Đối thủ mô phỏng'),
                value: _demo,
                onChanged: _busy
                    ? null
                    : (value) => setState(() => _demo = value),
              ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 16),
            const Text(
              'Giới hạn 5 phút. Bỏ trận hoặc hết giờ được tính là DNF.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
