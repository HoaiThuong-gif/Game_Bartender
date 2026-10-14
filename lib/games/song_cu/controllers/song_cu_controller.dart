import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/song_cu_levels.dart';
import '../models/song_cu_level.dart';
import '../models/song_cu_state.dart';
import '../services/song_cu_storage.dart';

class SongCuController extends ChangeNotifier {
  SongCuController() {
    level = generateSongCuBroadcast(
      DateTime.now().millisecondsSinceEpoch & 0x7fffffff,
      0,
    );
    state = SongCuState(level);
  }
  late SongCuLevel level;
  final _storage = SongCuStorage();
  late SongCuState state;
  Timer? _stableTimer;
  final _playClock = Stopwatch();
  int epoch = 1, revision = 0, round = 0;
  bool sound = true, reduceMotion = false, rhythmAssist = false;
  bool loaded = false, _disposed = false, _active = true;
  double volume = .18;
  int _hint = 0;
  String notice = '';
  String get phase => state.phase(level);

  Future<void> load() async {
    final saved = await _storage.load();
    if (_disposed) return;
    sound = saved['sound'] is bool ? saved['sound'] == true : true;
    reduceMotion = saved['reduceMotion'] == true;
    rhythmAssist = saved['rhythmAssist'] == true;
    final gain = saved['volume'];
    volume = gain is num && gain.isFinite ? gain.toDouble().clamp(0, .5) : .18;
    if (saved['version'] == 3 &&
        saved['seed'] is int &&
        saved['round'] is int) {
      round = (saved['round'] as int).clamp(0, 1000000000);
      level = generateSongCuBroadcast(saved['seed'] as int, round);
      state = SongCuState(level);
      final controls = saved['controls'];
      if (controls is List && controls.length == 4) {
        for (var i = 0; i < 3; i++) {
          final v = controls[i];
          if (v is num && v.isFinite) {
            state.controls[i] = v.toDouble().clamp(-1, 1);
          }
        }
      }
      state.powered = saved['powered'] == true;
      state.contact = saved['contact'] is int
          ? (saved['contact'] as int).clamp(0, level.contactTaps)
          : 0;
      state.complete = saved['complete'] == true;
    }
    state.controls[3] = volume * 4 - 1;
    loaded = true;
    _evaluateSignal();
    _changed();
    _save();
  }

  void _save() => unawaited(
    _storage
        .save({
          'version': 3,
          'seed': level.seed,
          'round': round,
          'controls': List.of(state.controls),
          'powered': state.powered,
          'contact': state.contact,
          'complete': state.complete,
          'sound': sound,
          'volume': volume,
          'reduceMotion': reduceMotion,
          'rhythmAssist': rhythmAssist,
        })
        .catchError((Object _) {
          if (!_disposed) {
            notice = 'Chưa lưu được tiến độ.';
            _changed();
          }
        }),
  );

  Map<String, Object> snapshot({required bool systemReducedMotion}) => {
    'epoch': epoch,
    'revision': revision,
    'ack': state.ack,
    'seed': level.seed,
    'scene': level.scene,
    'channel': state.channel,
    'targetChannel': level.channel,
    'needsAntennas': level.needsAntennas,
    'controls': List.of(state.controls),
    'targets': level.targets,
    'tolerance': level.tolerance,
    'quality': state.quality(level),
    'powered': state.powered,
    'phase': phase,
    'stable': state.stable,
    'contact': state.contact,
    'contactTaps': level.contactTaps,
    'rhythm': level.rhythm,
    'entered': List.of(state.entered),
    'playback': state.playback,
    'playing': state.playing,
    'observed': state.observed,
    'complete': state.complete,
    'sound': sound,
    'volume': volume,
    'reduceMotion': reduceMotion || systemReducedMotion,
    'rhythmAssist': rhythmAssist,
  };

  void settings({bool? audio, double? gain, bool? reduced, bool? assist}) {
    sound = audio ?? sound;
    volume = (gain ?? volume).clamp(0, .5);
    state.controls[3] = volume * 4 - 1;
    reduceMotion = reduced ?? reduceMotion;
    rhythmAssist = assist ?? rhythmAssist;
    _changed();
    _save();
  }

  void remote(String kind, [int step = 0]) {
    action({'epoch': epoch, 'kind': kind, 'step': step});
  }

  void setActive(bool active) {
    if (_disposed || _active == active) return;
    _active = active;
    if (!active) {
      _stableTimer?.cancel();
      _stableTimer = null;
      state.playing = false;
      state.observed = false;
      _playClock.stop();
      if (loaded) _save();
    } else {
      _evaluateSignal();
    }
    _changed();
  }

  String hint() {
    const hints = [
      'Bật NGUỒN. Xoay núm KÊNH hoặc bấm Kênh +/− trên remote để tìm chương trình có đèn lồng.',
      'Kéo anten trái để giảm bóng hình; kéo anten phải để giảm nhiễu và rung hình. Không cần chỉnh âm lượng để thắng.',
      'Khi hình ổn định, đèn lồng sẽ phát nhịp. Nếu hình bị tối ngắt quãng, gõ ngắn lên nóc để sửa tiếp xúc.',
      'Bấm Phát lại trên remote, xem đèn lồng rồi gõ cùng thứ tự lên nóc TV. Có thể Xóa hoặc Lùi 1.',
      'Chạm dưới 0,4 giây là ngắn. Giữ khoảng 0,6–2 giây là dài. Khoảng nghỉ tùy bạn. Ký hiệu hỗ trợ nằm trên remote.',
    ];
    return hints[(_hint++).clamp(0, hints.length - 1)];
  }

