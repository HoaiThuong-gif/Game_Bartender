import 'station.dart';

/// Quy tắc chế biến DUY NHẤT (D19) — Fake, Firebase và giao diện đều dùng.
/// Trả về itemId sau khi chế biến, hoặc null nếu trạm không xử lý được vật phẩm.
String? processItem(String itemId, StationType station) {
  switch (station) {
    case StationType.juicer:
      if (itemId == 'orange') return 'orange_juice';
      if (itemId == 'lemon') return 'lemon_juice';
    case StationType.cuttingBoard:
      if (itemId == 'strawberry') return 'cut_strawberry';
    case StationType.blender:
      if (itemId == 'cut_strawberry') return 'strawberry_smoothie';
      if (itemId == 'lemon_juice') return 'strawberry_lemonade_blend';
    case StationType.shaker:
      if (itemId == 'orange_juice' || itemId == 'lemon_juice') {
        return 'citrus_cocktail';
      }
      if (itemId == 'strawberry_lemonade_blend') return 'strawberry_lemonade';
  }
  return null;
}
