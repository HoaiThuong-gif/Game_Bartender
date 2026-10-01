import 'ingredient.dart';
import 'station.dart';

/// Một công đoạn chế biến trong công thức.
///
/// Mỗi bước yêu cầu một trạm cụ thể để thực hiện.
/// Ví dụ: "cắt cam" cần trạm cuttingBoard.
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
///
/// Công thức là dữ liệu tĩnh, đóng gói trong app, không lưu trên Firebase.
/// Firebase chỉ lưu recipeId (xem API.md).
class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.steps,
    required this.difficulty,
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

  @override
  String toString() => 'Recipe($id, difficulty=$difficulty)';
}
