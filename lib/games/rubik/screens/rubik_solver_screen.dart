import 'package:flutter/material.dart';

import '../widgets/rubik_theme.dart';
import 'manual_input_screen.dart';
import 'rubik_scan_screen.dart';

class RubikSolverScreen extends StatelessWidget {
  const RubikSolverScreen({super.key});
  @override
  Widget build(BuildContext context) => RubikTheme(
    child: Scaffold(
      appBar: AppBar(title: const Text('GIẢI RUBIK'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.view_in_ar,
                    size: 100,
                    color: Color(0xFF1670D2),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Chọn cách nhập Rubik',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 28),
                  RubikModeTile(
                    title: 'QUÉT RUBIK BẰNG CAMERA',
                    subtitle: 'Dùng camera để nhận diện màu',
                    icon: Icons.camera_alt_outlined,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const RubikScanScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  RubikModeTile(
                    title: 'NHẬP MÀU THỦ CÔNG',
                    subtitle: 'Tự nhập màu của 6 mặt Rubik',
                    icon: Icons.grid_view_rounded,
                    primary: true,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const ManualInputScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
