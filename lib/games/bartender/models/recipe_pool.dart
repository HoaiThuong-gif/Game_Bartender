import 'ingredient.dart';
import 'recipe.dart';
import 'station.dart';

/// Tập công thức tĩnh của game — 5 công thức từ dễ đến khó.
///
/// Xem PROJECT_SPEC.md: "3 đến 5 công thức" và DECISIONS.md D7:
/// "Tập cố định 3-5 công thức, độ khó tăng dần theo round."
///
/// Difficulty 1 = chỉ cần 1 nguyên liệu, 1 bước, 1 trạm.
/// Difficulty 2 = 2 nguyên liệu, 2 bước, có thể cần 2 trạm khác nhau.
/// Difficulty 3 = nhiều nguyên liệu, nhiều bước, nhiều trạm.
class RecipePool {
  RecipePool._();

  /// Tất cả công thức có trong game, sắp theo độ khó tăng dần.
  static const List<Recipe> allRecipes = [
    // --- Difficulty 1: đơn giản, 1 nguyên liệu, 1 trạm ---
    Recipe(
      id: 'orange_juice',
      name: 'Nước cam',
      ingredients: [Ingredient.orange],
      steps: [
        RecipeStep(station: StationType.juicer, description: 'Ép cam'),
      ],
      difficulty: 1,
    ),
    Recipe(
      id: 'lemonade',
      name: 'Nước chanh',
      ingredients: [Ingredient.lemon],
      steps: [
        RecipeStep(station: StationType.juicer, description: 'Ép chanh'),
      ],
      difficulty: 1,
    ),

    // --- Difficulty 2: 2 nguyên liệu, 2 bước, cần 2 trạm ---
    Recipe(
      id: 'strawberry_smoothie',
      name: 'Sinh tố dâu',
      ingredients: [Ingredient.strawberry, Ingredient.milk],
      steps: [
        RecipeStep(
          station: StationType.cuttingBoard,
          description: 'Cắt dâu',
        ),
        RecipeStep(
          station: StationType.blender,
          description: 'Xay sinh tố',
        ),
      ],
      difficulty: 2,
    ),

    // --- Difficulty 3: nhiều nguyên liệu, nhiều bước, nhiều trạm ---
    Recipe(
      id: 'citrus_cocktail',
      name: 'Cocktail cam chanh',
      ingredients: [Ingredient.orange, Ingredient.lemon, Ingredient.ice],
      steps: [
        RecipeStep(station: StationType.juicer, description: 'Ép cam'),
        RecipeStep(station: StationType.juicer, description: 'Ép chanh'),
        RecipeStep(
          station: StationType.shaker,
          description: 'Lắc trộn với đá',
        ),
      ],
      difficulty: 3,
    ),
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
        RecipeStep(
          station: StationType.cuttingBoard,
          description: 'Cắt dâu',
        ),
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
    ),
  ];

  /// Lấy công thức khả dụng cho round cụ thể.
  ///
  /// Round 1: chỉ difficulty 1.
  /// Round 2: difficulty 1-2.
  /// Round 3+: tất cả.
  ///
  /// Xem DECISIONS.md D7: "round đầu chỉ rút từ công thức dễ;
  /// round sau rút từ tập bao gồm cả công thức khó hơn."
  static List<Recipe> recipesForRound(int roundNumber) {
    // maxDifficulty tăng dần: round 1→1, round 2→2, round 3+→3.
    final maxDifficulty = roundNumber.clamp(1, 3);
    return allRecipes
        .where((r) => r.difficulty <= maxDifficulty)
        .toList();
  }
}
