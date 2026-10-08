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
      appBar: AppBar(title: const Text('RUBIK'), centerTitle: true),
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
