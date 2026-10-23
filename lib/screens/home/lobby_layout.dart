import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Source pixels on the 1774x887 panorama. Each outline is the original
/// projected surface, not a camera-facing sprite. PNGs retain source lighting.
abstract final class LobbyLayout {
  static const designSize = Size(1774, 887);
  static const backgroundAsset = 'assets/images/lobby/background.png';
  static const arcade = LobbyPlacement(
    asset: 'assets/images/lobby/picture.png',
    warpToCorners: true,
    bounds: Rect.fromLTWH(677, 313, 116, 123),
    corners: [
      Offset(680, 316),
      Offset(790, 335),
      Offset(790, 433),
      Offset(680, 434),
    ],
    contact: Offset(735, 434),
  );
  static const tv = LobbyPlacement(
    asset: 'assets/images/lobby/tv.png',
    warpToCorners: true,
    bounds: Rect.fromLTWH(1452, 353, 194, 152),
    corners: [
      Offset(1455, 378),
      Offset(1643, 355),
      Offset(1643, 503),
      Offset(1455, 484),
    ],
    contact: Offset(1549, 494),
  );
  static const bartender = LobbyPlacement(
    asset: 'assets/images/lobby/bartender.png',
    // Alpha-cropped tray is 1571x945; its long edges follow the dining table.
    // Tray footprint is centered at the dining top's diagonal intersection.
    bounds: Rect.fromLTWH(284, 481, 92, 92 * 945 / 1571),
    corners: [
      Offset(288, 514),
      Offset(348, 492),
      Offset(376, 506),
      Offset(314, 536),
    ],
    contact: Offset(333, 510),
  );
  static const rubik = LobbyPlacement(
    asset: 'assets/images/lobby/rubik.png',
    // New cube is 881x994 after alpha cropping. Its lower vertex touches marble.
    bounds: Rect.fromLTWH(702, 617 - 26 * 994 / 881, 26, 26 * 994 / 881),
    corners: [
      Offset(702, 594),
      Offset(715, 588),
      Offset(728, 594),
      Offset(728, 610),
      Offset(715, 617),
      Offset(702, 610),
    ],
    contact: Offset(715, 617),
    hitPadding: 4,
  );
}

class LobbyPlacement {
  const LobbyPlacement({
    required this.asset,
    required this.bounds,
    required this.corners,
    required this.contact,
    this.hitPadding = 2,
    this.warpToCorners = false,
    this.planar = false,
  });
  final String asset;
  final Rect bounds;
  final List<Offset> corners;
  final Offset contact;
  final double hitPadding;
  final bool warpToCorners;

  /// Project a flat image through its four world corners, keeping edges straight.
  final bool planar;
  double get yaw =>
      (bounds.center.dx / LobbyLayout.designSize.width - .5) * 2 * math.pi;
  double get pitch =>
      (.5 - bounds.center.dy / LobbyLayout.designSize.height) * math.pi;
  // Surface contact used by entry feedback and nearby cat reactions.
  double get x => contact.dx;
  double get y => contact.dy;
  Rect get visualRect => bounds;
}
