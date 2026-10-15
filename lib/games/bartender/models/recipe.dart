import 'ingredient.dart';
import 'station.dart';

/// Một công đoạn chế biến trong công thức.
///
/// Mỗi bước yêu cầu một trạm cụ thể để thực hiện.
/// Ví dụ: "ép chanh" cần trạm juicer.
class RecipeStep {
  const RecipeStep({
    required this.station,
    required this.description,
  });

  /// Trạm cần để thực hiện bước này.
  final StationType station;

  /// Mô tả ngắn gọn bước chế biến (dùng cho UI).
  final String description;

  @override
  String toString() => 'RecipeStep($station: $description)';
}

/// Công thức pha chế.
///
/// Mỗi công thức có:
/// - Danh sách nguyên liệu cần thu thập.
/// - Danh sách các bước chế biến (mỗi bước gắn với một trạm).
/// - Độ khó (difficulty) để phân theo round — xem DECISIONS.md D7.
/// - [productId]: ID của sản phẩm cuối cùng dùng để khớp khi nộp đơn.
///
/// Công thức là dữ liệu tĩnh, đóng gói trong app, không lưu trên Firebase.
/// Firebase chỉ lưu recipeId (xem API.md).
///
/// D16: Không có công thức nào cần quá 3 loại trạm khác nhau.
class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.steps,
    required this.difficulty,
    required this.productId,
  });

  /// ID duy nhất, dùng làm key trong Firebase (ví dụ: "orange_juice").
  final String id;

  /// Tên hiển thị (ví dụ: "Nước cam").
  final String name;

  /// Danh sách nguyên liệu cần cho công thức.
  final List<Ingredient> ingredients;

  /// Các bước chế biến, theo thứ tự.
  final List<RecipeStep> steps;

  /// Độ khó: 1 = dễ nhất (round đầu), số lớn hơn = khó hơn.
  /// Xem DECISIONS.md D7: round đầu chỉ rút từ pool dễ, round sau mở rộng.
  final int difficulty;

  /// ID của sản phẩm cuối cùng khi hoàn thành công thức.
  ///
  /// Dùng để kiểm tra khi người chơi kéo sản phẩm vào vùng nộp đơn:
  /// sản phẩm phải có itemId == recipeId của đơn hoặc == productId của recipe đó.
  /// Xem firebase_room_repository.dart (processItem) và fake_room_repository.dart
  /// (_deriveProcessedProduct) — phải đồng bộ với nhau.
  final String productId;

  /// Số loại trạm khác nhau cần để làm công thức này.
  /// Xem DECISIONS.md D16: không quá 3.
  int get distinctStationCount =>
      steps.map((s) => s.station).toSet().length;

  @override
  String toString() =>
      'Recipe($id, difficulty=$difficulty, stations=$distinctStationCount)';
}
