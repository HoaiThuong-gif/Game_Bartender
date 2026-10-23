import 'dart:math';

import 'package:flutter/material.dart';

import 'lobby_furnishings.dart';

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
  static const minInterval = Duration(seconds: 35);
  static const maxInterval = Duration(seconds: 80);
  static const fadeDuration = Duration(milliseconds: 1200);
  static const sizeScale = 1.25;
  static const raisedSizeScale = 1.25;
  static const groundAnchor = 0.9;
  static const relaxed = [CatPose.sitting, CatPose.sleeping, CatPose.resting];
  static const seated = [CatPose.sitting, CatPose.resting];
  static const lying = [CatPose.sleeping, CatPose.resting];
  static const spawns = [
    CatSpawn(
      'tvSideFloor',
      x: 1460,
      y: 657,
      targetSize: Size(215, 220),
      onGround: true,
      // Clear floor to the left of the TV console.
      depth: CatDepth.afterBartender,
      region: [
        Offset(1430, 665),
        Offset(1655, 675),
        Offset(1700, 790),
        Offset(1380, 785),
      ],
      layerDepth: 50,
    ),
    CatSpawn(
      'rugFloor',
      x: 1050,
      y: 713,
      targetSize: Size(285, 295),
      onGround: true,
      region: [
        Offset(840, 675),
        Offset(1030, 665),
        Offset(1060, 762),
        Offset(820, 770),
      ],
      layerDepth: 50,
    ),
    CatSpawn(
      'nearSofaFloor',
      x: 640,
      y: 748,
      targetSize: Size(300, 300),
      onGround: true,
      depth: CatDepth.foreground,
      region: [
        Offset(600, 735),
        Offset(770, 740),
        Offset(800, 825),
        Offset(575, 820),
      ],
    ),
    CatSpawn(
      'diningFloor',
      x: 190,
      y: 730,
      targetSize: Size(285, 290),
      onGround: true,
      depth: CatDepth.foreground,
      region: [
        Offset(225, 754),
        Offset(439, 756),
        Offset(460, 821),
        Offset(205, 821),
      ],
    ),
    CatSpawn(
      'sofaSeat',
      x: 709,
      y: 556,
      targetSize: Size(175, 170),
      poseSizes: {
        CatPose.sleeping: Size(175, 152),
        CatPose.resting: Size(175, 157),
      },
      allowedPoses: relaxed,
      depth: CatDepth.behindGames,
      region: [
        Offset(673, 548),
        Offset(755, 546),
        Offset(779, 565),
        Offset(668, 574),
      ],
      layerDepth: 27,
    ),
    CatSpawn(
      'windowCushion',
      x: 1258,
      y: 543,
      targetSize: Size(156, 166),
      allowedPoses: seated,
      depth: CatDepth.behindGames,
      region: [
        Offset(1204, 545),
        Offset(1308, 530),
        Offset(1318, 538),
        Offset(1212, 553),
      ],
      layerDepth: 26,
    ),
    CatSpawn(
      'diningLeftSeat',
      x: 250,
      y: 573,
      targetSize: Size(190, 195),
      allowedPoses: seated,
      region: [
        Offset(242, 569),
        Offset(262, 572),
        Offset(260, 578),
        Offset(241, 575),
      ],
      layerDepth: 29,
    ),
    CatSpawn(
      'diningRightSeat',
      x: 374,
      y: 610,
      targetSize: Size(185, 190),
      allowedPoses: seated,
      region: [
        Offset(360, 604),
        Offset(383, 607),
        Offset(389, 614),
        Offset(363, 617),
      ],
      layerDepth: 36,
    ),
    CatSpawn(
      'sofaChaise',
      x: 902,
      y: 574,
      targetSize: Size(232, 238),
      poseSizes: {CatPose.resting: Size(205, 211)},
      allowedPoses: relaxed,
      depth: CatDepth.afterBartender,
      region: [
        Offset(836, 558),
        Offset(906, 558),
        Offset(926, 576),
        Offset(849, 591),
      ],
      layerDepth: 27,
    ),
    CatSpawn(
      'windowWoodStep',
      x: 1334,
      y: 581,
      targetSize: Size(210, 215),
      poseSizes: {
        CatPose.sitting: Size(210, 215),
        CatPose.standing: Size(220, 210),
        CatPose.sleeping: Size(210, 176),
        CatPose.resting: Size(210, 205),
      },
      allowedPoses: seated,
      depth: CatDepth.foreground,
      region: [
        Offset(1244, 588),
        Offset(1368, 564),
        Offset(1380, 570),
        Offset(1254, 596),
      ],
      layerDepth: 26,
    ),
    CatSpawn(
      'sofaCorner',
      x: 804,
      y: 548,
      targetSize: Size(210, 185),
      poseSizes: {CatPose.resting: Size(210, 200)},
      allowedPoses: lying,
      region: [
        Offset(783, 541),
        Offset(813, 539),
        Offset(831, 549),
        Offset(798, 557),
      ],
      layerDepth: 27,
    ),
    // Contacts measured on the current furniture PNGs and the clear floor.
    CatSpawn(
      'hallFloor',
      x: 521,
      y: 640,
      targetSize: Size(240, 245),
      onGround: true,
      region: [
        Offset(505, 542),
        Offset(537, 542),
        Offset(551, 637),
        Offset(607, 751),
        Offset(477, 751),
        Offset(491, 634),
      ],
      layerDepth: 23,
    ),
    CatSpawn(
      'windowFloor',
      x: 1240,
      y: 738,
      targetSize: Size(280, 290),
      onGround: true,
      region: [
        Offset(1140, 673),
        Offset(1377, 669),
        Offset(1410, 790),
        Offset(1095, 790),
      ],
      layerDepth: 50,
    ),
    CatSpawn(
      'sofaBack',
      x: 721,
      y: 478,
      targetSize: Size(165, 170),
      allowedPoses: [CatPose.sitting],
      region: [
        Offset(653, 475),
        Offset(783, 474),
        Offset(789, 480),
        Offset(655, 482),
      ],
      layerDepth: 27,
    ),
    CatSpawn(
      'sofaLeftArm',
      x: 619,
      y: 531,
      targetSize: Size(155, 160),
      allowedPoses: [CatPose.sitting],
      region: [
        Offset(610, 521),
        Offset(626, 528),
        Offset(632, 540),
        Offset(615, 536),
      ],
      layerDepth: 27,
    ),
    CatSpawn(
      'sofaRightArm',
      x: 916,
      y: 515,
      targetSize: Size(155, 160),
      allowedPoses: [CatPose.sitting],
      region: [
        Offset(904, 509),
        Offset(923, 510),
        Offset(924, 520),
        Offset(908, 518),
      ],
      layerDepth: 27,
    ),
    CatSpawn(
      'kitchenCounter',
      x: 362,
      y: 467,
      targetSize: Size(165, 170),
      allowedPoses: relaxed,
      region: [
        Offset(316, 463),
        Offset(402, 469),
        Offset(413, 474),
        Offset(319, 469),
      ],
      layerDepth: 19,
    ),
    CatSpawn(
      'diningTableLeft',
      x: 253,
      y: 538,
      targetSize: Size(170, 175),
      allowedPoses: relaxed,
      region: [
        Offset(235, 532),
        Offset(260, 521),
        Offset(274, 532),
        Offset(251, 544),
      ],
      layerDepth: 34,
    ),
    CatSpawn(
      'diningTableRight',
      x: 407,
      y: 527,
      targetSize: Size(155, 160),
      allowedPoses: seated,
      region: [
        Offset(402, 520),
        Offset(421, 513),
        Offset(424, 523),
        Offset(402, 534),
      ],
      layerDepth: 34,
    ),
    CatSpawn(
      'consoleTop',
      x: 1532,
      y: 535,
      targetSize: Size(165, 170),
      allowedPoses: relaxed,
      region: [
        Offset(1475, 523),
        Offset(1577, 534),
        Offset(1580, 545),
        Offset(1473, 534),
      ],
      layerDepth: 28,
    ),
    CatSpawn(
      'coffeeTableLeft',
      x: 661,
      y: 615,
      targetSize: Size(145, 150),
      allowedPoses: [CatPose.sitting],
      region: [
        Offset(650, 609),
        Offset(670, 604),
        Offset(679, 613),
        Offset(658, 622),
      ],
      layerDepth: 37,
    ),
    CatSpawn(
      'coffeeTableRight',
      x: 763,
      y: 616,
      targetSize: Size(145, 150),
      allowedPoses: [CatPose.sitting],
      region: [
        Offset(754, 608),
        Offset(773, 611),
        Offset(777, 619),
        Offset(756, 622),
      ],
      layerDepth: 37,
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
    this.region = const [],
    this.layerDepth,
  });
  final String name;
  final double x;
  final double y;

  /// Maximum visible width/height in scene units, excluding transparent pixels.
  final Size targetSize;
  final Map<CatPose, Size> poseSizes;
  double get displayScale =>
      LobbyCats.sizeScale *
      ((surfaceGroup == 'sofa' ||
              name.startsWith('coffeeTable') ||
              name.startsWith('diningTable'))
          ? LobbyCats.raisedSizeScale
          : 1);
  Size sizeFor(CatPose pose) => (poseSizes[pose] ?? targetSize) * displayScale;
  final List<Offset> region;
  final int? layerDepth;
  int get paintDepth =>
      layerDepth ??
      switch (depth) {
        CatDepth.behindGames => 27,
        CatDepth.afterBartender => 37,
        CatDepth.foreground => 50,
      };
  CatSpawn at(Offset point) => CatSpawn(
    name,
    x: point.dx,
    y: point.dy,
    targetSize: targetSize,
    poseSizes: poseSizes,
    anchor: anchor,
    allowedPoses: allowedPoses,
    depth: depth,
    onGround: onGround,
    region: region,
    layerDepth: layerDepth,
  );

  Offset sample(Random random) {
    if (region.length < 3) return Offset(x, y);
    final path = Path()..addPolygon(region, true);
    final box = path.getBounds();
    for (var i = 0; i < 80; i++) {
      final p = Offset(
        box.left + random.nextDouble() * box.width,
        box.top + random.nextDouble() * box.height,
      );
      if (path.contains(p)) return p;
    }
    return Offset(x, y);
  }

  final Offset anchor;
  final List<CatPose> allowedPoses;
  final CatDepth depth;
  final bool onGround;
  String get surfaceGroup {
    if (name.startsWith('sofa')) return 'sofa';
    if (name.startsWith('coffeeTable')) return 'coffeeTable';
    if (!onGround && name.startsWith('dining')) return 'dining';
    if (name == 'windowCushion' || name == 'windowWoodStep') {
      return 'windowBench';
    }
    return name;
  }

  // Panorama contacts never move to fit the viewport.
  Offset viewportShift(Size viewport) => Offset.zero;

  CatDepth depthFor(CatType type) => depth;
  double get renderedSize =>
      max(targetSize.width / .82, targetSize.height / .8) * displayScale;
  Rect get rect => Rect.fromLTWH(
    x - renderedSize * anchor.dx,
    y - renderedSize * anchor.dy,
    renderedSize,
    renderedSize,
  );
  Rect rectFor(CatType type) => rect;

  Rect get visualRect {
    // Actor sizes use 1672 authoring units, not panorama pixels. Match the
    // tangent-plane projection when checking separation between characters.
    final latitude = (.5 - y / 887) * pi;
    final unit = 1774 / (2 * pi) * 2 * tan(75 * pi / 360) / 1672;
    final w =
        targetSize.width *
        displayScale *
        unit /
        cos(latitude).abs().clamp(.3, 1.0);
    final h = targetSize.height * displayScale * unit;
    // Resting sprites are anchored at the front paws, not the centre of the
    // complete silhouette. Reserve the rear paws and tail as well.
    return Rect.fromLTWH(x - w * .65, y - h, w * 1.5, h + 4);
  }

  bool supports(CatPose pose) {
    if (!allowedPoses.contains(pose)) return false;
    if (!onGround) return true;
    // Read the same furniture placements used for drawing. A floor cat may
    // cover a chair only when its paws are below that chair's floor contact.
    // This also reserves the opaque upper chair area, not just a centre point.
    final clearance = visualRect.inflate(8);
    for (final layer in LobbyFurnishings.layers) {
      if (!layer.id.startsWith('chair_') && layer.id != 'dining_table') {
        continue;
      }
      final furniture = layer.placement.bounds;
      final floor = max(layer.placement.contact.dy, furniture.bottom);
      if (clearance.overlaps(furniture) && y < floor + 10) return false;
    }
    return true;
  }
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
  CatSpawn? positioned;
  late DateTime nextChangeAt;
  CatSpawn get placement => positioned ?? LobbyCats.spawns[spawnIndex!];
  LobbyCat get sprite => LobbyCat(type, pose);
}

