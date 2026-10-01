import 'dart:math';

import 'package:flutter/material.dart';

enum CatType { black, orange, tuxedo }

enum CatPose { sitting, sleeping, standing, resting }

enum CatDepth { behindGames, afterBartender, foreground }

abstract final class LobbyCats {
  static const minInterval = Duration(seconds: 12);
  static const maxInterval = Duration(seconds: 25);
  static const fadeDuration = Duration(milliseconds: 450);
  static const emptyDuration = Duration(milliseconds: 900);
  static const groundAnchor = 0.9;
  // Nearby cats set the baseline; distant surfaces use smaller scales below.
  static const characterScale = 2.8;
  static const relaxed = [CatPose.sitting, CatPose.sleeping, CatPose.resting];
  static const seated = [CatPose.sitting, CatPose.resting];
  static const lying = [CatPose.sleeping, CatPose.resting];
  static const spawns = [
    CatSpawn(
      'arcadeArea',
      x: 710,
      y: 1270,
      size: 108,
      scale: 2.3,
      depth: CatDepth.behindGames,
    ),
    CatSpawn('centerGround', x: 485, y: 1585, size: 145),
    CatSpawn(
      'nearRubikTable',
      x: 370,
      y: 1645,
      size: 168,
      depth: CatDepth.foreground,
    ),
    CatSpawn(
      'bartenderArea',
      x: 260,
      y: 1600,
      size: 150,
      depth: CatDepth.foreground,
    ),
    CatSpawn(
      'roofTop',
      x: 445,
      y: 364,
      size: 80,
      scale: 1.6,
      allowedPoses: relaxed,
      depth: CatDepth.behindGames,
    ),
    CatSpawn(
      'doorStep',
      x: 566,
      y: 900,
      size: 70,
      scale: 1.8,
      allowedPoses: seated,
      depth: CatDepth.behindGames,
    ),
    CatSpawn(
      'chairLeft',
      x: 274,
      y: 1094,
      size: 100,
      scale: 1.9,
      allowedPoses: seated,
    ),
    CatSpawn(
      'chairRight',
      x: 420,
      y: 1083,
      size: 96,
      scale: 1.9,
      allowedPoses: seated,
    ),
    CatSpawn(
      'foregroundBlueStool',
      x: 618,
      y: 1408,
      size: 150,
      allowedPoses: seated,
      depth: CatDepth.afterBartender,
    ),
    CatSpawn(
      'foregroundRedStool',
      x: 795,
      y: 1482,
      size: 156,
      allowedPoses: seated,
      // The larger cat sits behind the cube on the table.
      depth: CatDepth.afterBartender,
    ),
    CatSpawn(
      'rubikTable',
      x: 660,
      y: 1315,
      size: 80,
      scale: 2.45,
      allowedPoses: lying,
    ),
  ];
}

class CatSpawn {
  const CatSpawn(
    this.name, {
    required this.x,
    required this.y,
    required this.size,
    this.scale = LobbyCats.characterScale,
    this.anchor = const Offset(0.5, LobbyCats.groundAnchor),
    this.allowedPoses = CatPose.values,
    this.depth = CatDepth.afterBartender,
  });
  final String name;
  final double x;
  final double y;
  final double size;
  final double scale;
  final Offset anchor;
  final List<CatPose> allowedPoses;
  final CatDepth depth;
  double get renderedSize => size * scale;
  Rect get rect => Rect.fromLTWH(
    x - renderedSize * anchor.dx,
    y - renderedSize * anchor.dy,
    renderedSize,
    renderedSize,
  );
  Rect get visualRect => Rect.fromLTWH(
    x - renderedSize * 0.41,
    y - renderedSize * 0.8,
    renderedSize * 0.82,
    renderedSize * 0.8,
  );
}

class LobbyCat {
  const LobbyCat(this.type, this.pose);
  final CatType type;
  final CatPose pose;
  String get asset => 'assets/images/character/lobby/${type.name}-poses.png';
  String get identity => type.name;
  int get quarterTurns => pose == CatPose.sleeping ? 1 : 0;
  static const atlasSize = 1254.0;
  Rect get sourceRect => switch (type) {
    CatType.black => const [
      Rect.fromLTWH(115, 31, 501, 596),
      Rect.fromLTWH(685, 135, 498, 492),
      Rect.fromLTWH(12, 627, 642, 571),
      Rect.fromLTWH(689, 650, 530, 540),
    ][pose.index],
    CatType.orange => const [
      Rect.fromLTWH(134, 30, 441, 583),
      Rect.fromLTWH(719, 144, 460, 465),
      Rect.fromLTWH(22, 644, 606, 559),
      Rect.fromLTWH(685, 701, 542, 493),
    ][pose.index],
    CatType.tuxedo => const [
      Rect.fromLTWH(151, 59, 444, 543),
      Rect.fromLTWH(671, 94, 506, 505),
      Rect.fromLTWH(33, 634, 610, 552),
      Rect.fromLTWH(686, 725, 530, 437),
    ][pose.index],
  };
}