  void restart() => _reset();
  void nextBroadcast() {
    if (!state.complete) return;
    round++;
    final seed = (level.seed + 104729 + Random().nextInt(100000)) & 0x7fffffff;
    level = generateSongCuBroadcast(seed, round);
    _reset(powered: true);
  }

  void _reset({bool powered = false}) {
    _stableTimer?.cancel();
    _stableTimer = null;
    _playClock.stop();
    _playClock.reset();
    state = SongCuState(level)..powered = powered;
    state.controls[3] = volume * 4 - 1;
    epoch++;
    _hint = 0;
    notice = '';
    _changed();
    _save();
  }

  void _complete() {
    state.complete = true;
    state.playing = false;
    _playClock.stop();
    notice = '';
    _save();
  }

  void _play() {
    state.playback++;
    state.playing = true;
    state.observed = false;
    _playClock.reset();
    _playClock.start();
  }

  void action(Map<String, dynamic> data) {
    if (_disposed || !loaded || !_active || data['epoch'] != epoch) return;
    final kind = data['kind'];
    if (kind == 'saveControls') {
      saveControls();
      return;
    }
    notice = '';
    if (kind == 'power') {
      state.powered = !state.powered;
      state.playing = false;
      state.observed = false;
      _playClock.stop();
      _evaluateSignal();
      _changed();
      _save();
      return;
    }
    if (!state.powered) return;
    if (kind == 'volume') {
      final step = data['step'];
      if (step is! int || step.abs() != 1) return;
      settings(gain: volume + step * .025);
      return;
    }
    if (kind == 'channel') {
      final step = data['step'];
      if (step is! int || step.abs() != 1 || state.complete) return;
      final channel = (state.channel + step + 8) % 8;
      state.controls[2] = channel / 3.5 - 1;
      state.entered.clear();
      state.observed = false;
      _evaluateSignal();
    } else if (kind == 'control') {
      final index = data['index'],
          value = data['value'],
          serial = data['serial'];
      if (index is! int ||
          index < 0 ||
          index > 3 ||
          value is! num ||
          !value.isFinite ||
          serial is! int ||
          serial <= state.ack) {
        return;
      }
      state.ack = serial;
      if (state.complete && index != 3) {
        _changed();
        return;
      }
      final oldChannel = state.channel;
      state.controls[index] = value.toDouble().clamp(-1, 1);
      if (index == 3) {
        volume = (state.controls[3] + 1) / 4;
      } else {
        if (oldChannel != state.channel) {
          state.entered.clear();
          state.observed = false;
        }
        _evaluateSignal();
      }
    } else if (state.complete) {
      return;
    } else if (kind == 'roof') {
      final duration = data['duration'];
      if (duration is! num ||
          !duration.isFinite ||
          duration < 20 ||
          duration > 2200) {
        return;
      }
      if (phase == 'contact' && duration <= 420) {
        state.contact = (state.contact + 1).clamp(0, level.contactTaps);
        if (state.contact == level.contactTaps) {
          if (level.rhythm.isEmpty) {
            _complete();
          } else {
            _play();
          }
        }
      } else if (phase == 'morse' && !state.playing && state.observed) {
        if (duration > 420 && duration < 550) {
          notice = 'Nhịp chưa rõ.';
        } else if (state.entered.length < level.rhythm.length) {
          state.entered.add(duration <= 420 ? '.' : '-');
          if (state.entered.length == level.rhythm.length) {
            if (listEquals(state.entered, level.rhythm)) {
              _complete();
            } else {
              notice = 'Nhịp chưa khớp.';
            }
          }
        }
      }
    } else if (kind == 'replay' && phase == 'morse') {
      _play();
    } else if (kind == 'playbackEnd' &&
        state.playing &&
        data['playback'] == state.playback &&
        _playClock.elapsedMilliseconds >= level.playbackMs - 100) {
      state.playing = false;
      state.observed = true;
      _playClock.stop();
    } else if ((kind == 'erase' || kind == 'undo') && !state.playing) {
      if (kind == 'erase') {
        state.entered.clear();
      } else if (state.entered.isNotEmpty) {
        state.entered.removeLast();
      }
    } else {
      return;
    }
    _changed();
    // Drag snapshots are saved on release instead of writing storage every frame.
    if (kind != 'control') _save();
  }

  void saveControls() {
    if (loaded && !_disposed) _save();
  }

  void _evaluateSignal() {
    if (!state.powered ||
        !state.tuned(level, relaxed: state.stable) ||
        !_active) {
      _stableTimer?.cancel();
      _stableTimer = null;
      state.stable = false;
      state.playing = false;
      state.observed = false;
      _playClock.stop();
      return;
    }
    if (state.complete || state.stable || _stableTimer != null) return;
    _stableTimer = Timer(const Duration(milliseconds: 650), () {
      _stableTimer = null;
      if (_disposed || !_active || !state.powered || !state.tuned(level)) {
        return;
      }
      state.stable = true;
      if (state.contact >= level.contactTaps) {
        if (level.rhythm.isEmpty) {
          _complete();
        } else {
          _play();
        }
      }
      _changed();
    });
  }

  void _changed() {
    if (!_disposed) {
      revision++;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _stableTimer?.cancel();
    _playClock.stop();
    super.dispose();
  }
}
