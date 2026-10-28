
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ModelViewerScreen extends StatelessWidget {
  final String modelUrl;

  const ModelViewerScreen({
    super.key,
    required this.modelUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101418),
      appBar: AppBar(
        title: const Text('Mô hình 3D'),
        centerTitle: true,
        backgroundColor: const Color(0xFF101418),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ModelViewer(
              src: modelUrl,
              alt: 'Mô hình 3D của vật thể đã quét',
              autoRotate: false,
              cameraControls: true,
              disableZoom: false,
              backgroundColor: const Color(0xFF101418),
              loading: Loading.eager,
              interactionPrompt: InteractionPrompt.auto,
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF1C252B),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Mô hình 3D',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 12),

                Text(
                  'Chạm và kéo để xoay mô hình.\n'
                      'Dùng hai ngón tay để phóng to hoặc thu nhỏ.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