/// This object belongs permanently to one character, even when offscreen.
class CatCharacter {
  CatCharacter(this.type);
  final CatType type;
  CatPose pose = CatPose.sitting;
  int? spawnIndex;
  LobbyCat get sprite => LobbyCat(type, pose);
}

class CatChange {
  const CatChange({this.outgoing, this.incoming, this.spawnIndex, this.pose});
  final CatType? outgoing;
  final CatType? incoming;
  final int? spawnIndex;
  final CatPose? pose;
  bool involves(CatType type) => outgoing == type || incoming == type;
}

class CatPopulation extends ChangeNotifier {
  CatPopulation(this.random) {
    final types = CatType.values.toList()..shuffle(random);
    final count = 1 + random.nextInt(3);
    for (final type in types.take(count)) {
      final free = availableSpawns();
      final slot = free[random.nextInt(free.length)];
      final cat = characters[type]!;
      cat.spawnIndex = slot;
      cat.pose = randomPose(slot);
    }
  }
  final Random random;
  final characters = {
    for (final type in CatType.values) type: CatCharacter(type),
  };
  CatChange? pending;
  Iterable<CatCharacter> get visible =>
      characters.values.where((cat) => cat.spawnIndex != null);

  List<int> availableSpawns({CatType? excluding}) {
    final occupied = visible
        .where((cat) => cat.type != excluding)
        .map((cat) => cat.spawnIndex!)
        .toList();
    return [
      for (var i = 0; i < LobbyCats.spawns.length; i++)
        if (!occupied.any(
          (slot) =>
              slot == i ||
              LobbyCats.spawns[i].visualRect.overlaps(
                LobbyCats.spawns[slot].visualRect,
              ),
        ))
          i,
    ];
  }

  CatPose randomPose(int slot, {CatPose? excluding}) {
    final choices = LobbyCats.spawns[slot].allowedPoses
        .where((pose) => pose != excluding)
        .toList();
    return choices[random.nextInt(choices.length)];
  }

  Duration nextInterval() => Duration(
    milliseconds:
        LobbyCats.minInterval.inMilliseconds +
        random.nextInt(
          LobbyCats.maxInterval.inMilliseconds -
              LobbyCats.minInterval.inMilliseconds +
              1,
        ),
  );

  CatChange? planChange() {
    final present = visible.toList();
    final absent = characters.values
        .where((cat) => cat.spawnIndex == null)
        .toList();
    final free = availableSpawns();
    final action = random.nextInt(6);
    if (action == 5) return null;
    if (action == 1 && absent.isNotEmpty && free.isNotEmpty) {
      final cat = absent[random.nextInt(absent.length)];
      final slot = free[random.nextInt(free.length)];
      return CatChange(
        incoming: cat.type,
        spawnIndex: slot,
        pose: randomPose(slot),
      );
    }
    final cat = present[random.nextInt(present.length)];
    if (action == 2 && present.length > 1) return CatChange(outgoing: cat.type);
    if (action == 3 && absent.isNotEmpty) {
      return CatChange(
        outgoing: cat.type,
        incoming: absent[random.nextInt(absent.length)].type,
        spawnIndex: cat.spawnIndex,
        pose: randomPose(cat.spawnIndex!),
      );
    }
    if (action == 4) {
      final destinations = availableSpawns(excluding: cat.type)
          .where((slot) => slot != cat.spawnIndex)
          .toList();
      if (destinations.isNotEmpty) {
        final slot = destinations[random.nextInt(destinations.length)];
        return CatChange(
          outgoing: cat.type,
          incoming: cat.type,
          spawnIndex: slot,
          pose: randomPose(slot),
        );
      }
    }
    return CatChange(
      outgoing: cat.type,
      incoming: cat.type,
      spawnIndex: cat.spawnIndex,
      pose: randomPose(cat.spawnIndex!, excluding: cat.pose),
    );
  }

  void begin(CatChange change) {
    assert(pending == null);
    pending = change;
    notifyListeners();
  }

  /// Called only after opacity reaches zero AND the empty interval finishes.
  void commit() {
    final change = pending!;
    if (change.outgoing case final type?) characters[type]!.spawnIndex = null;
    if (change.incoming case final type?) {
      final cat = characters[type]!;
      cat.spawnIndex = change.spawnIndex;
      cat.pose = change.pose!;
    }
    notifyListeners();
  }

  void finish() {
    pending = null;
    notifyListeners();
  }
}
