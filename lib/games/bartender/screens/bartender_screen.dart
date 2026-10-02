import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../../firebase_options.dart';
import '../bartender_config.dart';
import '../controllers/bartender_controller.dart';
import '../services/firebase_initializer.dart';
import 'bartender_lobby_screen.dart';
import 'bartender_match_screen.dart';
import 'bartender_results_screen.dart';

/// Điểm vào duy nhất (entry point) của tính năng Bartender.
/// Đây là screen mà lobby_screen.dart sẽ navigate tới (ở giai đoạn 7).
///
/// Quản lý vòng đời BartenderController và chuyển đổi giữa 3 màn hình:
/// 1. Lobby → khi chưa bắt đầu hoặc đang chờ phòng
/// 2. Match → khi đang chơi (status == playing)
/// 3. Results → khi trận kết thúc (status == ended)
///
/// Khi [BartenderConfig.useFakeRepository] == false, màn hình này khởi động
/// Firebase (dùng [DefaultFirebaseOptions.currentPlatform] từ firebase_options.dart)
/// trước khi tạo controller — xem [BartenderFirebaseInitializer].
class BartenderScreen extends StatefulWidget {
  const BartenderScreen({super.key});

  @override
  State<BartenderScreen> createState() => _BartenderScreenState();
}

class _BartenderScreenState extends State<BartenderScreen> {
  BartenderController? _controller;
  bool _firebaseReady = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    if (!BartenderConfig.useFakeRepository) {
      try {
        // Khởi động Firebase với config từ firebase_options.dart.
        // File đó được tạo tự động bởi `flutterfire configure`
        // và nằm ở lib/ (không commit git — xem .gitignore).
        await BartenderFirebaseInitializer.initialize(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } on FirebaseException catch (e) {
        if (mounted) {
          setState(() =>
              _initError = 'Firebase error [${e.code}]: ${e.message}');
        }
        return;
      } catch (e) {
        if (mounted) {
          setState(() => _initError = 'Lỗi khởi động Firebase: $e');
        }
        return;
      }
    }

    if (mounted) {
      setState(() {
        _controller = BartenderController();
        _firebaseReady = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Khi đang dùng FakeRepository, không cần chờ — khởi động ngay
    if (BartenderConfig.useFakeRepository) {
      _controller ??= BartenderController();
      return _buildApp(_controller!);
    }

    // Đang dùng Firebase — chờ khởi động
    if (_initError != null) {
      return _buildError(_initError!);
    }

    if (!_firebaseReady || _controller == null) {
      return const _LoadingScreen();
    }

    return _buildApp(_controller!);
  }

  Widget _buildApp(BartenderController ctrl) {
    return ListenableBuilder(
      listenable: ctrl,
      builder: (context, _) {
        if (ctrl.isMatchEnded) {
          return BartenderResultsScreen(controller: ctrl);
        }
        if (ctrl.isMatchPlaying) {
          return BartenderMatchScreen(controller: ctrl);
        }
        return BartenderLobbyScreen(controller: ctrl);
      },
    );
  }

  Widget _buildError(String message) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Không thể kết nối Firebase',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _initError = null;
                    _firebaseReady = false;
                  });
                  _initController();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F0F1A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🍸', style: TextStyle(fontSize: 48)),
            SizedBox(height: 16),
            CircularProgressIndicator(color: Colors.amberAccent),
            SizedBox(height: 12),
            Text(
              'Đang kết nối Firebase...',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
