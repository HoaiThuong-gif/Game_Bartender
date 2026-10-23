import 'package:flutter/material.dart';

import 'lobby_layout.dart';

/// Original panorama pixels are an authoring grid, independent of PNG resolution.
/// Depth orders complete furniture silhouettes, including holes between legs.
class RoomLayer {
  const RoomLayer(this.id, this.label, this.depth, this.placement);
  final String id, label;
  final int depth;
  final LobbyPlacement placement;
}

abstract final class LobbyFurnishings {
  static const layers = <RoomLayer>[
    RoomLayer(
      'seam_door',
      'Cửa giữa TV và tủ lạnh',
      9,
      LobbyPlacement(
        asset: 'assets/images/lobby/furniture/seam_door.png',
        // Measured outer frame in the original panorama, unwrapped at x=0.
        bounds: Rect.fromLTWH(-66, 303, 124, 281),
        corners: [
          Offset(-66, 303),
          Offset(58, 316),
          Offset(58, 571),
          Offset(-66, 584),
        ],
        contact: Offset(-4, 577),
        planar: true,
      ),
    ),
    RoomLayer(
      'kitchen',
      'Tủ bếp',
      10,
      LobbyPlacement(
        asset: 'assets/images/lobby/furniture/kitchen.png',
        bounds: Rect.fromLTWH(154, 280, 277, 294),
        corners: [],
        contact: Offset(292.5, 574),
      ),
    ),
    RoomLayer(
      'fridge',
      'Tủ lạnh',
      11,
      LobbyPlacement(
        asset: 'assets/images/lobby/furniture/fridge.png',
        bounds: Rect.fromLTWH(76, 351, 81, 219),
        corners: [],
        contact: Offset(116.5, 570),
      ),
    ),
    RoomLayer(
      'sofa',
      'Sofa',
      26,
      LobbyPlacement(
        asset: 'assets/images/lobby/furniture/sofa.png',
        bounds: Rect.fromLTWH(590, 462, 377, 187),
        corners: [],
        contact: Offset(778.5, 649),
      ),
    ),
    RoomLayer(
      'rug',
      'Thảm',
      0,
      LobbyPlacement(
        asset: 'assets/images/lobby/furniture/rug.png',
        bounds: Rect.fromLTWH(642, 566, 433, 179),
        corners: [],
        contact: Offset(858.5, 745),
      ),
    ),
    RoomLayer(
      'coffee_table',
      'Bàn trà',
      36,
      LobbyPlacement(
        asset: 'assets/images/lobby/furniture/coffee_table.png',
        // Chaise starts near x=800 in the sofa PNG; leave its cushion clear.
        bounds: Rect.fromLTWH(625, 583, 170, 119),
        corners: [],
        contact: Offset(710, 702),
      ),
    ),
    RoomLayer(
      'dining_table',
      'Bàn ăn',
      30,
      LobbyPlacement(
        asset: 'assets/images/lobby/furniture/dining_table.png',
        bounds: Rect.fromLTWH(180, 487, 265, 231),
        corners: [],
        contact: Offset(312.5, 718),
      ),
    ),
    RoomLayer(
      'chair_back_left',
      'Ghế ăn sau trái',
      20,
      LobbyPlacement(
        asset: 'assets/images/lobby/furniture/chair_back_left.png',
        bounds: Rect.fromLTWH(192, 480, 83, 178),
        corners: [],
        contact: Offset(233.5, 658),
      ),
    ),
    RoomLayer(
      'chair_back_right',
      'Ghế ăn sau phải',
      21,
      LobbyPlacement(
        asset: 'assets/images/lobby/furniture/chair_back_right.png',
        bounds: Rect.fromLTWH(288, 476, 83, 165),
        corners: [],
        contact: Offset(329.5, 641),
      ),
    ),
    RoomLayer(
      'chair_front',
      'Ghế ăn phía trước',
      35,
      LobbyPlacement(
        asset: 'assets/images/lobby/furniture/chair_front.png',
        bounds: Rect.fromLTWH(334, 512, 153, 218),
        corners: [],
        contact: Offset(410.5, 730),
      ),
    ),
    RoomLayer(
      'chair_side',
      'Ghế ăn bên phải',
      22,
      LobbyPlacement(
        asset: 'assets/images/lobby/furniture/chair_side.png',
        bounds: Rect.fromLTWH(422, 491, 83, 183),
        corners: [],
        contact: Offset(463.5, 674),
      ),
    ),
    RoomLayer(
      'window_bench',
      'Bục cửa sổ',
      25,
      LobbyPlacement(
        asset: 'assets/images/lobby/furniture/window_bench.png',
        // The right foot of this oblique PNG is 44px above its bounding bottom.
        // Lower it until that foot rests below the wall/floor boundary (y~556).
        bounds: Rect.fromLTWH(1175, 492, 220, 131),
        corners: [],
        contact: Offset(1285, 623),
      ),
    ),
    RoomLayer(
      'curtain_left',
      'Rèm trái',
      12,
      LobbyPlacement(
        asset: 'assets/images/lobby/furniture/curtain_left.png',
        bounds: Rect.fromLTWH(826, 275, 98, 282),
        corners: [],
        contact: Offset(875, 557),
      ),
    ),
    RoomLayer(
      'curtain_right',
      'Rèm phải',
      13,
      LobbyPlacement(
        asset: 'assets/images/lobby/furniture/curtain_right.png',
        bounds: Rect.fromLTWH(1258, 301, 77, 217),
        corners: [],
        contact: Offset(1296.5, 518),
      ),
    ),
    RoomLayer(
      'shelf',
      'Kệ gỗ',
      14,
      LobbyPlacement(
        asset: 'assets/images/lobby/furniture/shelf.png',
        bounds: Rect.fromLTWH(1324, 258, 102, 324),
        corners: [],
        contact: Offset(1384, 582),
      ),
    ),
    RoomLayer(
      'console',
      'Kệ TV',
      27,
      LobbyPlacement(
        asset: 'assets/images/lobby/furniture/console.png',
        planar: true,
        bounds: Rect.fromLTWH(1388, 500, 284, 133),
        corners: [],
        contact: Offset(1530, 633),
      ),
    ),
    RoomLayer(
      'plant',
      'Chậu cây',
      40,
      LobbyPlacement(
        asset: 'assets/images/lobby/furniture/plant.png',
        bounds: Rect.fromLTWH(1404, 452, 47, 63),
        corners: [],
        contact: Offset(1427.5, 515),
      ),
    ),
    RoomLayer(
      'camera',
      'Máy ảnh',
      41,
      LobbyPlacement(
        asset: 'assets/images/lobby/furniture/camera.png',
        bounds: Rect.fromLTWH(1603, 516, 48, 36),
        corners: [],
        contact: Offset(1627, 552),
      ),
    ),
  ];
}
