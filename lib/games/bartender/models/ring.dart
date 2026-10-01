/// Toán vòng tròn (ring math) cho N người chơi.
///
/// Người chơi được xếp thành vòng tròn theo ringIndex (0-based).
/// Vuốt trái = gửi cho người liền trái, vuốt phải = gửi cho người liền phải.
/// Vòng tròn wrap-around: người cuối nối với người đầu.
///
/// Xem PROJECT_SPEC.md: "(index ± 1) mod playerCount"
/// Logic tổng quát cho N người bất kỳ, không hard-code 4.
class Ring {
  Ring._();

  /// Tính ringIndex của người bên trái (vuốt trái = gửi đi hướng này).
  ///
  /// [currentIndex]: vị trí hiện tại (0-based).
  /// [playerCount]: tổng số người chơi (phải ≥ 2).
  ///
  /// Trả về ringIndex của người liền kề bên trái.
  static int leftNeighbor(int currentIndex, int playerCount) {
    assert(playerCount >= 2, 'Cần ít nhất 2 người chơi');
    assert(
      currentIndex >= 0 && currentIndex < playerCount,
      'currentIndex phải trong khoảng [0, playerCount)',
    );
    return (currentIndex - 1) % playerCount;
  }

  /// Tính ringIndex của người bên phải (vuốt phải = gửi đi hướng này).
  ///
  /// [currentIndex]: vị trí hiện tại (0-based).
  /// [playerCount]: tổng số người chơi (phải ≥ 2).
  ///
  /// Trả về ringIndex của người liền kề bên phải.
  static int rightNeighbor(int currentIndex, int playerCount) {
    assert(playerCount >= 2, 'Cần ít nhất 2 người chơi');
    assert(
      currentIndex >= 0 && currentIndex < playerCount,
      'currentIndex phải trong khoảng [0, playerCount)',
    );
    return (currentIndex + 1) % playerCount;
  }
}
