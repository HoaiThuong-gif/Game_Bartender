/// Các loại trạm chế biến trong game.
///
/// Mỗi round, mỗi người chơi được phân ngẫu nhiên một trạm (hoặc không có).
/// Trạm quyết định thao tác chế biến mà người chơi có thể thực hiện.
/// Xem PROJECT_SPEC.md mục "Trạm chế biến" và DECISIONS.md D5.
enum StationType {
  /// Dao/thớt — cắt nguyên liệu (thao tác: chạm/kéo thả).
  cuttingBoard,

  /// Máy xay — xay nhuyễn (thao tác: chạm/kéo thả).
  blender,

  /// Máy ép — ép lấy nước (thao tác: chạm/kéo thả).
  juicer,

  /// Bình lắc — lắc trộn (thao tác: lắc điện thoại, dùng sensors_plus).
  /// Đây là trạm duy nhất dùng cảm biến — xem DECISIONS.md D6.
  shaker,
}
