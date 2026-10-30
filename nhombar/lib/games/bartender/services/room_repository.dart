import '../models/game_item.dart';
import '../models/room.dart';
import '../models/station.dart';

/// Interface trừu tượng cho tầng truy xuất dữ liệu phòng chơi Bartender.
///
/// Các controller và widgets chỉ phụ thuộc vào interface này,
/// không bao giờ phụ thuộc trực tiếp vào Firebase hay Fake implementation.
///
/// Xem ARCHITECTURE.md mục "Các lớp nội bộ":
/// - [FakeRoomRepository]: in-memory, dùng cho local dev và single-device loop.
/// - [FirebaseRoomRepository]: RTDB thật cho multi-device play (giai đoạn 5).
abstract interface class RoomRepository {
  /// ID của người chơi trên máy này.
  /// Fake: 'p_0' khi tạo phòng, id được gán khi join.
  /// Firebase: uid từ FirebaseAuth (anonymous).
  String get localPlayerId;

  /// Tạo phòng mới với tên người tạo (host).
  /// [totalPlayers]: tổng số người chơi (mặc định 3 cho single-device loop).
  Future<Room> createRoom({
    required String hostPlayerName,
    int totalPlayers = 3,
  });

  /// Tham gia phòng đã có bằng mã phòng [code].
  Future<Room> joinRoom({
    required String code,
    required String playerName,
  });

  /// Rời phòng.
  Future<void> leaveRoom({
    required String code,
    required String playerId,
  });

  /// Bắt đầu trận đấu (chỉ gọi khi room.canStart == true).
  Future<void> startMatch({required String code});

  /// Lắng nghe stream thay đổi trạng thái của phòng.
  Stream<Room> watchRoom(String code);

  /// Chuyền một vật phẩm từ [fromRingIndex] sang [toRingIndex].
  /// Thao tác vuốt trái hoặc phải giữa hai người liền kề trong vòng tròn.
  Future<void> sendItem({
    required String code,
    required int fromRingIndex,
    required int toRingIndex,
    required GameItem item,
  });

  /// Bỏ một vật phẩm vào thùng rác để giải phóng không gian.
  Future<void> trashItem({
    required String code,
    required int ringIndex,
    required String itemId,
  });

  /// Chế biến một vật phẩm tại trạm [station].
  /// Trả về vật phẩm sau khi chế biến (ví dụ: cam -> nước cam ép).
  Future<GameItem> processItemAtStation({
    required String code,
    required int ringIndex,
    required String itemId,
    required StationType station,
  });

  /// Nộp đơn hàng đã hoàn thành.
  /// [productId] là itemId của sản phẩm hoàn chỉnh khớp với [orderId].
  Future<void> submitOrder({
    required String code,
    required String playerId,
    required String orderId,
    required String productId,
  });

  /// Kết thúc trận đấu. Ghi results và đặt status = ended.
  /// Idempotent: nếu trận đã kết thúc thì không làm gì.
  /// Fake: gọi _endMatch nội bộ. Firebase: dùng transaction (D17).
  Future<void> endMatch(String code);

  /// Giải phóng tài nguyên / stream controllers.
  void dispose();
}
