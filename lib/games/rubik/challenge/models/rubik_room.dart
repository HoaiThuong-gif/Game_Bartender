enum ChallengeStatus { waiting, ready, countdown, playing, finished }

Map<String, dynamic> challengeMap(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : {};

class ChallengePlayer {
  ChallengePlayer(Map<String, dynamic> data)
    : name = data['name'] as String? ?? 'Người chơi',
      ready = data['ready'] == true,
      finished = data['finished'] == true,
      dnf = data['dnf'] == true,
      rematch = data['rematch'] == true,
      left = data['left'] == true,
      finishMs = (data['finishMs'] as num?)?.toInt();
  final String name;
  final bool ready, finished, dnf, rematch, left;
  final int? finishMs;
}

class RubikRoom {
  RubikRoom(this.code, Map<String, dynamic> data)
    : status = ChallengeStatus.values.byName(data['status'] as String),
      round = (data['round'] as num).toInt(),
      creationId = data['creationId'] as String,
      startAt = (data['startAt'] as num?)?.toInt(),
      winnerId = data['winnerId'] as String?,
      scramble = List<String>.from(data['scramble'] as List? ?? []),
      rewards = challengeMap(data['rewards'])
          .map((k, v) => MapEntry(k, (v as num).toInt())),
      players = challengeMap(data['players'])
          .map((k, v) => MapEntry(k, ChallengePlayer(challengeMap(v))));
  final String code, creationId;
  final ChallengeStatus status;
  final int round;
  final int? startAt;
  final String? winnerId;
  final List<String> scramble;
  final Map<String, ChallengePlayer> players;
  final Map<String, int> rewards;
  String get rewardId => '${creationId}_$round';
}

String challengeTime(int milliseconds) {
  final ms = milliseconds.clamp(0, 99999999);
  return '${(ms ~/ 60000).toString().padLeft(2, '0')}:'
      '${(ms ~/ 1000 % 60).toString().padLeft(2, '0')}.'
      '${(ms % 1000).toString().padLeft(3, '0')}';
}
