class GachaReward {
  const GachaReward({
    required this.number,
    required this.name,
    required this.iconAssetPath,
    required this.modelAssetPath,
  });

  final int number;
  String get id => 'gacha_$number';
  String get modelPath => modelAssetPath;
  String get imagePath => iconAssetPath;
  final String name;

  /// PNG icon for the reward board and revealed result, independent of the GLB.
  final String iconAssetPath;

  /// Local GLB asset path. The viewer loads it only after the ticket is revealed.
  final String modelAssetPath;

  String get displayNumber => number.toString().padLeft(2, '0');
}
