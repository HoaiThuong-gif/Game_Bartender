import 'package:flutter/material.dart';

import '../widgets/rubik_theme.dart';
import 'manual_input_screen.dart';
import 'rubik_scan_screen.dart';

class RubikSolverScreen extends StatelessWidget {
  const RubikSolverScreen({super.key});
  @override
  Widget build(BuildContext context) => RubikTheme(
    child: Scaffold(
      appBar: AppBar(
        title: const Text('GIẢI RUBIK'),
        actions: [
          IconButton(
            tooltip: 'Cách sử dụng',
            icon: const Icon(Icons.help_outline),
            onPressed: () => showRubikHelp(
              context,
              'Chọn nhập thủ công hoặc quét camera để nhập sáu mặt của Rubik thật. Thuật toán giải trạng thái đã nhập.\n\nTrong hình xem trước: kéo để xoay góc nhìn, chụm hai ngón để thu phóng. Nhập từng mặt theo màu tâm và hướng phía trên hiển thị trên màn hình.',
            ),
          ),
        ],
        centerTitle: true,
      ),
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
