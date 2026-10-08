import 'package:flutter/material.dart';

import 'lobby_cats.dart';

/// Measured visible artwork bounds, in the original 1254 px hat canvas.
/// Target anchors are in each cat's original atlas, before sleeping rotation.
abstract final class NonLaFit {
  static const artwork = [
    Rect.fromLTWH(103, 98, 533, 388),
    Rect.fromLTWH(544, 251, 659, 426),
    Rect.fromLTWH(40, 413, 595, 376),
    Rect.fromLTWH(497, 735, 687, 434),
  ];

  // (center of the brim region, artwork width). All scaling stays uniform.
  static const _fits = {
    CatType.black: [
      (285.0, 80.0, 400.0),
      (940.0, 215.0, 340.0),
      (170.0, 695.0, 340.0),
      (870.0, 925.0, 400.0),
    ],
    CatType.orange: [
      (315.0, 85.0, 340.0),
      (975.0, 215.0, 300.0),
      (165.0, 685.0, 320.0),
      (875.0, 940.0, 390.0),
    ],
    CatType.tuxedo: [
      (332.0, 105.0, 325.0),
      (907.0, 165.0, 345.0),
      (182.0, 720.0, 315.0),
      (842.0, 885.0, 385.0),
    ],
  };

  static Rect target(LobbyCat cat) {
    final (x, y, width) = _fits[cat.type]![cat.pose.index];
    final height =
        width * artwork[cat.pose.index].height / artwork[cat.pose.index].width;
    // Brim anchor is 62% down the isolated artwork; includes hanging straps.
    return Rect.fromLTWH(x - width / 2, y - height * .62, width, height);
  }

  static String asset(CatPose pose) =>
      'assets/images/gacha/cat_wearables/non_la/pose_${pose.index + 1}.png';
}
