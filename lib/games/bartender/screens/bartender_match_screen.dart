import 'package:flutter/material.dart';

import '../controllers/bartender_controller.dart';
import '../models/ring.dart';
import '../widgets/item_card_widget.dart';
import '../widgets/order_tray_widget.dart';
import '../widgets/ring_neighbors_widget.dart';
import '../widgets/station_widget.dart';
import '../widgets/timer_bar_widget.dart';
import '../widgets/trash_bin_widget.dart';

/// Màn hình trận đấu Bartender — vòng lặp gameplay chính.
///
/// Hiển thị:
/// 1. Timer bar (đồng hồ + round + tổng đơn đội)
/// 2. Ring neighbors (ai bên trái / phải)
/// 3. Trạm chế biến
/// 4. Danh sách items trên tay (vuốt để chuyền, bấm để chế biến)
/// 5. Khay đơn hàng (nộp đơn)
///
/// Xem PROJECT_SPEC.md toàn bộ mục "Vòng lặp trận đấu".
class BartenderMatchScreen extends StatelessWidget {
  const BartenderMatchScreen({
    super.key,
    required this.controller,
  });

  final BartenderController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final ctrl = controller;
          final room = ctrl.room;
          final round = room?.currentRound;

          if (room == null || round == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.amberAccent,
              ),
            );
          }

          final playerCount = room.totalPlayerCount;
          final leftRing = Ring.leftNeighbor(ctrl.myRingIndex, playerCount);
          final rightRing = Ring.rightNeighbor(ctrl.myRingIndex, playerCount);

          return SafeArea(
            child: Column(
              children: [
                // 1. Timer bar
                TimerBarWidget(
                  remainingSeconds: ctrl.remainingSeconds,
                  roundNumber: round.number,
                  teamOrders: ctrl.totalTeamOrders,
                ),

                // 2. Ring neighbors
                RingNeighborsWidget(
                  myPlayer: ctrl.me,
                  leftPlayer: ctrl.leftNeighbor,
                  rightPlayer: ctrl.rightNeighbor,
                  myStation: ctrl.myStation,
                  leftStation: round.stationAssignment[leftRing],
                  rightStation: round.stationAssignment[rightRing],
                ),

                // 3. Trạm chế biến
                StationWidget(
                  station: ctrl.myStation,
                  items: ctrl.myItems,
                  onProcessItem: ctrl.processItemAtStation,
                  isBusy: ctrl.isBusy,
                ),

                // 4. Đơn hàng
                OrderTrayWidget(
                  orders: ctrl.myOrders,
                  availableItems: ctrl.myItems,
                  onSubmitOrder: ctrl.submitOrder,
                ),

                // 5. Danh sách vật phẩm trên tay + thùng rác
                Expanded(
                  child: ctrl.myItems.isEmpty
                      ? Center(
                          child: Text(
                            'Chưa có vật phẩm.\nĐợi nguyên liệu xuất hiện hoặc nhận từ đồng đội!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: 13,
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            // Danh sách items (scrollable)
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.only(top: 4, bottom: 8),
                                itemCount: ctrl.myItems.length,
                                itemBuilder: (context, index) {
                                  final item = ctrl.myItems[index];
                                  return DraggableItemWrapper(
                                    item: item,
                                    child: ItemCardWidget(
                                      item: item,
                                      onSwipeLeft: () => ctrl.swipeItemLeft(item),
                                      onSwipeRight: () => ctrl.swipeItemRight(item),
                                      onTrash: () => ctrl.trashItem(item),
                                      onTap: () {
                                        if (ctrl.myStation != null) {
                                          ctrl.processItemAtStation(item);
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),

                            // Thùng rác — kéo thả hoặc bấm nút trên ItemCard
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TrashBinWidget(
                                    isVisible: true,
                                    onDropped: ctrl.trashItem,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),

                // Thông báo / lỗi
                if (ctrl.noticeMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.amberAccent.withValues(alpha: 0.15),
                    child: Text(
                      ctrl.noticeMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),

                if (ctrl.errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    child: Text(
                      ctrl.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
