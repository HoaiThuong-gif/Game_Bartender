import 'package:flutter/material.dart';

import '../models/player.dart';
import '../models/station.dart';

/// Hiển thị hai người chơi liền kề bên trái và bên phải trong vòng tròn (Ring).
///
/// Giúp người chơi nắm bắt ngay:
/// - Khi vuốt trái: vật phẩm sẽ đến tay ai, người đó đang cầm trạm gì.
/// - Khi vuốt phải: vật phẩm sẽ đến tay ai, người đó đang cầm trạm gì.
///
/// Xem PROJECT_SPEC.md mục "Nguyên liệu & vật phẩm":
/// "Vật phẩm được chuyền bằng cách vuốt trái hoặc phải, gửi cho người liền kề trong vòng tròn."
class RingNeighborsWidget extends StatelessWidget {
  const RingNeighborsWidget({
    super.key,
    required this.myPlayer,
    required this.leftPlayer,
    required this.rightPlayer,
    this.leftStation,
    this.rightStation,
    this.myStation,
  });

  final Player? myPlayer;
  final Player? leftPlayer;
  final Player? rightPlayer;
  final StationType? leftStation;
  final StationType? rightStation;
  final StationType? myStation;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF262638),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Người bên trái (Vuốt Trái ⬅️)
          Expanded(
            child: _NeighborCard(
              directionIcon: Icons.arrow_back,
              directionLabel: 'VUỐT TRÁI',
              playerName: leftPlayer?.name ?? 'Trống',
              station: leftStation,
              isLeft: true,
            ),
          ),

          const SizedBox(width: 8),

          // Bạn ở giữa
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.5)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  myPlayer?.name ?? 'Bạn',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  myStation == null ? 'Không trạm' : '${myStation!.iconEmoji} ${myStation!.displayName}',
                  style: TextStyle(
                    color: myStation == null ? Colors.grey : Colors.amberAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Người bên phải (Vuốt Phải ➡️)
          Expanded(
            child: _NeighborCard(
              directionIcon: Icons.arrow_forward,
              directionLabel: 'VUỐT PHẢI',
              playerName: rightPlayer?.name ?? 'Trống',
              station: rightStation,
              isLeft: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _NeighborCard extends StatelessWidget {
  const _NeighborCard({
    required this.directionIcon,
    required this.directionLabel,
    required this.playerName,
    required this.station,
    required this.isLeft,
  });

  final IconData directionIcon;
  final String directionLabel;
  final String playerName;
  final StationType? station;
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment:
            isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: isLeft
                ? [
                    Icon(directionIcon, size: 12, color: Colors.cyanAccent),
                    const SizedBox(width: 4),
                    Text(
                      directionLabel,
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]
                : [
                    Text(
                      directionLabel,
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(directionIcon, size: 12, color: Colors.cyanAccent),
                  ],
          ),
          const SizedBox(height: 2),
          Text(
            playerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            station == null ? '🚫 Không trạm' : '${station!.iconEmoji} ${station!.displayName}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: station == null ? Colors.grey : Colors.amber.shade300,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
