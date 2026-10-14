import 'dart:math' as math;

import 'song_cu_level.dart';

class SongCuState {
  SongCuState(SongCuLevel level) : controls = List.of(level.initial);

  bool powered = false;
  final List<double> controls;
  int ack = 0;
  bool stable = false;
  int contact = 0;
  int playback = 0;
  bool playing = false;
  bool observed = false;
  bool complete = false;
  final List<String> entered = [];

  List<double> quality(SongCuLevel level) => [
    for (var i = 0; i < 2; i++)
      math.exp(-3 * math.pow(controls[i] - level.targets[i], 2)),
  ];

  int get channel => ((controls[2] + 1) * 3.5).round().clamp(0, 7);

  bool tuned(SongCuLevel level, {bool relaxed = false}) =>
      channel == level.channel &&
      (!level.needsAntennas ||
          List.generate(
            2,
            (i) => (controls[i] - level.targets[i]).abs(),
          ).every((error) => error <= level.tolerance + (relaxed ? .04 : 0)));

  String phase(SongCuLevel level) {
    if (complete) return 'complete';
    if (!powered) return 'off';
    if (!stable) return 'tune';
    if (contact < level.contactTaps) return 'contact';
    return 'morse';
  }
}
