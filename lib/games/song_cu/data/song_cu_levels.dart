import 'dart:math';

import '../models/song_cu_level.dart';

SongCuLevel generateSongCuBroadcast(int seed, int round) {
  final random = Random(seed);
  final difficulty = round.clamp(0, 12);
  final needsAntennas = round == 0 || round % 5 != 3;
  final needsRhythm = round == 0 || round % 4 != 2;
  final targets = [
    random.nextDouble() * 1.4 - .7,
    random.nextDouble() * 1.4 - .7,
    0.0,
    0.0,
  ];
  final initial = [
    for (var i = 0; i < 2; i++)
      (targets[i] + (targets[i] > 0 ? -.85 : .85)).clamp(-1.0, 1.0),
    -1.0,
    -.28,
  ];
  return SongCuLevel(
    seed: seed,
    targets: targets,
    initial: initial,
    channel: 1 + random.nextInt(7),
    scene: random.nextInt(4),
    needsAntennas: needsAntennas,
    tolerance: .25 - difficulty * .007,
    contactTaps: needsRhythm && round % 3 == 1 ? 1 : 0,
    rhythm: needsRhythm
        ? [
            for (var i = 0; i < 3 + difficulty ~/ 4; i++)
              random.nextBool() ? '.' : '-',
          ]
        : [],
  );
}
