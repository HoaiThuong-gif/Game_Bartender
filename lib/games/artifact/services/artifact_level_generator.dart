import 'dart:math';

import '../models/artifact_puzzle.dart';

class ArtifactLevelGenerator {
  ArtifactLevelGenerator({Random? random});

  ArtifactLevel generate(int number) {
    if (number < 1) throw ArgumentError.value(number, 'number');
    if (number == 1) {
      return ArtifactLevel(
        ArtifactPuzzle(
          level: 1,
          shape: ArtifactShape.cube,
          targets: const [],
          links: const [],
          sliderCount: 0,
        ),
        ArtifactState(
          const [],
          const [],
          const [false, false, false],
          const [false, false, false, false, false, false, false],
        ),
        // Eight successful moves; the ninth discovery is trying the blocked D.
        8,
      );
    }
    if (number > 5) {
      throw ArgumentError.value(number, 'number', 'Chỉ có 5 cổ vật.');
    }
    final puzzle = ArtifactPuzzle(
      level: number,
      shape: number == 2 || number == 4
          ? ArtifactShape.cylinder
          : ArtifactShape.hexagonalPrism,
      targets: const [],
      links: const [],
      sliderCount: 0,
    );
    return ArtifactLevel(
      puzzle,
      ArtifactState(const [], const [], const [
        false,
        false,
        false,
      ], List.filled(puzzle.joints.length, false)),
      const {2: 5, 3: 7, 4: 9, 5: 11}[number]!,
    );
  }
}
