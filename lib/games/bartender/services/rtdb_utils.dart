/// Tiện ích dùng chung khi đọc/ghi Firebase Realtime Database.
///
/// RTDB có thể trả về Map hoặc List tuỳ theo dạng key
/// (nếu key là "0", "1", "2" liên tục → List; ngược lại → Map).
/// Hàm [asMap] chuẩn hoá kết quả về `Map<String, dynamic>`.
library;

/// Chuẩn hoá dữ liệu từ RTDB thành `Map<String, dynamic>`.
///
/// - null → {}
/// - Map → chuyển tất cả key thành String, bỏ entry có value null.
/// - List → chuyển index thành key dạng String ("0", "1", …), bỏ phần tử null.
/// - Loại khác → {} (an toàn).
Map<String, dynamic> asMap(Object? data) {
  if (data == null) return <String, dynamic>{};
  if (data is Map) {
    final res = <String, dynamic>{};
    for (final e in data.entries) {
      if (e.value != null) {
        res[e.key.toString()] = e.value;
      }
    }
    return res;
  }
  if (data is List) {
    final res = <String, dynamic>{};
    for (var i = 0; i < data.length; i++) {
      if (data[i] != null) {
        res[i.toString()] = data[i];
      }
    }
    return res;
  }
  return <String, dynamic>{};
}
