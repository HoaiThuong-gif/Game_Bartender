import 'package:flutter/material.dart';

import '../models/game_item.dart';
import '../models/station.dart';

/// Hiển thị trạm chế biến được phân cho người chơi trong round hiện tại.
///
/// Xem PROJECT_SPEC.md & DECISIONS.md D5:
/// - Màn hình của mỗi người chỉ hiển thị MỘT trạm cố định cho round đó.
/// - Có thể không có trạm nào (null) — lúc này người chơi đóng vai trò điều phối/chuyền đồ.
class StationWidget extends StatelessWidget {
  const StationWidget({
    super.key,
    required this.station,
    required this.items,
    required this.onProcessItem,
    required this.isBusy,
  });

  final StationType? station;
  final List<GameItem> items;
  final void Function(GameItem item) onProcessItem;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    if (station == null) {
      return _buildNoStationBanner();
    }

    // Lọc ra các item có thể chế biến tại trạm này
    final processableItems = items
        .where((item) => _canProcess(item, station!))
        .toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF2C2540), const Color(0xFF1F1D30)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.deepPurpleAccent.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tiêu đề trạm
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade800,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        station!.iconEmoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            station!.displayName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Thao tác: ${station!.actionVerb}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (isBusy)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.amberAccent,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Vùng tương tác chế biến
          if (processableItems.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: Text(
                'Chưa có nguyên liệu phù hợp để ${station!.actionVerb.toLowerCase()}.\n'
                'Nhận hoặc xin từ đồng đội!',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            )
          else ...[
            Text(
              'Có ${processableItems.length} món có thể ${station!.actionVerb.toLowerCase()}:',
              style: const TextStyle(
                color: Colors.amberAccent,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: processableItems.map((item) {
                return ElevatedButton.icon(
                  onPressed: isBusy ? null : () => onProcessItem(item),
                  icon: Text(
                    station!.iconEmoji,
                    style: const TextStyle(fontSize: 14),
                  ),
                  label: Text('${station!.actionVerb} ${item.itemId}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoStationBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2C241E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade900.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Text('🚫', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ROUND NÀY BẠN KHÔNG CÓ TRẠM',
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Hãy điều phối và vuốt chuyền nguyên liệu cho đồng đội bên trái hoặc bên phải!',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _canProcess(GameItem item, StationType station) {
    final id = item.itemId;
    switch (station) {
      case StationType.juicer:
        return id == 'orange' || id == 'lemon';
      case StationType.cuttingBoard:
        return id == 'strawberry' || id == 'lemon';
      case StationType.blender:
        return id == 'cut_strawberry' || id == 'strawberry';
      case StationType.shaker:
        return id == 'orange_juice' || id == 'lemonade' || id == 'ice';
    }
  }
}
