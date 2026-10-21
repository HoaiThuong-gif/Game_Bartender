import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Measured from the CURRENT PNGs (alpha > 40). All positions refer to the
/// background canvas; transparent margins are excluded from anchor geometry.
abstract final class LobbyLayout {
  static const designSize = Size(941, 1672);
  static const backgroundAsset = 'assets/images/lobby/background.png';

  // TV feet meet the wooden tea table under the pendant lamp.
  static const tv = LobbyPlacement(
    asset: 'assets/images/lobby/frames/tv_0.png',
    imageSize: Size(620, 620),
    contentRect: Rect.fromLTWH(20, 87, 581, 513),
    x: 435,
    y: 758,
    width: 110,
  );

  static const _bartenderX = 180.0;
  static const _bartenderY = 1320.0;
  static const _bartenderWidth = 570.0;

  // Foreground stall: front feet sit on the courtyard paving.
  static const bartender = LobbyPlacement(
    asset: 'assets/images/lobby/frames/bartender_0.png',
    imageSize: Size(400, 480),
    contentRect: Rect.fromLTWH(23, 48, 354, 302),
    x: _bartenderX,
    y: _bartenderY,
    width: _bartenderWidth,
  );
  // Smaller, deeper in the scene, immediately in front of the right wall.
  static const arcade = LobbyPlacement(
    asset: 'assets/images/lobby/frames/games_0.png',
    imageSize: Size(500, 620),
    contentRect: Rect.fromLTWH(26, 39, 448, 561),
    x: 720,
    y: 1000,
    width: 240,
  );
  // The bottom of the cube meets the tabletop, inside its visible perimeter.
  static const rubik = LobbyPlacement(
    asset: 'assets/images/lobby/frames/rubik_0.png',
    imageSize: Size(336, 336),
    contentRect: Rect.fromLTWH(30, 22, 276, 293),
    x: 790,
    y: 1302,
    width: 86,
  );
  // Wall attachment, measured at source pixel (104, 900), not the flag's tip.
  static const flag = LobbyPlacement(
    asset: 'assets/images/lobby/frames/flag_0.png',
    imageSize: Size(600, 480),
    contentRect: Rect.fromLTWH(68, 85, 375, 321),
    x: 655,
    y: 455,
    width: 250,
    anchor: Offset((80 - 68) / 375, (398.5 - 85) / 321),
  );

  // Measured contact points on the authored red and blue seat surfaces.
  static const bartenderLeftSeat = Offset(244, 289);
  static const bartenderRightSeat = Offset(310, 284);
  static const bartenderLeftSeatX =
      _bartenderX + (244 - 200) * _bartenderWidth / 354;
  static const bartenderLeftSeatY =
      _bartenderY + (289 - 350) * _bartenderWidth / 354;
  static const bartenderRightSeatX =
      _bartenderX + (310 - 200) * _bartenderWidth / 354;
  static const bartenderRightSeatY =
      _bartenderY + (284 - 350) * _bartenderWidth / 354;

  static Rect viewportRect(Size viewport) {
    if (viewport.isEmpty) return Offset.zero & designSize;
    final cover = math.max(
      viewport.width / designSize.width,
      viewport.height / designSize.height,
    );
    final size = viewport / cover;
    return Rect.fromLTWH(
      (designSize.width - size.width) / 2,
      (designSize.height - size.height) / 2,
      size.width,
      size.height,
    );
  }

  static LobbyPlacement fitObject(LobbyPlacement placement, Size viewport) {
    if (placement.asset != bartender.asset && placement.asset != flag.asset) {
      return placement;
    }
    final scene = viewportRect(viewport).deflate(8);
    if (identical(placement, bartender)) {
      return LobbyPlacement(
        asset: placement.asset,
        imageSize: placement.imageSize,
        contentRect: placement.contentRect,
        x: scene.left + (placement.sourceAnchor.dx - 90) * placement.imageScale,
        y: placement.y,
        width: placement.width,
        anchor: placement.anchor,
      );
    }
    final bounds = placement.asset == bartender.asset
        ? const Rect.fromLTWH(16, 41, 363, 402)
        : const Rect.fromLTWH(60, 75, 480, 380);
    final anchor = placement.sourceAnchor;
    final scale = math.min(
      placement.imageScale,
      math.min(
        (placement.x - scene.left) / (anchor.dx - bounds.left),
        (scene.right - placement.x) / (bounds.right - anchor.dx),
      ),
    );
    return LobbyPlacement(
      asset: placement.asset,
      imageSize: placement.imageSize,
      contentRect: placement.contentRect,
      x: placement.x,
      y: placement.y,
      width: scale * placement.contentRect.width,
      anchor: placement.anchor,
    );
  }
}

class LobbyPlacement {
  const LobbyPlacement({
    required this.asset,
    required this.imageSize,
    required this.contentRect,
    required this.x,
    required this.y,
    required this.width,
    this.scale = 1,
    this.anchor = const Offset(0.5, 1),
  });

  final String asset;
  final Size imageSize;
  final Rect contentRect;

  /// Contact point in scene coordinates.
  final double x;
  final double y;

  /// Visible content width at scale 1, excluding transparent PNG padding.
  final double width;
  final double scale;

  /// Fraction of the content rectangle; ground objects use bottom center.
  final Offset anchor;

  double get imageScale => width * scale / contentRect.width;
  Offset get sourceAnchor => Offset(
    contentRect.left + contentRect.width * anchor.dx,
    contentRect.top + contentRect.height * anchor.dy,
  );
  Rect get imageRect => Rect.fromLTWH(
    x - sourceAnchor.dx * imageScale,
    y - sourceAnchor.dy * imageScale,
    imageSize.width * imageScale,
    imageSize.height * imageScale,
  );
  Rect get visualRect => Rect.fromLTWH(
    x - contentRect.width * anchor.dx * imageScale,
    y - contentRect.height * anchor.dy * imageScale,
    contentRect.width * imageScale,
    contentRect.height * imageScale,
  );
}
