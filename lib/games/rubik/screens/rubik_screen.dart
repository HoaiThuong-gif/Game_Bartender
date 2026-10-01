import 'package:flutter/material.dart';

import 'rubik_solver_screen.dart';
import '../widgets/rubik_3d_view.dart';
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
      appBar: AppBar(title: const Text('RUBIK'), centerTitle: true),
      backgroundColor: Colors.black,
      body: SafeArea(child: Rubik3DView(active: _active)),
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
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                ),
                onPressed: () => _open(const _ChallengeScreen()),
                child: const Text('THÁCH ĐẤU'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ChallengeScreen extends StatelessWidget {
  const _ChallengeScreen();
  @override
  Widget build(BuildContext context) => RubikTheme(
    child: Scaffold(
      appBar: AppBar(title: const Text('THÁCH ĐẤU')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.sports_esports_outlined,
                size: 80,
                color: Color(0xFF1670D2),
              ),
              const SizedBox(height: 24),
              const Text(
                'Thử thách sắp bắt đầu',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              const Text(
                'Chế độ thách đấu đang được phát triển.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Về Rubik'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
