import 'dart:math' as math;
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import '../controllers/bartender_controller.dart';
import '../models/game_item.dart';
import '../models/ingredient.dart';
import '../models/processing_rules.dart';
import '../models/order.dart';
import '../models/recipe.dart';
import '../models/recipe_pool.dart';
import '../models/station.dart';
import '../widgets/station_widget.dart';
import 'bartender_3d_match_screen.dart';

// Quầy Bartender — gameplay UI V8
// Giữ nguyên controller/repository của nhóm, chỉ thay UI màn hình trận đấu.
// Không cần ảnh nền hay dependency mới. Phần 3D thật sẽ là một bước riêng.

const _espresso = Color(0xFF51250F);
const _chocolate = Color(0xFF733712);
const _caramel = Color(0xFFD57B2E);
const _cream = Color(0xFFFFF1CD);
const _paper = Color(0xFFFFFBEC);
const _gold = Color(0xFFFFC447);
const _mint = Color(0xFF5CD6A5);
const _muted = Color(0xFF94663F);

class BartenderMatchScreen extends StatelessWidget {
  const BartenderMatchScreen({super.key, required this.controller});

  final BartenderController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Bartender3DMatchScreen(
        controller: controller,
        statusPanel: _MatchTopBar(
          round: controller.room?.currentRound?.number ?? 1,
          time: controller.remainingSeconds,
          orders: controller.totalTeamOrders,
          message: controller.errorMessage ?? controller.noticeMessage,
          isError: controller.errorMessage != null,
        ),
        ordersPanel: _OrderPanel(controller: controller),
        fallback: _buildLegacy(context),
      ),
    );
  }

  Widget _buildLegacy(BuildContext context) {
    return Scaffold(
      backgroundColor: _espresso,
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final room = controller.room;
          final round = room?.currentRound;
          if (room == null || round == null) {
            return const Center(child: CircularProgressIndicator(color: _gold));
          }
          return Stack(
            children: [
              const Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(painter: _BarCounterPainter()),
                ),
              ),
              SafeArea(
                minimum: const EdgeInsets.fromLTRB(10, 5, 10, 6),
                child: LayoutBuilder(
                  builder: (context, box) {
                    final small = box.maxHeight < 370;
                    final topHeight = small ? 45.0 : 54.0;
                    final dockHeight = (box.maxHeight * (small ? 0.275 : 0.29))
                        .clamp(90.0, 136.0)
                        .toDouble();
                    return Column(
                      children: [
                        SizedBox(
                          height: topHeight,
                          child: _MatchTopBar(
                            round: round.number,
                            time: controller.remainingSeconds,
                            orders: controller.totalTeamOrders,
                            message:
                                controller.errorMessage ??
                                controller.noticeMessage,
                            isError: controller.errorMessage != null,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 57,
                                child: _StationPanel(controller: controller),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 43,
                                child: _OrderPanel(controller: controller),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 7),
                        SizedBox(
                          height: dockHeight,
                          child: _InventoryDock(controller: controller),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MatchTopBar extends StatelessWidget {
  const _MatchTopBar({
    required this.round,
    required this.time,
    required this.orders,
    required this.message,
    required this.isError,
  });
  final int round;
  final int time;
  final int orders;
  final String? message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final critical = time <= 10;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: _panelDecoration(
        colors: const [Color(0xFF864019), Color(0xFF4E260F)],
        radius: 16,
        line: const Color(0xFFFFD68A),
        depth: 4,
      ),
      child: Row(
        children: [
          const Icon(Icons.local_bar_rounded, color: _gold, size: 21),
          const SizedBox(width: 6),
          _smallValue('VÒNG', '$round', color: _cream),
          const SizedBox(width: 14),
          Icon(
            Icons.timer_outlined,
            color: critical ? const Color(0xFFFF7773) : _mint,
            size: 20,
          ),
          const SizedBox(width: 5),
          Text(
            '${(time < 0 ? 0 : time) ~/ 60}'.padLeft(2, '0') +
                ':' +
                '${(time < 0 ? 0 : time) % 60}'.padLeft(2, '0'),
            style: TextStyle(
              color: critical ? const Color(0xFFFF8880) : _cream,
              fontWeight: FontWeight.w900,
              fontSize: 21,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (message != null && message!.isNotEmpty)
                  Text(
                    message!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isError ? const Color(0xFFFFA19C) : _cream,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  )
                else
                  const Text(
                    'CÙNG NHAU HOÀN THÀNH ĐƠN!',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFFEEC995),
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (time / 60).clamp(0.0, 1.0).toDouble(),
                    minHeight: 5,
                    color: critical ? const Color(0xFFFF7166) : _mint,
                    backgroundColor: const Color(0xFF391D10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 13),
          const Icon(Icons.check_circle_outline, size: 18, color: _gold),
          const SizedBox(width: 5),
          _smallValue('ĐƠN ĐỘI', '$orders', color: _cream),
        ],
      ),
    );
  }

  Widget _smallValue(String label, String value, {required Color color}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFFFC57F),
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _StationPanel extends StatelessWidget {
  const _StationPanel({required this.controller});
  final BartenderController controller;

  @override
  Widget build(BuildContext context) {
    final left = controller.leftNeighbor;
    final right = controller.rightNeighbor;
    final station = controller.myStation;
    return _GamePanel(
      title: 'KHU VỰC PHA CHẾ',
      icon: Icons.restaurant_menu_rounded,
      titleTrailing: station == null ? 'ĐIỀU PHỐI' : station.displayName,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
            child: Row(
              children: [
                Expanded(
                  child: _NeighborPill(
                    label: 'VUỐT TRÁI',
                    name: left?.name ?? 'Trống',
                    station: controller
                        .room
                        ?.currentRound
                        ?.stationAssignment[left?.ringIndex],
                    icon: Icons.west_rounded,
                  ),
                ),
                const SizedBox(width: 6),
                Tooltip(
                  message: 'Tên của bạn: ${controller.me?.name ?? 'Bạn'}',
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF89421E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFFFFE5AD),
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _NeighborPill(
                    label: 'VUỐT PHẢI',
                    name: right?.name ?? 'Trống',
                    station: controller
                        .room
                        ?.currentRound
                        ?.stationAssignment[right?.ringIndex],
                    icon: Icons.east_rounded,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(13),
                bottomRight: Radius.circular(13),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 5),
                child: StationWidget(
                  station: station,
                  items: controller.myItems,
                  onProcessItem: controller.processItemAtStation,
                  isBusy: controller.isBusy,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NeighborPill extends StatelessWidget {
  const _NeighborPill({
    required this.label,
    required this.name,
    required this.station,
    required this.icon,
  });
  final String label;
  final String name;
  final StationType? station;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: _paper,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFE5AE6A)),
      ),
      child: Row(
        children: [
          Icon(icon, color: _caramel, size: 17),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$label · $name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _espresso,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                ),
                Text(
                  station == null ? 'Không có trạm' : station!.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderPanel extends StatelessWidget {
  const _OrderPanel({required this.controller});
  final BartenderController controller;

  @override
  Widget build(BuildContext context) {
    final orders = controller.myOrders;
    final done = orders.where((o) => o.isCompleted).length;
    return _GamePanel(
      title: 'ĐƠN CẦN LÀM',
      icon: Icons.receipt_long_rounded,
      titleTrailing: '$done/${orders.length}',
      child: orders.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Đang nhận đơn hàng...',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _chocolate),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 7),
              itemBuilder: (context, index) => _OrderTile(
                order: orders[index],
                availableItems: controller.myItems,
                busy: controller.isBusy,
                onSubmit: controller.submitOrder,
              ),
            ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({
    required this.order,
    required this.availableItems,
    required this.busy,
    required this.onSubmit,
  });
  final Order order;
  final List<GameItem> availableItems;
  final bool busy;
  final void Function(Order, GameItem) onSubmit;

  @override
  Widget build(BuildContext context) {
    Recipe? recipe;
    for (final r in RecipePool.allRecipes) {
      if (r.id == order.recipeId) {
        recipe = r;
        break;
      }
    }
    final productId = recipe?.productId ?? order.recipeId;
    GameItem? matching;
    for (final item in availableItems) {
      if (item.type == GameItemType.product && item.itemId == productId) {
        matching = item;
        break;
      }
    }
    final ready = matching != null && !order.isCompleted;
    final currentMatching = matching;
    final recipeName = recipe?.name ?? order.recipeId;

    return DragTarget<GameItem>(
      onWillAcceptWithDetails: (details) =>
          !busy &&
          !order.isCompleted &&
          details.data.type == GameItemType.product &&
          details.data.itemId == productId,
      onAcceptWithDetails: (details) {
        if (!busy && !order.isCompleted) onSubmit(order, details.data);
      },
      builder: (context, candidates, rejected) {
        final hovering = candidates.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          padding: const EdgeInsets.fromLTRB(9, 8, 9, 8),
          decoration: BoxDecoration(
            color: order.isCompleted
                ? const Color(0xFFDCF6DD)
                : hovering
                ? const Color(0xFFC8F4DF)
                : _paper,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: order.isCompleted
                  ? const Color(0xFF69B884)
                  : hovering
                  ? const Color(0xFF36B987)
                  : const Color(0xFFE3AB67),
              width: hovering ? 2 : 1.3,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x20844218),
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    order.isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.local_cafe_rounded,
                    size: 17,
                    color: order.isCompleted
                        ? const Color(0xFF269A69)
                        : _caramel,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      recipeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _espresso,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (recipe != null)
                    Text(
                      '★ ${recipe.difficulty}',
                      style: const TextStyle(
                        color: _caramel,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 5),
              if (recipe != null)
                Text(
                  recipe.ingredients
                      .map((i) => '${i.emoji} ${i.displayName}')
                      .join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 10),
                ),
              const SizedBox(height: 5),
              if (order.isCompleted)
                const Text(
                  '✓ ĐÃ HOÀN THÀNH',
                  style: TextStyle(
                    color: Color(0xFF228A59),
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                )
              else if (ready)
                SizedBox(
                  width: double.infinity,
                  height: 29,
                  child: FilledButton.icon(
                    onPressed: busy
                        ? null
                        : () => onSubmit(order, currentMatching!),
                    style: FilledButton.styleFrom(
                      backgroundColor: _gold,
                      foregroundColor: _espresso,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle, size: 13),
                    label: const Text(
                      'NỘP ĐƠN · +5 GIÂY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                )
              else
                const Text(
                  'Kéo sản phẩm hoàn thành vào đây để nộp',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _muted,
                    fontSize: 9,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _InventoryDock extends StatelessWidget {
  const _InventoryDock({required this.controller});
  final BartenderController controller;

  @override
  Widget build(BuildContext context) {
    return _GamePanel(
      title: 'KHAY NGUYÊN LIỆU',
      icon: Icons.inventory_2_rounded,
      titleTrailing: '${controller.myItems.length} MÓN',
      titleAction: Tooltip(
        message: 'Kéo vật phẩm vào thùng rác để bỏ',
        child: _TrashDropZone(onDropped: controller.trashItem),
      ),
      child: controller.myItems.isEmpty
          ? const Center(
              child: Text(
                'Chưa có nguyên liệu · Chờ món xuất hiện hoặc đồng đội chuyền tới',
                textAlign: TextAlign.center,
                style: TextStyle(color: _chocolate, fontSize: 11),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final columns = (constraints.maxWidth / 177)
                    .floor()
                    .clamp(2, 7)
                    .toInt();
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(7, 6, 7, 7),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisExtent: 67,
                    crossAxisSpacing: 7,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: controller.myItems.length,
                  itemBuilder: (context, index) {
                    final item = controller.myItems[index];
                    return _InventoryItem(
                      key: ValueKey(item.id),
                      item: item,
                      busy: controller.isBusy,
                      onSwipeLeft: () => controller.swipeItemLeft(item),
                      onSwipeRight: () => controller.swipeItemRight(item),
                      onTap: () {
                        if (!controller.isBusy &&
                            controller.myStation != null &&
                            controller.myStation != StationType.shaker &&
                            processItem(item.itemId, controller.myStation!) !=
                                null) {
                          controller.processItemAtStation(item);
                        }
                      },
                      onTrash: () => controller.trashItem(item),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _InventoryItem extends StatelessWidget {
  const _InventoryItem({
    super.key,
    required this.item,
    required this.busy,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onTap,
    required this.onTrash,
  });
  final GameItem item;
  final bool busy;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final VoidCallback onTap;
  final VoidCallback onTrash;

  @override
  Widget build(BuildContext context) {
    final isProduct = item.type == GameItemType.product;
    final card = Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: isProduct ? const Color(0xFFE8FAE4) : _paper,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: isProduct ? const Color(0xFF6CC197) : const Color(0xFFE2B27C),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x25814622),
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(_itemEmoji(item), style: const TextStyle(fontSize: 25)),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _itemName(item),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: _espresso,
                  ),
                ),
                Text(
                  isProduct ? 'Thành phẩm · giữ để kéo' : 'Vuốt ← → để chuyền',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 9, color: _muted),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: busy ? null : onTrash,
            icon: const Icon(Icons.delete_outline_rounded, size: 17),
            color: const Color(0xFFC36C57),
            constraints: const BoxConstraints(minWidth: 27, minHeight: 30),
            padding: EdgeInsets.zero,
            tooltip: 'Bỏ vật phẩm',
          ),
        ],
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: busy ? null : onTap,
      onHorizontalDragEnd: busy
          ? null
          : (details) {
              final speed = details.primaryVelocity ?? 0;
              // Không gửi khi chỉ chạm nhẹ; vuốt nhanh rõ hướng mới chuyền.
              if (speed < -230) onSwipeLeft();
              if (speed > 230) onSwipeRight();
            },
      child: LongPressDraggable<GameItem>(
        data: item,
        maxSimultaneousDrags: busy ? 0 : 1,
        feedback: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: 174,
            height: 64,
            child: Opacity(opacity: 0.85, child: card),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.25, child: card),
        child: card,
      ),
    );
  }
}

class _TrashDropZone extends StatelessWidget {
  const _TrashDropZone({required this.onDropped});
  final ValueChanged<GameItem> onDropped;

  @override
  Widget build(BuildContext context) {
    return DragTarget<GameItem>(
      onAcceptWithDetails: (details) => onDropped(details.data),
      builder: (context, incoming, rejected) {
        final hovering = incoming.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 42,
          height: 27,
          decoration: BoxDecoration(
            color: hovering ? const Color(0xFFFA9684) : const Color(0xFFFFD19F),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE49B68)),
          ),
          child: Icon(
            Icons.delete_outline,
            color: hovering ? Colors.white : _chocolate,
            size: 17,
          ),
        );
      },
    );
  }
}

class _GamePanel extends StatelessWidget {
  const _GamePanel({
    required this.title,
    required this.icon,
    required this.child,
    required this.titleTrailing,
    this.titleAction,
  });
  final String title;
  final IconData icon;
  final Widget child;
  final String titleTrailing;
  final Widget? titleAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(
        colors: const [Color(0xFFFFEBC1), Color(0xFFFFD79A)],
        radius: 16,
        line: const Color(0xFFAE6329),
        depth: 4,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          children: [
            Container(
              height: 31,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFA75C26), Color(0xFF753817)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, color: _cream, size: 16),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: _cream,
                        letterSpacing: 0.15,
                      ),
                    ),
                  ),
                  if (titleTrailing.isNotEmpty)
                    Text(
                      titleTrailing,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFFFD992),
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  if (titleAction != null) ...[
                    const SizedBox(width: 6),
                    titleAction!,
                  ],
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _panelDecoration({
  required List<Color> colors,
  required double radius,
  required Color line,
  required double depth,
}) {
  return BoxDecoration(
    gradient: LinearGradient(
      colors: colors,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: line, width: 1.8),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF2F170B).withValues(alpha: 0.5),
        blurRadius: 7,
        offset: Offset(0, depth),
      ),
      const BoxShadow(
        color: Color(0x55FFFFFF),
        offset: Offset(0, 1),
        blurRadius: 0,
      ),
    ],
  );
}

String _itemEmoji(GameItem item) {
  if (item.type == GameItemType.ingredient) {
    for (final i in Ingredient.values) {
      if (i.name == item.itemId) return i.emoji;
    }
    return '🥬';
  }
  switch (item.itemId) {
    case 'orange_juice':
      return '🍊';
    case 'lemon_juice':
    case 'lemonade':
      return '🍋';
    case 'cut_strawberry':
      return '🍓';
    case 'strawberry_smoothie':
      return '🥤';
    case 'strawberry_lemonade_blend':
      return '🍓';
    case 'citrus_cocktail':
      return '🍹';
    case 'strawberry_lemonade':
      return '🍹';
    default:
      return '📦';
  }
}

String _itemName(GameItem item) {
  if (item.type == GameItemType.ingredient) {
    for (final i in Ingredient.values) {
      if (i.name == item.itemId) return i.displayName;
    }
  }
  switch (item.itemId) {
    case 'orange_juice':
      return 'Nước cam ép';
    case 'lemon_juice':
    case 'lemonade':
      return 'Nước chanh';
    case 'cut_strawberry':
      return 'Dâu đã sơ chế';
    case 'strawberry_smoothie':
      return 'Sinh tố dâu';
    case 'strawberry_lemonade_blend':
      return 'Hỗn hợp dâu chanh';
    case 'citrus_cocktail':
      return 'Mocktail cam chanh';
    case 'strawberry_lemonade':
      return 'Nước chanh dâu';
    default:
      return item.itemId.replaceAll('_', ' ');
  }
}

/// Vẽ nền quầy gỗ bằng Flutter: không cần khai báo asset, tránh lỗi ảnh không tải.
class _BarCounterPainter extends CustomPainter {
  const _BarCounterPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final area = Offset.zero & size;
    canvas.drawRect(
      area,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEAB779), Color(0xFFBB773D), Color(0xFF8D4E28)],
        ).createShader(area),
    );
    final seam = Paint()
      ..color = const Color(0x445D2D10)
      ..strokeWidth = 2;
    for (double y = 68; y < size.height; y += 78) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), seam);
      canvas.drawLine(
        Offset(0, y + 3),
        Offset(size.width, y + 3),
        Paint()
          ..color = const Color(0x44FFF0C7)
          ..strokeWidth = 1.2,
      );
    }
    final grain = Paint()
      ..color = const Color(0x336E3B19)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 36; i++) {
      final x = ((i * 127.37) % math.max(1, size.width));
      final y = ((i * 47.23) % math.max(1, size.height));
      final path = Path()
        ..moveTo(x, y)
        ..quadraticBezierTo(x + 25, y - 3, x + 85, y);
      canvas.drawPath(path, grain);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
