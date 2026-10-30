import 'game_item.dart';
import 'match_result.dart';
import 'match_timer.dart';
import 'player.dart';
import 'round.dart';

/// Trạng thái phòng chơi — aggregate chứa tất cả dữ liệu của một trận.
///
/// Khớp với schema Firebase gốc: rooms/{roomCode}/
/// Xem API.md cho chi tiết đầy đủ.
///
/// Đây là "source of truth" phía client — controller đọc/ghi Room qua
/// RoomRepository interface (xem ARCHITECTURE.md).
class Room {
  const Room({
    required this.code,
    required this.status,
    required this.players,
    this.serverNowMs,
    this.timer,
    this.currentRound,
    this.inbox = const {},
    this.results,
  });

  /// Mã phòng (ví dụ "4821"). Dùng để người khác nhập vào phòng.
  final String code;

  /// Trạng thái phòng hiện tại.
  final RoomStatus status;

  /// Thời gian server (ms since epoch) nhận từ server snapshot (API.md).
  final int? serverNowMs;

  /// Danh sách người chơi. Key = playerId.
  final Map<String, Player> players;

  /// Đồng hồ chung (null khi phòng đang ở lobby, chưa bắt đầu trận).
  final MatchTimer? timer;

  /// Round hiện tại (null khi chưa bắt đầu trận).
  final Round? currentRound;

  /// Hộp thư / vật phẩm trên màn hình của từng người chơi theo ringIndex.
  /// Key = ringIndex, Value = danh sách GameItem đang có trên màn hình.
  /// Khớp với API.md schema: inbox/{ringIndex}/{itemId}/
  final Map<int, List<GameItem>> inbox;

  /// Kết quả trận đấu khi ended.
  /// Khớp với API.md schema: results/
  final MatchResult? results;

  /// Số người chơi đang kết nối.
  int get connectedPlayerCount =>
      players.values.where((p) => p.connected).length;

  /// Tổng số người chơi (kể cả đã thoát — slot vẫn giữ).
  int get totalPlayerCount => players.length;

  /// Tất cả người chơi đang kết nối đã sẵn sàng trong phòng chờ hay chưa.
  bool get allPlayersReadyInLobby =>
      players.values.where((p) => p.connected).every((p) => p.readyInLobby);

  /// Số người chơi đang kết nối đã sẵn sàng trong phòng chờ.
  int get readyPlayerCount =>
      players.values.where((p) => p.connected && p.readyInLobby).length;

  /// Có đủ người và mọi người đã ở trong phòng chờ để bắt đầu trận không.
  /// Hỗ trợ cả trạng thái lobby và ended (sau khi quay lại phòng ban đầu).
  bool get canStart =>
      (status == RoomStatus.lobby || status == RoomStatus.ended) &&
      connectedPlayerCount >= 2 &&
      allPlayersReadyInLobby;

  /// Lấy Player theo ringIndex.
  Player? playerAtRing(int ringIndex) {
    return players.values.cast<Player?>().firstWhere(
      (p) => p!.ringIndex == ringIndex,
      orElse: () => null,
    );
  }

  /// Lấy danh sách item trong inbox của một ringIndex.
  List<GameItem> itemsAtRing(int ringIndex) => inbox[ringIndex] ?? const [];

  /// Tạo bản sao với một số trường thay đổi.
  Room copyWith({
    RoomStatus? status,
    int? serverNowMs,
    Map<String, Player>? players,
    MatchTimer? timer,
    Round? currentRound,
    Map<int, List<GameItem>>? inbox,
    MatchResult? results,
    bool clearResults = false,
  }) {
    return Room(
      code: code,
      status: status ?? this.status,
      serverNowMs: serverNowMs ?? this.serverNowMs,
      players: players ?? this.players,
      timer: timer ?? this.timer,
      currentRound: currentRound ?? this.currentRound,
      inbox: inbox ?? this.inbox,
      results: clearResults ? null : (results ?? this.results),
    );
  }

  /// Chuyển thành JSON map khớp với API.md schema room snapshot.
  Map<String, dynamic> toJson({int? currentServerNowMs}) {
    final nowMs =
        currentServerNowMs ??
        serverNowMs ??
        DateTime.now().millisecondsSinceEpoch;
    return {
      'code': code,
      'status': status.name,
      'serverNowMs': nowMs,
      'players': players.map((k, v) => MapEntry(k, v.toJson())),
      'timer': timer?.toJson(),
      'currentRound': currentRound?.toJson(),
      'inbox': inbox.map(
        (k, v) =>
            MapEntry(k.toString(), v.map((item) => item.toJson()).toList()),
      ),
      'results': results?.toJson(),
    };
  }

  /// Khởi tạo từ JSON map của room snapshot.
  factory Room.fromJson(Map<String, dynamic> json, {int? localNowMs}) {
    final serverNowMs = (json['serverNowMs'] as num?)?.toInt();
    final offset = (serverNowMs != null && localNowMs != null)
        ? (serverNowMs - localNowMs)
        : 0;

    final rawPlayers = (json['players'] as Map<String, dynamic>?) ?? {};
    final players = rawPlayers.map((k, v) {
      return MapEntry(k, Player.fromJson(v as Map<String, dynamic>));
    });

    final timerJson = json['timer'] as Map<String, dynamic>?;
    final timer = timerJson != null
        ? MatchTimer.fromJson(timerJson, serverOffsetMs: offset)
        : null;

    final roundJson = json['currentRound'] as Map<String, dynamic>?;
    final currentRound = roundJson != null ? Round.fromJson(roundJson) : null;

    final rawInbox = (json['inbox'] as Map<String, dynamic>?) ?? {};
    final inbox = rawInbox.map((k, v) {
      final ring = int.parse(k);
      final items = (v as List<dynamic>)
          .map((item) => GameItem.fromJson(item as Map<String, dynamic>))
          .toList();
      return MapEntry(ring, items);
    });

    final resultsJson = json['results'] as Map<String, dynamic>?;
    final results = resultsJson != null
        ? MatchResult.fromJson(resultsJson)
        : null;

    final statusStr = json['status'] as String? ?? 'lobby';
    final status = RoomStatus.values.byName(statusStr);

    return Room(
      code: json['code'] as String? ?? '',
      status: status,
      serverNowMs: serverNowMs,
      players: players,
      timer: timer,
      currentRound: currentRound,
      inbox: inbox,
      results: results,
    );
  }

  @override
  String toString() =>
      'Room($code, $status, ${players.length} players, '
      'round=${currentRound?.number})';
}

/// Trạng thái phòng. Khớp với trường "status" trong API.md.
enum RoomStatus {
  /// Đang chờ người chơi vào — chưa bắt đầu trận.
  lobby,

  /// Đang chơi.
  playing,

  /// Trận đã kết thúc (đồng hồ về 0).
  ended,
}
