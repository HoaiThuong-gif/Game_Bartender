/// Các loại nguyên liệu có trong game.
///
/// Nguyên liệu xuất hiện trên màn hình người chơi theo chu kỳ (~3 giây).
/// Mỗi công thức (Recipe) yêu cầu một tập nguyên liệu cụ thể.
enum Ingredient {
  /// Cam — dùng cho nước ép, cocktail.
  orange,

  /// Chanh — dùng cho cocktail, nước chanh.
  lemon,

  /// Dâu tây — dùng cho sinh tố.
  strawberry,

  /// Đá — dùng cho hầu hết đồ uống.
  ice,

  /// Sữa — dùng cho sinh tố.
  milk,

  /// Đường — dùng cho nhiều loại đồ uống.
  sugar,
}

/// Alias thuận tiện để dùng đồng nghĩa với Ingredient.
typedef IngredientType = Ingredient;

extension IngredientExtension on Ingredient {
  /// Tên tiếng Việt hiển thị trên giao diện.
  String get displayName {
    switch (this) {
      case Ingredient.orange:
        return 'Cam tươi';
      case Ingredient.lemon:
        return 'Chanh vàng';
      case Ingredient.strawberry:
        return 'Dâu tây';
      case Ingredient.ice:
        return 'Đá viên';
      case Ingredient.milk:
        return 'Sữa tươi';
      case Ingredient.sugar:
        return 'Đường cát';
    }
  }

  /// Emoji / ký hiệu tạm thời hiển thị khi chưa nạp asset ảnh.
  String get emoji {
    switch (this) {
      case Ingredient.orange:
        return '🍊';
      case Ingredient.lemon:
        return '🍋';
      case Ingredient.strawberry:
        return '🍓';
      case Ingredient.ice:
        return '🧊';
      case Ingredient.milk:
        return '🥛';
      case Ingredient.sugar:
        return '🍬';
    }
  }
}

