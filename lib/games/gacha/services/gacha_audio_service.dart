import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum GachaSound {
  paperPick,
  paperRustle,
  paperTear,
  numberReveal,
  prizeHit,
  itemReveal,
}

/// One short-effect player, no looping or preloaded collection audio.
class GachaAudioService {
  AudioPlayer? _player;
  bool _disposed = false;
  Future<void> _queue = Future.value();
  static const paths = {
    GachaSound.paperPick: 'audio/gacha/paper_pick.wav',
    GachaSound.paperRustle: 'audio/gacha/paper_rustle.wav',
    GachaSound.paperTear: 'audio/gacha/paper_tear.wav',
    GachaSound.numberReveal: 'audio/gacha/number_reveal.wav',
    GachaSound.prizeHit: 'audio/gacha/prize_hit.wav',
    GachaSound.itemReveal: 'audio/gacha/item_reveal.wav',
  };
  void play(GachaSound sound) {
    if (_disposed) return;
    _queue = _queue.then((_) async {
      if (_disposed) return;
      try {
        final player = _player ??= AudioPlayer();
        await player.play(AssetSource(paths[sound]!), volume: .35);
      } catch (error) {
        if (kDebugMode) debugPrint('[GachaAudio] ${paths[sound]}: $error');
      }
    });
  }

  void stop() {
    _queue = _queue.then((_) async {
      try {
        await _player?.stop();
      } catch (_) {}
    });
  }

  void dispose() {
    _disposed = true;
    unawaited(
      _queue.then((_) async {
        try {
          await _player?.dispose();
        } catch (_) {}
        _player = null;
      }),
    );
  }
}
