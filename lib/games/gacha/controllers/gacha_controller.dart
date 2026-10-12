import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/gacha_rewards.dart';
import '../models/gacha_reward.dart';
import '../models/gacha_ticket_state.dart';
import '../services/gacha_collection.dart';
import '../services/gacha_wallet.dart';

/// One charge and one random result per turn; no renderer resources here.
class GachaController extends ChangeNotifier {
  GachaController({
    required this.collection,
    required this.wallet,
    Random? random,
  }) : _random = random ?? Random();
  final GachaCollection collection;
  final GachaWallet wallet;
  final Random _random;
  GachaTicketState state = GachaTicketState.idle;
  GachaReward? reward;
  GachaReward? result;
  double progress = 0;
  final tearProgress = ValueNotifier<double>(0);
  bool tearFromLeft = true;
  bool _directionChosen = false;
  bool duplicate = false;
  bool resultVisible = false;
  bool active = true;
  bool _disposed = false;
  bool _collecting = false;
  bool _saved = false;
  String? message;
  Timer? _timer;
  void _emit() {
    if (!_disposed) notifyListeners();
  }

  bool get canDraw =>
      active &&
      !_collecting &&
      (state == GachaTicketState.idle || state == GachaTicketState.result);
  bool get canTear =>
      active &&
      (state == GachaTicketState.waitingForTear ||
          state == GachaTicketState.tearing);
  bool get collecting => _collecting;
  bool get saved => _saved;
  Future<void> initialize() async {
    try {
      await wallet.load();
      _emit();
    } catch (error) {
      if (!_disposed) {
        message = 'Chưa đọc được số cá. Hãy thử lại khi bốc giấy.';
        _emit();
      }
    }
  }

  void _after(Duration duration, VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, () {
      if (!_disposed) action();
    });
  }

  Future<bool> draw() async {
    if (!canDraw) return false;
    final previous = state;
    state = GachaTicketState.selecting;
    resultVisible = false;
    message = null;
    _emit();
    try {
      if (!await collection.load()) {
        throw StateError('Collection storage unavailable');
      }
      if (_disposed) return false;
      if (!await wallet.spend()) {
        if (_disposed) return false;
        state = previous;
        message = 'Không đủ 100 cá để bốc. Bạn còn ${wallet.balance} cá.';
        _emit();
        return false;
      }
    } catch (error) {
      if (_disposed) return false;
      state = previous;
      message = 'Chưa lưu được số cá. Hãy thử lại.';
      _emit();
      return false;
    }
    if (_disposed) return false;
    reward = gachaRewardPool.draw(_random);
    result = null;
    duplicate = collection.owns(reward!.number);
    progress = 0;
    tearProgress.value = 0;
    tearFromLeft = true;
    _directionChosen = false;
    _saved = false;
    state = GachaTicketState.paperFocus;
    _emit();
    _after(const Duration(milliseconds: 280), () {
      state = GachaTicketState.waitingForTear;
      _emit();
    });
    return true;
  }

  void tear(double delta) {
    if (!canTear || delta == 0 || !delta.isFinite) return;
    final previousState = state;
    if (!_directionChosen) {
      tearFromLeft = delta > 0;
      _directionChosen = true;
    }
    // Torn paper never heals when the finger reverses or is lifted.
    final next = (progress + delta * (tearFromLeft ? 1 : -1)).clamp(0.0, 1.0);
    if (next > progress) progress = next;
    state = GachaTicketState.tearing;
    if (progress >= .65) {
      progress = 1;
      result = reward;
      state = GachaTicketState.numberReveal;
      _after(const Duration(milliseconds: 500), () {
        state = GachaTicketState.prizeLookup;
        _emit();
        _after(const Duration(milliseconds: 600), () {
          state = GachaTicketState.itemReveal;
          _emit();
          _after(const Duration(milliseconds: 300), finishReveal);
        });
      });
    }
    tearProgress.value = progress;
    // Only the paper listens to continuous progress; scene rebuilds on stages.
    if (state != previousState) _emit();
  }

  void endTear() {
    if (state != GachaTicketState.tearing &&
        state != GachaTicketState.waitingForTear) {
      return;
    }
    state = GachaTicketState.waitingForTear;
    _emit();
  }

  void finishReveal() {
    if (_disposed || state != GachaTicketState.itemReveal) return;
    _timer?.cancel();
    reward = null;
    state = GachaTicketState.result;
    resultVisible = active;
    // Preserve collection UX: award once on reveal, even if dismissed.
    unawaited(collect());
    _emit();
  }

  Future<void> collect() async {
    if (_disposed || _saved || _collecting || result == null) return;
    _collecting = true;
    final number = result!.number;
    _emit();
    final saved = await collection.unlock(number);
    if (_disposed) return;
    _collecting = false;
    _saved = saved;
    if (!saved) message = 'Chưa lưu được vật phẩm. Mở Tủ đồ để thử lại.';
    _emit();
  }

  void closeResult() {
    resultVisible = false;
    _emit();
  }

  void reopenResult() {
    if (active && state == GachaTicketState.result && result != null) {
      resultVisible = true;
      _emit();
    }
  }

  void setActive(bool value) {
    active = value;
    if (!value) {
      resultVisible = false;
      if (state == GachaTicketState.tearing) endTear();
    }
    _emit();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    tearProgress.dispose();
    super.dispose();
  }
}
