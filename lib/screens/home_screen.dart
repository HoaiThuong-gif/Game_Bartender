
import 'package:flutter/material.dart';

import '../services/scan_service.dart';
import 'scanner_screen.dart';
import 'pointcloud_viewer_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Bản quét chai thuốc đã dựng thành công bằng COLMAP.
  static const String demoScanId =
      '86840f04e2164e47a8b4590fa1b1c074';

  Future<void> _openSavedScan(BuildContext context) async {
    final scanService = ScanService();

    try {
      final result = await scanService.getScanStatus(demoScanId);

      if (!context.mounted) return;

      if (result['status'] == 'completed' &&
          result['result_type'] == 'pointcloud' &&
          result['pointcloud_url'] != null) {
        final pointCloudUrl = scanService.getPointCloudUrl(
          result['pointcloud_url'].toString(),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PointCloudViewerScreen(
              pointCloudUrl: pointCloudUrl,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Bản quét chưa có dữ liệu Point Cloud.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể mở bản quét: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Object Scanner'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.tealAccent.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(
                  Icons.view_in_ar,
                  size: 110,
                  color: Colors.tealAccent,
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                '3D Object Scanner',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Quét vật thể bằng camera và tái tạo '
                    'mô hình 3D từ nhiều góc nhìn.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 35),

              // Nút quay video mới.
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const ScannerScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.document_scanner),
                  label: const Text(
                    'Bắt đầu quét 3D',
                    style: TextStyle(fontSize: 17),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Nút mở Point Cloud đã dựng bằng COLMAP.
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () => _openSavedScan(context),
                  icon: const Icon(Icons.scatter_plot),
                  label: const Text(
                    'Xem bản quét đã dựng',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.tealAccent,
                    side: const BorderSide(
                      color: Colors.tealAccent,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Di chuyển camera chậm quanh vật thể '
                    'để thu thập dữ liệu 3D.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
