import 'package:flutter/material.dart';

import 'rubik_solver_screen.dart';
import '../challenge/screens/rubik_challenge_lobby_screen.dart';
import '../widgets/rubik_interactive_preview.dart';
import '../widgets/rubik_theme.dart';

class RubikScreen extends StatefulWidget {
  const RubikScreen({super.key});
  @override
  State<RubikScreen> createState() => _RubikScreenState();
}

class _RubikScreenState extends State<RubikScreen> {
  bool _active = true;
  Future<void> _open(Widget screen) async {
    setState(() => _active = false);
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => screen),
    );
    if (mounted) setState(() => _active = true);
  }

  @override
  Widget build(BuildContext context) => RubikTheme(
    child: Scaffold(
      appBar: AppBar(
        title: const Text('RUBIK'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Cách sử dụng',
            icon: const Icon(Icons.help_outline),
            onPressed: () async {
              setState(() => _active = false);
              await showRubikHelp(
                context,
                'Kéo bằng hai ngón để đổi góc nhìn toàn khối 360°, kể cả mặt đáy. Kéo bằng một ngón trên một ô để xoay tầng. Tự xáo thêm các lượt xoay hợp lệ; Hoàn tác lùi một lượt; Đặt lại đưa khối và góc nhìn về ban đầu, tâm trắng ở trên.\n\nTiến trình, lịch sử hoàn tác và góc nhìn được lưu trên thiết bị để tiếp tục khi mở lại. Giải Rubik mở nhập màu hoặc camera cho Rubik thật, độc lập với khối luyện tập ở đây. Thách đấu mở phòng thi giải; mỗi người có góc nhìn riêng.',
              );
              if (mounted) setState(() => _active = true);
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFDCEFFC),
      body: SafeArea(child: RubikInteractivePreview(active: _active)),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        child: Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: () => _open(const RubikSolverScreen()),
                child: const Text('GIẢI RUBIK'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF155A91),
                  side: const BorderSide(color: Color(0xFF75ADD4)),
                ),
                onPressed: () => _open(const RubikChallengeLobbyScreen()),
                child: const Text('THÁCH ĐẤU'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
