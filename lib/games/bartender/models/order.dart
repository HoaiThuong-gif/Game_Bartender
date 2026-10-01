/// Một đơn hàng được giao cho người chơi trong một round.
///
/// Khớp với schema Firebase: rooms/{code}/orders/{playerId}/{orderId}/
/// Xem API.md cho chi tiết các trường.
class Order {
  const Order({
    required this.id,
    required this.recipeId,
    this.status = OrderStatus.pending,
  });

  /// ID duy nhất của đơn này.
  final String id;

  /// ID công thức cần hoàn thành (tham chiếu tới Recipe.id).
  /// Công thức là dữ liệu tĩnh trong app, không lưu trên Firebase.
  final String recipeId;

  /// Trạng thái đơn: đang chờ hay đã nộp.
  final OrderStatus status;

  /// Đơn đã được hoàn thành chưa.
  bool get isCompleted => status == OrderStatus.submitted;

  /// Tạo bản sao với trạng thái mới.
  Order copyWith({OrderStatus? status}) {
    return Order(
      id: id,
      recipeId: recipeId,
      status: status ?? this.status,
    );
  }

  @override
  String toString() => 'Order($id, recipe=$recipeId, $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Order &&
          id == other.id &&
          recipeId == other.recipeId &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, recipeId, status);
}

/// Trạng thái đơn hàng. Khớp với trường "status" trong API.md.
enum OrderStatus {
  /// Đang chờ hoàn thành.
  pending,

  /// Đã nộp xong.
  submitted,
}
