import 'package:flutter/material.dart';

import '../models/game_item.dart';
import '../models/ingredient.dart';
import '../models/order.dart';
import '../models/recipe.dart';
import '../models/recipe_pool.dart';
import '../models/station.dart';

/// Khay hiển thị các đơn hàng người chơi cần hoàn thành trong round hiện tại.
///
/// Xem PROJECT_SPEC.md:
/// - Mỗi round, mỗi người nhận một số đơn cố định (mục tiêu: 3).
/// - Round kết thúc khi tất cả người chơi hoàn thành hết đơn.
/// - Nộp đơn bằng cách nộp sản phẩm hoàn thành (kéo hoặc bấm nút nộp đơn).
class OrderTrayWidget extends StatelessWidget {
  const OrderTrayWidget({
    super.key,
    required this.orders,
    required this.availableItems,
    required this.onSubmitOrder,
  });

  final List<Order> orders;
  final List<GameItem> availableItems;
  final void Function(Order order, GameItem product) onSubmitOrder;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.receipt_long, size: 16, color: Colors.amberAccent),
                  SizedBox(width: 6),
                  Text(
                    'ĐƠN HÀNG CẦN PHA CHẾ',
                    style: TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Text(
                '${orders.where((o) => o.isCompleted).length} / ${orders.length} ĐÃ NỘP',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Danh sách đơn hàng nằm ngang
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: orders.map((order) {
                final recipe = RecipePool.allRecipes.firstWhere(
                  (r) => r.id == order.recipeId,
                  orElse: () => Recipe(
                    id: order.recipeId,
                    name: order.recipeId,
                    ingredients: [],
                    steps: [],
                    difficulty: 1,
                  ),
                );

                // Kiểm tra người chơi có sẵn sản phẩm hoàn chỉnh của đơn này không
                final matchingProduct = availableItems.cast<GameItem?>().firstWhere(
                      (item) => item!.itemId == order.recipeId,
                      orElse: () => null,
                    );

                return _OrderCard(
                  order: order,
                  recipe: recipe,
                  matchingProduct: matchingProduct,
                  onSubmit: () {
                    if (matchingProduct != null) {
                      onSubmitOrder(order, matchingProduct);
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.recipe,
    required this.matchingProduct,
    required this.onSubmit,
  });

  final Order order;
  final Recipe recipe;
  final GameItem? matchingProduct;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final isReadyToSubmit = matchingProduct != null && !order.isCompleted;

    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: order.isCompleted
            ? Colors.green.shade900.withValues(alpha: 0.3)
            : isReadyToSubmit
                ? Colors.amber.shade900.withValues(alpha: 0.35)
                : const Color(0xFF2C2C40),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: order.isCompleted
              ? Colors.greenAccent.withValues(alpha: 0.6)
              : isReadyToSubmit
                  ? Colors.amberAccent
                  : Colors.white12,
          width: isReadyToSubmit ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  recipe.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (order.isCompleted)
                const Icon(Icons.check_circle, size: 16, color: Colors.greenAccent)
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade800,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Độ khó ${recipe.difficulty}',
                    style: const TextStyle(color: Colors.white70, fontSize: 9),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),

          // Nguyên liệu cần
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: recipe.ingredients.map((ing) {
              return Text(
                '${ing.emoji} ${ing.displayName}',
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              );
            }).toList(),
          ),
          const SizedBox(height: 4),

          // Các bước trạm cần
          Wrap(
            spacing: 4,
            children: recipe.steps.map((step) {
              return Text(
                '${step.station.iconEmoji} ${step.description}',
                style: const TextStyle(color: Colors.amberAccent, fontSize: 10),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // Trạng thái hoặc Nút Nộp Đơn
          if (order.isCompleted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.green.shade800.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '✓ ĐÃ HOÀN TẤT',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            )
          else if (isReadyToSubmit)
            SizedBox(
              width: double.infinity,
              height: 28,
              child: ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'NỘP ĐƠN (+5s) ✨',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Đang chế biến...',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
