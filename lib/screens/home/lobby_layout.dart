import 'package:flutter/material.dart';

/// Measured from the CURRENT PNGs (alpha > 40). All positions refer to the
/// background canvas; transparent margins are excluded from anchor geometry.
abstract final class LobbyLayout {
  static const designSize = Size(941, 1672);
  static const backgroundAsset = 'assets/images/lobby/background.png';

  // Foreground stall: front feet sit on the courtyard paving.
  static const bartender = LobbyPlacement(
    asset: 'assets/images/lobby/bartender.png',
    imageSize: Size(1448, 1086),
    contentRect: Rect.fromLTWH(62, 24, 1365, 1047),
    x: 200,
    y: 1218,
    width: 740,
  );
  // Smaller, deeper in the scene, immediately in front of the right wall.
  static const arcade = LobbyPlacement(
    asset: 'assets/images/lobby/games.png',
    imageSize: Size(1303, 1207),
    contentRect: Rect.fromLTWH(94, 14, 1182, 1183),
    x: 720,
    y: 1000,
    width: 240,
  );
  // The bottom of the cube meets the tabletop, inside its visible perimeter.
  static const rubik = LobbyPlacement(
    asset: 'assets/images/lobby/rubik.png',
    imageSize: Size(1312, 1199),
    contentRect: Rect.fromLTWH(139, 68, 1034, 1099),
    x: 790,
    y: 1302,
    width: 86,
  );
  // Wall attachment, measured at source pixel (104, 900), not the flag's tip.
  static const flag = LobbyPlacement(
    asset: 'assets/images/lobby/flag.png',
    imageSize: Size(1448, 1086),
    contentRect: Rect.fromLTWH(58, 37, 1374, 1019),
    x: 655,
    y: 455,
    width: 250,
    anchor: Offset((104 - 58) / 1374, (900 - 37) / 1019),
  );
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
  Alignment get imageAnchorAlignment => Alignment(
    sourceAnchor.dx / imageSize.width * 2 - 1,
    sourceAnchor.dy / imageSize.height * 2 - 1,
  );
}
