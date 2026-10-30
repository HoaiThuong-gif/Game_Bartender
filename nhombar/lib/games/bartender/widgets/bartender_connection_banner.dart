import 'package:flutter/material.dart';

import '../controllers/bartender_controller.dart';

/// The same repository connection state is shown in both 3D and fallback UI.
/// Reconnecting behavior remains owned by Zhoufen's controller/repository.
class BartenderConnectionBanner extends StatelessWidget {
  const BartenderConnectionBanner({super.key, required this.state});
  final RoomConnectionState state;

  @override
  Widget build(BuildContext context) {
    if (state == RoomConnectionState.connected) return const SizedBox.shrink();
    final reconnecting = state == RoomConnectionState.reconnecting;
    return Material(
      color: reconnecting ? Colors.orange.shade800 : Colors.red.shade800,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (reconnecting)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else
              const Icon(
                Icons.cloud_off_rounded,
                color: Colors.white,
                size: 18,
              ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                reconnecting ? 'Đang nối lại...' : 'Mất kết nối máy chủ',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