class CatChange {
  const CatChange({
    this.outgoing,
    this.incoming,
    this.spawnIndex,
    this.pose,
    this.placement,
  });
  final CatType? outgoing;
  final CatType? incoming;
  final int? spawnIndex;
  final CatPose? pose;
  final CatSpawn? placement;
  bool involves(CatType type) => outgoing == type || incoming == type;
}

class CatPopulation extends ChangeNotifier {
  CatPopulation(this.random) {
    const seats = {CatType.black: 4, CatType.orange: 7, CatType.tuxedo: 5};
    for (final type in CatType.values) {
      final cat = characters[type]!;
      cat.spawnIndex = seats[type];
      cat.pose = CatPose.sitting;
      cat.nextChangeAt = DateTime.now().add(
        Duration(seconds: 25 + random.nextInt(26)),
      );
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
    return choices.isEmpty
        ? excluding!
        : choices[random.nextInt(choices.length)];
  }

  Duration nextInterval() {
    final free = visible.where((cat) => !busyCats.contains(cat.type)).toList();
    if (free.isEmpty) return const Duration(seconds: 1);
    final due = free
        .map((cat) => cat.nextChangeAt)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    return Duration(
      milliseconds: max(750, due.difference(DateTime.now()).inMilliseconds),
    );
  }

  CatChange? planChange() {
    if (pending != null) return null;
    final now = DateTime.now();
    final ready =
        visible
            .where(
              (cat) =>
                  !busyCats.contains(cat.type) &&
                  !cat.nextChangeAt.isAfter(now),
            )
            .toList()
          ..sort((a, b) => a.nextChangeAt.compareTo(b.nextChangeAt));
    if (ready.isEmpty) return null;
    final cat = ready.first;
    final slots = List.generate(LobbyCats.spawns.length, (i) => i)
      ..shuffle(random);
    // Usually change surface, sometimes settle into another authored pose.
    if (random.nextInt(4) == 0) slots.insert(0, cat.spawnIndex!);
    for (final slot in slots) {
      for (var attempt = 0; attempt < 12; attempt++) {
        final surface = LobbyCats.spawns[slot];
        final point = surface.sample(random);
        final placement = surface.at(point);
        final pose = randomPose(slot, excluding: cat.pose);
        if (!placement.supports(pose)) continue;
        if (visible.any(
          (other) =>
              other.type != cat.type &&
              ((!surface.onGround &&
                      other.placement.surfaceGroup == surface.surfaceGroup) ||
                  other.placement.visualRect
                      .inflate(14)
                      .overlaps(placement.visualRect.inflate(14))),
        )) {
          continue;
        }
        if (slot == cat.spawnIndex &&
            (point - Offset(cat.placement.x, cat.placement.y)).distance < 5 &&
            surface.allowedPoses.length < 2) {
          continue;
        }
        return CatChange(
          outgoing: cat.type,
          incoming: cat.type,
          spawnIndex: slot,
          pose: pose,
          placement: placement,
        );
      }
    }
    cat.nextChangeAt = now.add(const Duration(seconds: 2));
    return null;
  }

  void begin(CatChange change) {
    assert(pending == null);
    // A scheduled change relocates one existing character. It must never add
    // a fourth cat or remove one of the three identities.
    if (change.incoming == null ||
        change.incoming != change.outgoing ||
        change.spawnIndex == null ||
        change.pose == null) {
      throw ArgumentError('A lobby change must retain the same cat.');
    }
    pending = change;
    notifyListeners();
  }

  /// Atomically replace a placement; all three characters remain registered.
  void commit() {
    final change = pending!;
    if (change.incoming case final type?) {
      final cat = characters[type]!;
      cat.spawnIndex = change.spawnIndex;
      cat.pose = change.pose!;
      cat.positioned = change.placement;
      final extra = cat.pose == CatPose.sleeping ? 18 : 0;
      cat.nextChangeAt = DateTime.now().add(
        Duration(
          seconds:
              LobbyCats.minInterval.inSeconds +
              extra +
              random.nextInt(
                LobbyCats.maxInterval.inSeconds -
                    LobbyCats.minInterval.inSeconds +
                    1,
              ),
        ),
      );
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
