/// Vật phẩm đang lưu thông trong game — có thể là nguyên liệu thô
/// hoặc sản phẩm đã (đang) chế biến.
///
/// Vật phẩm được chuyền giữa người chơi bằng vuốt trái/phải,
/// hoặc bỏ vào thùng rác. Xem PROJECT_SPEC.md mục "Nguyên liệu & vật phẩm".
///
/// Trên Firebase, item nằm trong inbox/{ringIndex}/{itemId}/ — xem API.md.
class GameItem {
  const GameItem({
    required this.id,
    required this.type,
    required this.itemId,
    required this.fromRingIndex,
  });

  /// ID duy nhất của vật phẩm này (dùng làm key trong Firebase).
  final String id;

  /// Loại: nguyên liệu thô hay sản phẩm đã chế biến.
  final GameItemType type;

  /// ID tham chiếu (ingredient enum name hoặc recipe id tùy theo type).
  final String itemId;

  /// Vị trí ring của người gửi (để UI có thể hiện "nhận từ ai").
  final int fromRingIndex;

  @override
  String toString() => 'GameItem($id, $type, $itemId, from=$fromRingIndex)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameItem &&
          id == other.id &&
          type == other.type &&
          itemId == other.itemId &&
          fromRingIndex == other.fromRingIndex;

  @override
  int get hashCode => Object.hash(id, type, itemId, fromRingIndex);
}

/// Phân biệt nguyên liệu thô và sản phẩm đã/đang chế biến.
/// Khớp với trường "type" trong API.md schema inbox.
enum GameItemType {
  /// Nguyên liệu thô, chưa qua chế biến.
  ingredient,

  /// Sản phẩm đã (hoặc đang) chế biến.
  product,
}
