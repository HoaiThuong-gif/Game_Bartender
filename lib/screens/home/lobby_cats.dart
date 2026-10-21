import 'dart:math';

import 'package:flutter/material.dart';

import 'lobby_layout.dart';

enum CatType { black, orange, tuxedo }

extension CatAssetName on CatType {
  String get assetName => switch (this) {
    CatType.black => 'Nam',
    CatType.orange => 'Cam',
    CatType.tuxedo => 'Cho',
  };
}

enum CatPose { sitting, sleeping, standing, resting }

enum CatDepth { behindGames, afterBartender, foreground }

enum LobbyGame { bartender, rubik, arcade, television }

/// A single shared clock animates one courtyard object at a time.
class LobbyAtmosphere extends ChangeNotifier {
  LobbyAtmosphere(this.animation);
  final Animation<double> animation;
  late final Listenable repaint = Listenable.merge([this, animation]);
  LobbyGame? game;
  CatType? reactingCat;
  bool entering = false;
  int event = 0;
  int televisionScene = 0;
  int previousTelevisionScene = 0;

  void show(LobbyGame next, {CatType? cat, bool entry = false}) {
    if (next == LobbyGame.television && !entry) {
      previousTelevisionScene = televisionScene;
      televisionScene = (televisionScene + 1) % 2;
    }
    game = next;
    reactingCat = cat;
    entering = entry;
    event++;
    notifyListeners();
  }

  void clear() {
    game = null;
    reactingCat = null;
    entering = false;
    notifyListeners();
  }

  void react(CatType cat) {
    reactingCat = cat;
    event++;
    notifyListeners();
  }
}

class LobbyEnvironment extends InheritedWidget {
  const LobbyEnvironment({
    super.key,
    required this.atmosphere,
    required this.prepareEntry,
    required this.finishEntry,
    required super.child,
  });
  final LobbyAtmosphere atmosphere;
  final Future<bool> Function(LobbyGame) prepareEntry;
  final VoidCallback finishEntry;
  static LobbyEnvironment? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LobbyEnvironment>();
  @override
  bool updateShouldNotify(LobbyEnvironment oldWidget) =>
      atmosphere != oldWidget.atmosphere;
}

abstract final class LobbyCats {
  static const minInterval = Duration(seconds: 12);
  static const maxInterval = Duration(seconds: 25);
  static const fadeDuration = Duration(milliseconds: 450);
  static const emptyDuration = Duration(milliseconds: 900);
  static const groundAnchor = 0.9;
  static const relaxed = [CatPose.sitting, CatPose.sleeping, CatPose.resting];
  static const seated = [CatPose.sitting, CatPose.resting];
  static const lying = [CatPose.sleeping, CatPose.resting];
  static const spawns = [
    CatSpawn(
      'arcadeArea',
      x: 730,
      y: 1195,
      targetSize: Size(215, 220),
      onGround: true,
      // On the courtyard in front of the cabinet, not behind its lower panel.
      depth: CatDepth.afterBartender,
    ),
    CatSpawn(
      'centerGround',
      x: 485,
      y: 1585,
      targetSize: Size(285, 295),
      onGround: true,
    ),
    CatSpawn(
      'nearRubikTable',
      x: 370,
      y: 1645,
      targetSize: Size(300, 300),
      onGround: true,
      depth: CatDepth.foreground,
    ),
    CatSpawn(
      'bartenderArea',
      x: 260,
      y: 1600,
      targetSize: Size(285, 290),
      onGround: true,
      depth: CatDepth.foreground,
    ),
    CatSpawn(
      'roofTop',
      x: 445,
      y: 364,
      targetSize: Size(175, 170),
      poseSizes: {
        CatPose.sleeping: Size(175, 152),
        CatPose.resting: Size(175, 157),
      },
      allowedPoses: relaxed,
      depth: CatDepth.behindGames,
    ),
    CatSpawn(
      'doorStep',
      // Keep the entire body to the left of the arcade cabinet.
      x: 495,
      y: 900,
      targetSize: Size(156, 166),
      allowedPoses: seated,
      depth: CatDepth.behindGames,
    ),
    CatSpawn(
      'chairLeft',
      x: LobbyLayout.bartenderLeftSeatX,
      y: LobbyLayout.bartenderLeftSeatY,
      targetSize: Size(190, 195),
      allowedPoses: seated,
    ),
    CatSpawn(
      'chairRight',
      x: LobbyLayout.bartenderRightSeatX,
      y: LobbyLayout.bartenderRightSeatY,
      targetSize: Size(185, 190),
      allowedPoses: seated,
    ),
    CatSpawn(
      'foregroundBlueStool',
      x: 610,
      y: 1408,
      targetSize: Size(232, 238),
      poseSizes: {CatPose.resting: Size(205, 211)},
      allowedPoses: seated,
      depth: CatDepth.afterBartender,
    ),
    CatSpawn(
      'foregroundRedStool',
      // Centre the body's supporting paws on the visible red seat.
      x: 780,
      y: 1490,
      targetSize: Size(210, 215),
      poseSizes: {
        CatPose.sitting: Size(210, 215),
        CatPose.standing: Size(220, 210),
        CatPose.sleeping: Size(210, 176),
        CatPose.resting: Size(210, 205),
      },
      allowedPoses: seated,
      depth: CatDepth.foreground,
    ),
    CatSpawn(
      'rubikTable',
      // Centre the larger silhouette over the tabletop, keeping contact height.
      x: 680,
      y: 1315,
      targetSize: Size(210, 185),
      poseSizes: {CatPose.resting: Size(210, 200)},
      allowedPoses: lying,
    ),
  ];
}

