import 'ingredient.dart';
import 'recipe.dart';
import 'station.dart';

/// Tập công thức tĩnh của game — 5 công thức từ dễ đến khó.
///
/// "Tập cố định 3-5 công thức, độ khó tăng dần theo round."
///
/// Difficulty 1 = chỉ cần 1 nguyên liệu, 1 bước, 1 trạm.
/// Difficulty 2 = 2 nguyên liệu, 2 bước, có thể cần 2 trạm khác nhau.
/// Difficulty 3 = nhiều nguyên liệu, nhiều bước, tối đa 3 trạm (D16).
///
/// D16: Không công thức nào cần quá 3 loại trạm khác nhau.
/// strawberry_lemonade giảm từ 4 bước (4 trạm) xuống còn 3 bước (3 trạm).
///
/// dùng processItem() trong models/processing_rules.dart (D19).
///
/// Đường chế biến của từng công thức:
/// 1. orange_juice:       orange --(juicer)--> orange_juice
/// 2. lemonade:           lemon  --(juicer)--> lemon_juice → đây là sản phẩm "lemonade"
/// 3. strawberry_smoothie: strawberry --(cuttingBoard)--> cut_strawberry --(blender)--> strawberry_smoothie
/// 4. citrus_cocktail:    orange --(juicer)--> orange_juice --(shaker)--> citrus_cocktail
///                     OR lemon  --(juicer)--> lemon_juice  --(shaker)--> citrus_cocktail
/// 5. strawberry_lemonade: lemon --(juicer)--> lemon_juice
///                          lemon_juice --(blender)--> strawberry_lemonade_blend
///                          strawberry_lemonade_blend --(shaker)--> strawberry_lemonade
class RecipePool {
  RecipePool._();

  /// Tất cả công thức có trong game, sắp theo độ khó tăng dần.
  static const List<Recipe> allRecipes = [
    // --- Difficulty 1: đơn giản, 1 nguyên liệu, 1 trạm ---
    Recipe(
      id: 'orange_juice',
      name: 'Nước cam',
      ingredients: [Ingredient.orange],
      steps: [RecipeStep(station: StationType.juicer, description: 'Ép cam')],
      difficulty: 1,
      // Đường chế biến: orange → (juicer) → orange_juice
      productId: 'orange_juice',
    ),
    Recipe(
      id: 'lemonade',
      name: 'Nước chanh',
      ingredients: [Ingredient.lemon],
      steps: [RecipeStep(station: StationType.juicer, description: 'Ép chanh')],
      difficulty: 1,
      // Đường chế biến: lemon → (juicer) → lemon_juice (= sản phẩm nộp)
      productId: 'lemon_juice',
    ),

    // --- Difficulty 2: 2 nguyên liệu, 2 bước, cần 2 trạm ---
    Recipe(
      id: 'strawberry_smoothie',
      name: 'Sinh tố dâu',
      ingredients: [Ingredient.strawberry, Ingredient.milk],
      steps: [
        RecipeStep(station: StationType.cuttingBoard, description: 'Cắt dâu'),
        RecipeStep(
          station: StationType.blender,
          description: 'Xay dâu đã cắt thành sinh tố',
        ),
      ],
      difficulty: 2,
      // Đường chế biến: strawberry → (cuttingBoard) → cut_strawberry → (blender) → strawberry_smoothie
      productId: 'strawberry_smoothie',
    ),

    // --- Difficulty 3: nhiều nguyên liệu, nhiều bước, tối đa 3 trạm ---
    Recipe(
      id: 'citrus_cocktail',
      name: 'Cocktail cam chanh',
      ingredients: [Ingredient.orange, Ingredient.lemon, Ingredient.ice],
      steps: [
        RecipeStep(
          station: StationType.juicer,
          description: 'Ép cam hoặc chanh',
        ),
        RecipeStep(station: StationType.shaker, description: 'Lắc trộn với đá'),
      ],
      difficulty: 3,
      // Đường chế biến: orange → (juicer) → orange_juice → (shaker) → citrus_cocktail
      //              OR lemon  → (juicer) → lemon_juice  → (shaker) → citrus_cocktail
      productId: 'citrus_cocktail',
    ),
    // Bước D16: strawberry_lemonade giảm từ 4 bước (4 trạm) xuống 3 bước (3 trạm):
    // juicer "Ép chanh" → blender "Xay dâu + nước chanh" → shaker "Lắc trộn với đá và đường"
    Recipe(
      id: 'strawberry_lemonade',
      name: 'Nước chanh dâu',
      ingredients: [
        Ingredient.strawberry,
        Ingredient.lemon,
        Ingredient.sugar,
        Ingredient.ice,
      ],
      steps: [
        RecipeStep(station: StationType.juicer, description: 'Ép chanh'),
        RecipeStep(
          station: StationType.blender,
          description: 'Xay dâu + nước chanh',
        ),
        RecipeStep(
          station: StationType.shaker,
          description: 'Lắc trộn với đá và đường',
        ),
      ],
      difficulty: 3,
      // Đường chế biến: lemon → (juicer) → lemon_juice
      //                 strawberry + lemon_juice → (blender) → strawberry_lemonade_blend
      //                 strawberry_lemonade_blend → (shaker) → strawberry_lemonade
      productId: 'strawberry_lemonade',
    ),
  ];

  /// Lấy công thức khả dụng cho round cụ thể.
  ///
  /// Round 1: chỉ difficulty 1.
  /// Round 2: difficulty 1-2.
  /// Round 3+: tất cả.
  ///
  /// round sau rút từ tập bao gồm cả công thức khó hơn."
  static List<Recipe> recipesForRound(int roundNumber) {
    // maxDifficulty tăng dần: round 1→1, round 2→2, round 3+→3.
    final maxDifficulty = roundNumber.clamp(1, 3);
    return allRecipes.where((r) => r.difficulty <= maxDifficulty).toList();
  }
}
