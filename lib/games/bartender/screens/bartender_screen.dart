import 'package:flutter/material.dart';

/// Điểm vào duy nhất (entry point) của tính năng Bartender.
/// Đây là screen mà lobby_screen.dart sẽ navigate tới (ở giai đoạn 7).
///
/// Hiện tại chỉ hiện chữ placeholder — sẽ được thay thế dần qua các giai đoạn
/// tiếp theo trong DEVELOPMENT.md.
class BartenderScreen extends StatelessWidget {
  const BartenderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BARTENDER'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_bar, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Bartender — Coming Soon',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Khung tính năng đã sẵn sàng.\n'
              'Giai đoạn 1 hoàn tất.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
