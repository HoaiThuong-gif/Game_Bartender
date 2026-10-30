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
/// 1. Timer bar (đồng hồ + round + tổng đơn đội) cố định trên cùng
/// 2. Toàn bộ phần dưới có thể cuộn (SingleChildScrollView) tránh tràn xuống thanh điều hướng (navigation bar)
/// 3. Ring neighbors (ai bên trái / phải)
/// 4. Trạm chế biến
/// 5. Khay đơn hàng (nộp đơn)
/// 6. Danh sách items trên tay (vuốt để chuyền, bấm để chế biến)
/// 7. Thùng rác (kéo thả hoặc bấm nút)
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
                // 1. Timer bar (ghim cố định trên cùng để luôn thấy thời gian đếm ngược)
                TimerBarWidget(
                  remainingSeconds: ctrl.remainingSeconds,
                  roundNumber: round.number,
                  teamOrders: ctrl.totalTeamOrders,
                ),

                // 2. Nội dung cuộn được khi các thành phần nhiều hoặc màn hình nhỏ / có navigation bar
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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

                        // 5. Danh sách vật phẩm trên tay
                        if (ctrl.myItems.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 24,
                              horizontal: 16,
                            ),
                            child: Text(
                              'Chưa có vật phẩm.\nĐợi nguyên liệu xuất hiện hoặc nhận từ đồng đội!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.35),
                                fontSize: 13,
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                for (final item in ctrl.myItems)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: DraggableItemWrapper(
                                      item: item,
                                      child: ItemCardWidget(
                                        item: item,
                                        onSwipeLeft: () =>
                                            ctrl.swipeItemLeft(item),
                                        onSwipeRight: () =>
                                            ctrl.swipeItemRight(item),
                                        onTrash: () => ctrl.trashItem(item),
                                        onTap: () {
                                          if (ctrl.myStation != null) {
                                            ctrl.processItemAtStation(item);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                        // Thùng rác — kéo thả hoặc bấm nút trên ItemCard
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TrashBinWidget(
                                isVisible: true,
                                onDropped: ctrl.trashItem,
                                size: 56,
                              ),
                            ],
                          ),
                        ),

                        // Thông báo / lỗi nếu có
                        if (ctrl.noticeMessage != null)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 8),
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
                            margin: const EdgeInsets.only(top: 8),
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