class CatSpawn {
  const CatSpawn(
    this.name, {
    required this.x,
    required this.y,
    required this.targetSize,
    this.poseSizes = const {},
    this.anchor = const Offset(0.5, LobbyCats.groundAnchor),
    this.allowedPoses = CatPose.values,
    this.depth = CatDepth.afterBartender,
    this.onGround = false,
  });
  final String name;
  final double x;
  final double y;

  /// Maximum visible width/height in scene units, excluding transparent pixels.
  final Size targetSize;
  final Map<CatPose, Size> poseSizes;
  Size sizeFor(CatPose pose) => poseSizes[pose] ?? targetSize;
  final Offset anchor;
  final List<CatPose> allowedPoses;
  final CatDepth depth;
  final bool onGround;
  Offset viewportShift(Size viewport) {
    if (name == 'chairLeft' || name == 'chairRight') {
      final bar = LobbyLayout.fitObject(LobbyLayout.bartender, viewport);
      final source = name == 'chairLeft'
          ? LobbyLayout.bartenderLeftSeat
          : LobbyLayout.bartenderRightSeat;
      return bar.imageRect.topLeft + source * bar.imageScale - Offset(x, y);
    }
    if (!onGround ||
        viewport.isEmpty ||
        !viewport.width.isFinite ||
        !viewport.height.isFinite) {
      return Offset.zero;
    }
    final scene = LobbyLayout.designSize;
    final cover = max(
      viewport.width / scene.width,
      viewport.height / scene.height,
    );
    final bottom = (scene.height + viewport.height / cover) / 2;
    return Offset(0, min(0, bottom - 4 / cover - y));
  }

  CatDepth depthFor(CatType type) => depth;
  double get renderedSize =>
      max(targetSize.width / .82, targetSize.height / .8);
  Rect get rect => Rect.fromLTWH(
    x - renderedSize * anchor.dx,
    y - renderedSize * anchor.dy,
    renderedSize,
    renderedSize,
  );
  Rect rectFor(CatType type) => rect;

  Rect get visualRect => Rect.fromLTWH(
    x - targetSize.width / 2,
    y - targetSize.height,
    targetSize.width,
    targetSize.height,
  );
}

class LobbyCat {
  const LobbyCat(this.type, this.pose);
  final CatType type;
  final CatPose pose;
  String get asset {
    final suffix = switch (pose) {
      CatPose.sitting => 'ngoi',
      CatPose.standing => 'dung',
      CatPose.sleeping => 'nam',
      CatPose.resting => 'vo',
    };
    return 'assets/images/character/${type.assetName}/${type.assetName}_$suffix.png';
  }

  String get identity => type.name;
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
      final free = availableSpawns()
          .where(
            (slot) =>
                type != CatType.black ||
                LobbyCats.spawns[slot].allowedPoses.contains(CatPose.sitting),
          )
          .toList();
      final slot = free[random.nextInt(free.length)];
      final cat = characters[type]!;
      cat.spawnIndex = slot;
      cat.pose =
          type == CatType.black &&
              LobbyCats.spawns[slot].allowedPoses.contains(CatPose.sitting)
          ? CatPose.sitting
          : randomPose(slot);
    }
  }
  final Random random;
  final characters = {
    for (final type in CatType.values) type: CatCharacter(type),
  };
  CatChange? pending;
  CatPose? _queuedNamPose;
  final busyCats = <CatType>{};
  bool get namBusy => busyCats.contains(CatType.black);
  set namBusy(bool value) => setBusy(CatType.black, value);
  void setBusy(CatType type, bool value) {
    if (value) {
      busyCats.add(type);
    } else {
      busyCats.remove(type);
    }
  }

  void setPose(CatType type, CatPose pose) {
    characters[type]!.pose = pose;
    notifyListeners();
  }

  /// Debug pose override reuses the population and never moves another cat.
  void previewNam(CatPose pose) {
    if (pending != null) {
      _queuedNamPose = pose;
      return;
    }
    final cat = characters[CatType.black]!;
    if (cat.spawnIndex == null) {
      final slots = availableSpawns(excluding: CatType.black).toList();
      if (slots.isEmpty) return;
      // Prefer the nearby ground for the debug experiment, retaining all
      // occupancy checks and leaving Orange/Tuxedo untouched.
      slots.sort(
        (a, b) =>
            (a >= 1 && a <= 3 ? 0 : 1).compareTo(b >= 1 && b <= 3 ? 0 : 1),
      );
      cat.spawnIndex = slots.first;
    }
    cat.pose = pose;
    notifyListeners();
  }

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
    if (busyCats.contains(cat.type)) return null;
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
    final preview = _queuedNamPose;
    _queuedNamPose = null;
    if (preview != null) {
      previewNam(preview);
    } else {
      notifyListeners();
    }
  }
}
