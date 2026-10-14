class SongCuLevel {
  const SongCuLevel({
    required this.seed,
    required this.targets,
    required this.initial,
    required this.rhythm,
    this.tolerance = .16,
    this.contactTaps = 2,
    this.channel = 3,
    this.scene = 0,
    this.needsAntennas = true,
  });

  final int seed;
  // Normalized [-1, 1]: left antenna, right antenna, channel, volume.
  final List<double> targets;
  final List<double> initial;
  final List<String> rhythm;
  final double tolerance;
  final int contactTaps;
  final int channel, scene;
  final bool needsAntennas;

  String get title => 'Bắt lại buổi chiều';
  String get goal => 'Chỉnh anten, căn hình rồi gõ lại lời nhắn trên nóc TV.';
  int get playbackMs =>
      600 +
      rhythm.fold<int>(
        0,
        (total, mark) => total + (mark == '.' ? 350 : 950) + 550,
      );

  bool get valid =>
      targets.length == 4 &&
      initial.length == 4 &&
      [...targets, ...initial].every((v) => v.isFinite && v >= -1 && v <= 1) &&
      tolerance >= .1 &&
      tolerance <= .3 &&
      channel >= 0 &&
      channel < 8 &&
      scene >= 0 &&
      scene < 4 &&
      contactTaps >= 0 &&
      rhythm.length <= 6 &&
      rhythm.every((mark) => mark == '.' || mark == '-');
}
