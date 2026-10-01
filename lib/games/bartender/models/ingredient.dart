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
