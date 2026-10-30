
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'games/bartender/screens/bartender_screen.dart';

Future<void> main() async {
  // Khởi tạo Flutter trước khi cấu hình màn hình.
  WidgetsFlutterBinding.ensureInitialized();

  // Khóa màn hình ngang để phù hợp với Game Bartender.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Ẩn thanh trạng thái và thanh điều hướng Android.
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  // Khởi chạy ứng dụng.
  runApp(const NhomBarApp());
}

class NhomBarApp extends StatelessWidget {
  const NhomBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Ẩn biểu tượng DEBUG.
      debugShowCheckedModeBanner: false,

      // Tên ứng dụng.
      title: 'Quầy Bartender',

      // Cấu hình giao diện.
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFBD47),
        ),
      ),

      // Màn hình chính của Game Bartender.
      home: const BartenderScreen(),
    );
  }
}
