import 'package:flutter/material.dart';

import '../models/game_item.dart';
import '../models/ingredient.dart';

/// Card hiển thị một vật phẩm (nguyên liệu / sản phẩm) trên màn hình người chơi.
///
/// Hỗ trợ thao tác vuốt trái/phải để chuyền cho đồng đội — xem PROJECT_SPEC.md.
/// Hỗ trợ bấm nút thùng rác để xoá — xem PROJECT_SPEC.md.
class ItemCardWidget extends StatelessWidget {
  const ItemCardWidget({
    super.key,
    required this.item,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onTrash,
    required this.onTap,
  });

  final GameItem item;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final VoidCallback onTrash;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isProduct = item.type == GameItemType.product;

    return Dismissible(
      key: ValueKey(item.id),
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onSwipeLeft();
        } else {
          onSwipeRight();
        }
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: Colors.cyan.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_forward, color: Colors.cyanAccent, size: 20),
            SizedBox(width: 4),
            Text(
              'CHUYỀN PHẢI ➡️',
              style: TextStyle(
                color: Colors.cyanAccent,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.cyan.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '⬅️ CHUYỀN TRÁI',
              style: TextStyle(
                color: Colors.cyanAccent,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.arrow_back, color: Colors.cyanAccent, size: 20),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isProduct
                ? const Color(0xFF2A3020)
                : const Color(0xFF1E1E2C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isProduct
                  ? Colors.greenAccent.withValues(alpha: 0.5)
                  : Colors.white12,
            ),
          ),
          child: Row(
            children: [
              // Emoji / icon
              Text(
                _itemEmoji(item),
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(width: 10),

              // Tên và loại
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _itemDisplayName(item),
                      style: TextStyle(
                        color: isProduct ? Colors.greenAccent : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      isProduct ? 'Sản phẩm' : 'Nguyên liệu',
                      style: TextStyle(
                        color: isProduct
                            ? Colors.green.shade300
                            : Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              // Nút thùng rác
              IconButton(
                onPressed: onTrash,
                icon: const Icon(Icons.delete_outline),
                color: Colors.redAccent.withValues(alpha: 0.7),
                iconSize: 20,
                visualDensity: VisualDensity.compact,
                tooltip: 'Bỏ thùng rác',
              ),

              // Hướng dẫn vuốt
              const Icon(
                Icons.swipe,
                size: 16,
                color: Colors.white24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _itemEmoji(GameItem item) {
    if (item.type == GameItemType.ingredient) {
      final ingredient = Ingredient.values.cast<Ingredient?>().firstWhere(
        (i) => i!.name == item.itemId,
        orElse: () => null,
      );
      return ingredient?.emoji ?? '📦';
    }
    // Sản phẩm
    switch (item.itemId) {
      case 'orange_juice':
        return '🍊🧃';
      case 'lemonade':
        return '🍋🧃';
      case 'cut_strawberry':
        return '🍓🔪';
      case 'strawberry_smoothie':
        return '🍓🥤';
      case 'citrus_cocktail':
        return '🍸';
      case 'strawberry_lemonade':
        return '🍹';
      default:
        return '📦';
    }
  }

  String _itemDisplayName(GameItem item) {
    if (item.type == GameItemType.ingredient) {
      final ingredient = Ingredient.values.cast<Ingredient?>().firstWhere(
        (i) => i!.name == item.itemId,
        orElse: () => null,
      );
      return ingredient?.displayName ?? item.itemId;
    }
    switch (item.itemId) {
      case 'orange_juice':
        return 'Nước cam ép';
      case 'lemonade':
        return 'Nước chanh ép';
      case 'cut_strawberry':
        return 'Dâu tây đã cắt';
      case 'strawberry_smoothie':
        return 'Sinh tố dâu';
      case 'citrus_cocktail':
        return 'Cocktail cam chanh';
      case 'strawberry_lemonade':
        return 'Nước chanh dâu';
      default:
        return item.itemId;
    }
  }
}
